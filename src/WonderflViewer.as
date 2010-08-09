package  
{
	import com.adobe.serialization.json.JSON;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import net.wonderfl.component.core.UIComponent;
	import net.wonderfl.editor.AS3Viewer;
	import net.wonderfl.editor.livecoding.LiveCodingEvent;
	import net.wonderfl.editor.livecoding.LiveCodingPanelEvent;
	import net.wonderfl.editor.livecoding.LiveCodingViewerPanel;
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
			trace(JSON.encode(loaderInfo.parameters));
			
			_viewer = new AS3Viewer;
			_viewer.addEventListener(Event.COMPLETE, onColoringComplete);
			addChild(_viewer);
			
			var resize:Function = bind(updateSize);
			
			if (loaderInfo.parameters.server) {
				_isLive = true;
				_infoPanel = new LiveCodingViewerPanel(_viewer);
				_infoPanel.setUpdateParent(updateSize);
				_infoPanel.addEventListener(Event.CLOSE, resize);
				_infoPanel.addEventListener(LiveCodingEvent.JOINED, resize);
				_infoPanel.addEventListener(LiveCodingPanelEvent.CHAT_WINDOW_OPEN, resize);
				_infoPanel.addEventListener(LiveCodingPanelEvent.CHAT_WINDOW_CLOSE, resize);
				addChild(_infoPanel);
				_infoPanel.init(Boolean(parseInt(loaderInfo.parameters.big_viewer)));
				_infoPanel.connect();
				_infoPanel.start();
			}
			
			if (ExternalInterface.available) {
				var code:String = ExternalInterface.call("Wonderfl.Codepage.get_initial_code");
				_source = code || "";
				_viewer.text = _source;
 			}
			
			ContextMenuBuilder.getInstance().buildMenu(this, _viewer);
			
			stage.dispatchEvent(new Event(Event.RESIZE));
		}
		
		private function onColoringComplete(e:Event):void 
		{
			_selectionObject = null;
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
			
			setSize(w, h);
		}
		
		override protected function updateSize():void 
		{
			if (!_viewer) return;
			
			trace("WonderflViewer.updateSize");
			_viewer.width = _width;
			if (_infoPanel && _infoPanel.isLive()) {
				_infoPanel.width = _width;
				_viewer.y = _infoPanel.height;
				_viewer.height = height - _infoPanel.height;
				if (_infoPanel.isChatWindowOpen())
					_viewer.setSize(_width - 288, _height);
				if (!_infoPanel.parent) addChild(_infoPanel);
			} else {
				_viewer.y = 0;
				_viewer.height = _height;
				_viewer.setSize(_width, _height);
			}
		}
		
		
		
		private function start():void {
			addChild(_infoPanel);
			_infoPanel.start();
			_isLive = true;
			updateSize();
		}
		
		
		private function startListening(e:LiveCodingEvent):void 
		{
			_isLive = true;
			
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