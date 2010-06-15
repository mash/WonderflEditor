package  
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import net.wonderfl.editor.AS3Editor;
	import net.wonderfl.editor.livecoding.LiveCoding;
	import net.wonderfl.editor.livecoding.LiveCodingSettings;
	import net.wonderfl.editor.manager.ContextMenuBuilder;
	import net.wonderfl.editor.manager.LocalSettingManager;
	import net.wonderfl.editor.utils.bind;
	import org.libspark.ui.SWFWheel;
	
	//import net.wonderfl.editor.WonderflEditor;
	
	/**
	 * @author kobayashi-taro
	 */
	public class WonderflEditor extends Sprite
	{
		[Embed(source = '../assets/btn_smallscreen.jpg')]
		private var _image_out_:Class;
		
		[Embed(source = '../assets/btn_smallscreen_o.jpg')]
		private var _image_over_:Class;
		
		private var _scaleDownButton:Sprite;
		private var _editor:AS3Editor;
		private var _compileTimer:Timer;
		private var _mouseUIFlag:Boolean = false;
		
		public function WonderflEditor() 
		{
			LocalSettingManager.initialize();
			new LiveCoding;
			addChild(_editor = new AS3Editor);
			LiveCoding.editor = _editor;
			_compileTimer = new Timer(1500, 1);
			_compileTimer.addEventListener(TimerEvent.TIMER, bind(compile));
			_editor.addEventListener(Event.COMPLETE, bind(_compileTimer.start));
			
			_editor.setFontSize(12);
			
			addChild(_scaleDownButton = new Sprite);
			_scaleDownButton.addChild(new _image_out_);
			var bm:Bitmap = new _image_over_;
			bm.visible = false;
			focusRect = null;
			
			_scaleDownButton.addChild(bm);
			_scaleDownButton.buttonMode = true;
			_scaleDownButton.tabEnabled = false;
			_scaleDownButton.addEventListener(MouseEvent.CLICK, function ():void {
				CONFIG::useExternalInterface {
					if (ExternalInterface.available) ExternalInterface.call("Wonderfl.Compiler.scale_down");
				}
			});
			_scaleDownButton.addEventListener(MouseEvent.MOUSE_OVER, function ():void {
				bm.visible = true;
			});
			_scaleDownButton.addEventListener(MouseEvent.MOUSE_OUT, function ():void {
				bm.visible = false;
			});
			
			addEventListener(Event.ADDED_TO_STAGE, init);
			
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
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			if (loaderInfo.parameters)
				LiveCodingSettings.setUpParameters(loaderInfo.parameters);
				
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onResize);
			stage.dispatchEvent(new Event(Event.RESIZE));
			
			var resetTimer:Function;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, resetTimer = bind(_compileTimer.reset));
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function ():void {
				resetTimer();
				_mouseUIFlag = true;
			});
			stage.addEventListener(Event.MOUSE_LEAVE, clearMouseUIFlag);
			stage.addEventListener(MouseEvent.MOUSE_UP, clearMouseUIFlag);
			
			ContextMenuBuilder.getInstance().buildMenu(this, _editor, true);
			
			CONFIG::useExternalInterface {
				if (ExternalInterface.available) {
					SWFWheel.initialize(stage);
					
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
			
			_editor.width = w;
			_editor.height = h;
			_scaleDownButton.x = w - _scaleDownButton.width - 15;
			_scaleDownButton.visible = (w > 465 || h > 465);
		}
	}
}