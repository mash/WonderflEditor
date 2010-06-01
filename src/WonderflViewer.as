package  
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Transform;
	import flash.net.FileReference;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuClipboardItems;
	import flash.ui.ContextMenuItem;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import jp.psyark.utils.callLater;
	import jp.psyark.utils.CodeUtil;
	import jp.psyark.utils.StringComparator;
	import net.wonderfl.editor.minibuilder.ASParserController;
	import net.wonderfl.editor.core.UIComponent;
	import net.wonderfl.editor.UIFTETextFieldComponent;
	import net.wonderfl.editor.livecoding.LiveCoding;
	import net.wonderfl.editor.livecoding.LiveCodingEvent;
	import net.wonderfl.editor.livecoding.LiveCodingSettings;
	import net.wonderfl.editor.livecoding.SocketBroadCaster;
	import net.wonderfl.editor.livecoding.ViewerInfoPanel;
	import org.libspark.ui.SWFWheel;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class WonderflViewer extends UIComponent
	{
		private static const TICK:int = 6;
		private static const COPY:String = 'Copy (C-c)';
		private static const SELECT_ALL:String = 'Select All (C-a)';
		private static const SAVE:String = 'Save (C-s)';
		private static const MINI_BUILDER:String = 'MiniBuilder';
		public var fileRef:FileReference;
		
		[Embed(source = '../assets/btn_smallscreen.jpg')]
		private var _image_out_:Class;
		
		[Embed(source = '../assets/btn_smallscreen_o.jpg')]
		private var _image_over_:Class;
		
		private var _viewer:UIFTETextFieldComponent;
		private var _ctrl:ASParserController;
		private var _scaleDownButton:Sprite;
		private var broadcaster:SocketBroadCaster = new SocketBroadCaster;
		private var _source:String ='';
		private var _commandList:Array = [];
		private var _executer:Sprite = new Sprite;
		private var _parseTime:int;
		private var _setInitialCodeForLiveCoding:Boolean = false;
		private var _isLive:Boolean = false;
		private var _infoPanel:ViewerInfoPanel;
		private var _ignoreSelection:Boolean;
		private var _prevText:String;
		private var _comparetor:StringComparator;
		private var _selectionObject:Object;
		
		public function WonderflViewer() 
		{
			_parseTime = getTimer();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onResize);
			SWFWheel.initialize(stage);
			
			_scaleDownButton = new Sprite;
			_scaleDownButton.addChild(new _image_out_);
			var bm:Bitmap = new _image_over_;
			bm.visible = false;
			focusRect = null;
			
			_scaleDownButton.addChild(bm);
			_scaleDownButton.buttonMode = true;
			_scaleDownButton.tabEnabled = false;
			_scaleDownButton.visible = false;
			_scaleDownButton.addEventListener(MouseEvent.CLICK, function ():void {
				if (ExternalInterface.available) ExternalInterface.call("Wonderfl.Codepage.scale_down");
			});
			_scaleDownButton.addEventListener(MouseEvent.MOUSE_OVER, function ():void {
				bm.visible = true;
			});
			_scaleDownButton.addEventListener(MouseEvent.MOUSE_OUT, function ():void {
				bm.visible = false;
			});
			
			_viewer = new UIFTETextFieldComponent;
			_viewer.addEventListener(Event.COMPLETE, onColoringComplete);
			addChild(_viewer);
			addChild(_scaleDownButton);
			
			_ctrl = new ASParserController(stage, _viewer);
			
			_viewer.addEventListener(Event.CHANGE, onChange);

			if (loaderInfo.parameters)
				LiveCodingSettings.setUpParameters(loaderInfo.parameters);
			
			broadcaster.addEventListener(Event.CONNECT, function ():void {
				broadcaster.join(LiveCodingSettings.room, LiveCodingSettings.ticket);
			});
			broadcaster.addEventListener(LiveCodingEvent.JOINED, startListening);
			broadcaster.addEventListener(LiveCodingEvent.RELAYED, onRelayed);
			
			if (LiveCodingSettings.server && LiveCodingSettings.port) {
				broadcaster.connect(LiveCodingSettings.server, LiveCodingSettings.port);
				_setInitialCodeForLiveCoding = true;
				_comparetor = new StringComparator;
			}
			
			if (ExternalInterface.available) {
				var code:String = ExternalInterface.call("Wonderfl.Codepage.get_initial_code");
				code ||= "";
				_source = code.replace(/\t/g, "    ").replace(/\r\n/g, "\r").replace(/\n/g, "\r");
				_viewer.text = _source;
				//trace('init', code);
				if (!_setInitialCodeForLiveCoding) {
					onChange(null);
				}
 			}
			
			if (_setInitialCodeForLiveCoding) {
				addEventListener(Event.ENTER_FRAME, setupInitialCode);
				_setInitialCodeForLiveCoding = false;
			}
			
			var menu:ContextMenu = new ContextMenu;
			menu.hideBuiltInItems();
			menu.customItems = ([COPY, SELECT_ALL, SAVE, MINI_BUILDER]).map(
				function ($caption:String, $index:int, $arr:Array):ContextMenuItem {
					var item:ContextMenuItem = new ContextMenuItem($caption, $caption == MINI_BUILDER || $caption == SAVE);
					item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuItemSelected);
					
					return item;
				}
			);
			menu.addEventListener(ContextMenuEvent.MENU_SELECT, function ():void {
				menu.customItems[0].enabled = (_viewer.selectionBeginIndex != _viewer.selectionEndIndex);
				menu.customItems[1].enabled = (_viewer.selectionBeginIndex > 0 || _viewer.selectionEndIndex < _viewer.text.length - 1);
			});
			contextMenu = menu;
			stage.dispatchEvent(new Event(Event.RESIZE));
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		private function onMenuItemSelected(e:ContextMenuEvent):void 
		{
			switch (e.currentTarget.caption) {
			case COPY :
				_viewer.copy();
				break;
			case SELECT_ALL :
				_viewer.selectAll();
				break;
			case SAVE : 
				save();
				break;
			case MINI_BUILDER :
				navigateToURL(new URLRequest('http://code.google.com/p/minibuilder/'), '_self');
				break;
			}
		}
		
		private function onColoringComplete(e:Event):void 
		{
			if (_selectionObject)
				onSetSelection(_selectionObject.index, _selectionObject.index);
				
			_selectionObject = null;
		}
		
		private function keyDownHandler(e:KeyboardEvent):void 
		{
			if (e.ctrlKey) {
				if (e.keyCode == 83) { // Ctrl + S
					save();
				}
			}
		}
		
		public function save():void {
			var text:String = (Capabilities.os.indexOf('Windows') != -1) ? _viewer.text.replace(/\r/g, '\r\n') : _viewer.text;
			var localName:String = CodeUtil.getDefinitionLocalName(text);
			localName ||= "untitled";
			fileRef = new FileReference();
			fileRef.save(text, localName + ".as");
		}
		
		private function setupInitialCode(e:Event):void 
		{
			if (_commandList.length) {
				var t:int = getTimer();
				var command:Object;
				
				while (getTimer() - t < TICK) {
					if (_commandList.length == 0) break;
					
					command = _commandList.shift();
					if (command.method == LiveCoding.SEND_CURRENT_TEXT || command.method == LiveCoding.REPLACE_TEXT)
						command.method.apply(null, command.args);
				}
			} else {
				if (_setInitialCodeForLiveCoding) {
					removeEventListener(Event.ENTER_FRAME, setupInitialCode);
					_executer.addEventListener(Event.ENTER_FRAME, execute);
					onChange(null);
				}
			}
		}
		
		private function onResize(e:Event):void 
		{
			var w:int = stage.stageWidth;
			var h:int = stage.stageHeight;
			var size:Array;
			if (ExternalInterface.available) {
				size = ExternalInterface.call("Wonderfl.Codepage.get_stage_size");
				if (size) {
					w = size[0];
					h = size[1];
				}
			}
			
			width = (w > 465) ? w - 465 : w;
			height = h;
		}
		
		override protected function updateSize():void 
		{
			_viewer.width = width;
			_scaleDownButton.x = width - _scaleDownButton.width - 15;
			_scaleDownButton.visible = (width > 464 || height > 466);
			if (_isLive) {
				_infoPanel.width = _scaleDownButton.visible ? _scaleDownButton.x  : width - 15;
				_viewer.y = _infoPanel.height;
				_viewer.height = height - _infoPanel.height;
			} else {
				_viewer.y = 0;
				_viewer.height = height;
			}
		}
		
		private function onRelayed(e:LiveCodingEvent):void 
		{
			if (!_isLive) {
				restart();
			}
			
			var method:Function;
			switch (e.data.command) {
			case LiveCoding.REPLACE_TEXT:
				method = onReplaceText;
				break;
			case LiveCoding.SET_SELECTION:
				method = onSetSelection;
				break;
			case LiveCoding.SEND_CURRENT_TEXT:
				method = onSendCurrentText;
				break;
			case LiveCoding.SWF_RELOADED:
				method = onSWFReloaded;
				break;
			case LiveCoding.CLOSED:
				method = onClosed;
				break;
			case LiveCoding.SCROLL_V:
				method = onScrollV;
				break;
			case LiveCoding.SCROLL_H:
				method = onScrollH;
				break;
			}
			
			if (method != null) {
				var args:Array = e.data.args;
				_commandList[_commandList.length] = {
					method : method,
					args : args
				}
			}
		}
		
		private function onScrollH($scrollH:int):void
		{
			if (_infoPanel.isSync) _viewer.scrollH = $scrollH;
		}
		
		private function onScrollV($scrollV:int):void
		{
			if (_infoPanel.isSync) _viewer.scrollY = $scrollV;
		}
		
		private function onClosed():void
		{
			trace('on closed');
			//_viewer.hideCaret();
			_infoPanel.stop();
			if (_infoPanel.parent) _infoPanel.parent.removeChild(_infoPanel);
			_isLive = false;
			updateSize();
		}
		
		private function restart():void {
			trace('restart');
			addChild(_infoPanel);
			_infoPanel.restart();
			_isLive = true;
			updateSize();
		}
		
		private function onSWFReloaded():void
		{
			if (ExternalInterface.available)
				ExternalInterface.call('Wonderfl.Codepage.reload_swf');
		}
		
		private function startListening(e:LiveCodingEvent):void 
		{
			_isLive = true;
			
			addChild(_infoPanel = new ViewerInfoPanel);
			_infoPanel.elapsed_time = e.data ? e.data.elapsed_time : 0;
			broadcaster.addEventListener(LiveCodingEvent.MEMBERS_UPDATED, _infoPanel.onMemberUpdate);
			updateSize();
			
			setTimeout(function ():void {
				_setInitialCodeForLiveCoding = true;
			}, 1000);
		}
		
		private function execute(e:Event):void 
		{
			if (_commandList.length) {
				var t:int = getTimer();
				var command:Object;
				
				while (getTimer() - t < TICK) {
					if (_commandList.length == 0) break;
					
					command = _commandList.shift();
					command.method.apply(null, command.args);
				}
			}
		}
		
		private function onChange(e:Event):void 
		{
			var parserRunning:Boolean = _ctrl.sourceChanged(_source, '');
			
			if (!parserRunning)
				_viewer.text = _source;
		}
		
		private function substring($begin:int, $end:int = 0x7fffffff):String {
			var str:String = _source.substring($begin, $end);
			
			return (str) ? str : '';
		}
		
		
		private function onReplaceText($beginIndex:int, $endIndex:int, $newText:String):void 
		{
			//JSLog.logToConsole('viewer: onReplaceText', $beginIndex, $endIndex, $newText.length);
			_source = _source.substring(0, $beginIndex) + $newText + substring($endIndex);
			_viewer.text = _source;
			_selectionObject = {
				index : $endIndex + $newText.length
			}
			onChange(null);
		}
		
		private function onSetSelection($selectionBeginIndex:int, $selectionEndIndex:int):void
		{
			//JSLog.logToConsole('viewer: onSetSelection', $selectionBeginIndex, $selectionEndIndex);
			_ignoreSelection = false;
			//callLater(_viewer.setSelection, [$selectionBeginIndex, $selectionEndIndex]);
			_viewer.setSelection($selectionBeginIndex, $selectionEndIndex);
			_selectionObject = {
				index : $selectionEndIndex
			};
		}
		
		private function onSendCurrentText($text:String):void 
		{
			//JSLog.logToConsole('viewer: onSendCurrentText ', $text);
			_viewer.text = _source = $text;
			onChange(null);
		}		
	}
}