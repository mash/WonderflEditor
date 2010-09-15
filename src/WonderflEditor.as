package  
{
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	import net.wonderfl.chat.ChatClient;
	import net.wonderfl.component.core.UIComponent;
	import net.wonderfl.editor.AS3Editor;
	import net.wonderfl.editor.livecoding.LiveCoding;
	import net.wonderfl.editor.livecoding.LiveCodingEditorPanel;
	import net.wonderfl.editor.livecoding.LiveCodingPanelEvent;
	import net.wonderfl.editor.livecoding.LiveCodingViewerPanel;
	import net.wonderfl.editor.manager.ContextMenuBuilder;
	import net.wonderfl.editor.manager.LocalSettingManager;
	import net.wonderfl.utils.bind;
	import net.wonderfl.utils.listenOnce;
	import org.libspark.ui.SWFWheel;
	
	//import net.wonderfl.editor.WonderflEditor;
	
	/**
	 * @author kobayashi-taro
	 */
	public class WonderflEditor extends UIComponent
	{
		private var _editor:AS3Editor;
		private var _compileTimer:Timer;
		private var _compileFlag:Boolean;
		private var _client:ChatClient;
		private var _mouseUIFlag:Boolean = false;
		private var _infoPanel:LiveCodingEditorPanel;
		
		public function WonderflEditor() 
		{
			LocalSettingManager.initialize();
			addChild(_editor = new AS3Editor);
			_compileTimer = new Timer(1500, 1);
			_compileTimer.addEventListener(TimerEvent.TIMER, bind(compile));
			_editor.addEventListener(Event.COMPLETE, function ():void {
				_compileFlag = true;
				_compileTimer.start();
			});
			_editor.setFontSize(12);
			
			focusRect = null;
			
			listenOnce(this, Event.ADDED_TO_STAGE, init);
			
			CONFIG::useExternalInterface {
				if (ExternalInterface.available) {
					ExternalInterface.addCallback("xi_get_code", js_xi_get_code);
					ExternalInterface.addCallback("xi_set_error", _editor.setError);
					ExternalInterface.addCallback("xi_clear_errors", _editor.clearErrors);
					ExternalInterface.addCallback("xi_swf_reloaded", _editor.onSWFReloaded);
				}
			}
		}
		
		private function compile():void
		{
			_compileFlag = false;
			trace("WonderflEditor.compile");
			CONFIG::useExternalInterface {
				if (ExternalInterface.available && !_mouseUIFlag) {
					ExternalInterface.call("Wonderfl.Compiler.edit_complete");
					_editor.clearErrors();
				}
			}
		}
		
		private function js_xi_get_code():String
		{
			return encodeURIComponent(_editor.text);
		}
		
		private function resetTimer(e:Event = null):void {
			_compileTimer.reset();
			if (_compileFlag) {
				_compileTimer.start();
			}
		}
		
		private function init():void 
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, resetTimer);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function ():void {
				resetTimer();
				_mouseUIFlag = true;
			});
			stage.addEventListener(Event.MOUSE_LEAVE, clearMouseUIFlag);
			stage.addEventListener(MouseEvent.MOUSE_UP, clearMouseUIFlag);
			
			ContextMenuBuilder.getInstance().buildMenu(this, _editor, true);
			var resize:Function = bind(updateSize);
			
			if (loaderInfo.parameters.server) {
				_infoPanel = new LiveCodingEditorPanel(_editor);
				_infoPanel.setUpdateParent(updateSize);
				_infoPanel.addEventListener(Event.CLOSE, resize);
				_infoPanel.addEventListener(LiveCodingPanelEvent.CHAT_WINDOW_OPEN, resize);
				_infoPanel.addEventListener(LiveCodingPanelEvent.CHAT_WINDOW_CLOSE, function ():void {
					_editor.setSize(_width, _height);
				});
				addChild(_infoPanel);
				_infoPanel.init(true);
				
				LiveCoding.getInstance().setSocket(_infoPanel.getSocket());
				LiveCoding.getInstance().setEditor(_editor);
			}	
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, resetTimer);
			stage.dispatchEvent(new Event(Event.RESIZE));
			
			CONFIG::useExternalInterface {
				if (ExternalInterface.available) {
					SWFWheel.initialize(stage);
					SWFWheel.browserScroll = false;
					
					var code:String = ExternalInterface.call("Wonderfl.Compiler.get_initial_code");
					_editor.text = (code) ? code : "";
				}
			}
		}
		
		private function clearMouseUIFlag(e:Event):void {
			_mouseUIFlag = false;
		}
		
		private function onResize(e:Event):void 
		{
			var w:int = stage.stageWidth;
			var h:int = stage.stageHeight;
			var size:Array;
			CONFIG::useExternalInterface {
				if (ExternalInterface.available) {
					size = ExternalInterface.call("Wonderfl.Compiler.get_stage_size");
					if (size) {
						w = size[0];
						h = size[1];
					}
				}
			}
			
			setSize(w, h);
		}
		
		override protected function updateSize():void 
		{
			if (_infoPanel) {
				_infoPanel.width = _width;
				
				if (_infoPanel.isLive())
					_editor.setSize(_infoPanel.getChatLeftPos(), _height);
				else
					_editor.setSize(_width, _height);
			} else {
				_editor.setSize(_width, _height);
			}
		}
	}
}