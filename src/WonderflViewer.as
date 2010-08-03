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
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import jp.psyark.utils.CodeUtil;
	import net.wonderfl.editor.AS3Viewer;
	import net.wonderfl.component.core.UIComponent;;
	import net.wonderfl.editor.livecoding.LiveCoding;
	import net.wonderfl.editor.livecoding.LiveCodingEvent;
	import net.wonderfl.editor.livecoding.LiveCodingSettings;
	import net.wonderfl.editor.livecoding.LiveCodingViewerPanel;
	import net.wonderfl.editor.livecoding.SocketBroadCaster;
	import net.wonderfl.editor.livecoding.ViewerInfoPanel;
	import net.wonderfl.editor.manager.ContextMenuBuilder;
	import net.wonderfl.utils.bind;
	import org.libspark.ui.SWFWheel;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class WonderflViewer extends UIComponent
	{
		private static const TICK:int = 33;
		private const CHAT_BUTTON_MIN_WIDTH:int = 80;
		
		private var _viewer:AS3Viewer;
		private var broadcaster:SocketBroadCaster = new SocketBroadCaster;
		private var _source:String ='';
		private var _commandList:Array = [];
		private var _executer:Sprite = new Sprite;
		private var _parseTime:int;
		private var _setInitialCodeForLiveCoding:Boolean = false;
		private var _isLive:Boolean = false;
		private var _infoPanel:LiveCodingViewerPanel;
		private var _ignoreSelection:Boolean;
		private var _prevText:String;
		private var _selectionObject:Object;
		
		public function WonderflViewer() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_parseTime = getTimer();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onResize);
			SWFWheel.initialize(stage);
			SWFWheel.browserScroll = false;
			
			focusRect = null;
			
			_viewer = new AS3Viewer;
			_viewer.addEventListener(Event.COMPLETE, onColoringComplete);
			addChild(_viewer);
			
			if (loaderInfo.parameters.server) {
				_infoPanel = new LiveCodingViewerPanel(_viewer);
				_infoPanel.addEventListener(Event.CLOSE, bind(updateSize));
				addChild(_infoPanel);
				_infoPanel.init();
			}
			//if (LiveCodingSettings.server && LiveCodingSettings.port) {
				//_setInitialCodeForLiveCoding = true;
			//}
			
			if (ExternalInterface.available) {
				var code:String = ExternalInterface.call("Wonderfl.Codepage.get_initial_code");
				_source = code || "";
				_viewer.text = _source;
 			}
			
			//if (_setInitialCodeForLiveCoding) {
				//addEventListener(Event.ENTER_FRAME, setupInitialCode);
				//_setInitialCodeForLiveCoding = false;
			//}
			
			ContextMenuBuilder.getInstance().buildMenu(this, _viewer);
			
			stage.dispatchEvent(new Event(Event.RESIZE));
		}
		
		private function onColoringComplete(e:Event):void 
		{
			//if (_selectionObject)
				//setSelection(_selectionObject.index, _selectionObject.index);
				
			_selectionObject = null;
		}
		
		//private function setupInitialCode(e:Event):void 
		//{
			//if (_commandList.length) {
				//var t:int = getTimer();
				//var command:Object;
				//
				//while (getTimer() - t < TICK) {
					//if (_commandList.length == 0) break;
					//
					//command = _commandList.shift();
					//if (command.method == LiveCoding.SEND_CURRENT_TEXT || command.method == LiveCoding.REPLACE_TEXT)
						//command.method.apply(null, command.args);
				//}
			//} else {
				//if (_setInitialCodeForLiveCoding) {
					//removeEventListener(Event.ENTER_FRAME, setupInitialCode);
					//_executer.addEventListener(Event.ENTER_FRAME, execute);
					//_viewer.onChange(null);
				//}
			//}
		//}
		
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
			
			setSize(w, h);
		}
		
		override protected function updateSize():void 
		{
			_viewer.width = _width;
			if (_isLive) {
				_infoPanel.width = _width;
				_viewer.y = _infoPanel.height;
				_viewer.height = height - _infoPanel.height;
			} else {
				_viewer.y = 0;
				_viewer.height = _height;
			}
			
			if (_infoPanel && _infoPanel.isChatWindowOpen()) {
				_viewer.setSize(_width - 288, _height);
			} else {
				_viewer.setSize(_width, _height);
				
			}
		}
		
		
		
		private function restart():void {
			trace('restart');
			addChild(_infoPanel);
			//addChild(_chat);
			//addChild(_chatButton);
			_infoPanel.start();
			_isLive = true;
			updateSize();
		}
		
		
		private function startListening(e:LiveCodingEvent):void 
		{
			_isLive = true;
			
			//addChild(_infoPanel = new ViewerInfoPanel);
			//addChild(_chat);
			//addChild(_chatButton);
			//_infoPanel.elapsed_time = e.data ? e.data.elapsed_time : 0;
			//broadcaster.addEventListener(LiveCodingEvent.MEMBERS_UPDATED, _infoPanel.onMemberUpdate);
			//updateSize();
			
			setTimeout(function ():void {
				_setInitialCodeForLiveCoding = true;
			}, 1000);
		}
		
		private function substring($begin:int, $end:int = 0x7fffffff):String {
			var str:String = _source.substring($begin, $end);
			
			return (str) ? str : '';
		}
		
	}
}