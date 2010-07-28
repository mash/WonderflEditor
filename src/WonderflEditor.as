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
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import net.wonderfl.chat.Chat;
	import net.wonderfl.chat.ChatButton;
	import net.wonderfl.chat.ChatClient;
	import net.wonderfl.component.core.UIComponent;
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
	public class WonderflEditor extends UIComponent
	{
		[Embed(source = '../assets/btn_smallscreen.jpg')]
		private var _image_out_:Class;
		
		[Embed(source = '../assets/btn_smallscreen_o.jpg')]
		private var _image_over_:Class;
		
		private var _scaleDownButton:Sprite;
		private var _editor:AS3Editor;
		private var _compileTimer:Timer;
		private var _client:ChatClient;
		private var _mouseUIFlag:Boolean = false;
		private var _chatButton:ChatButton;
		private var _chat:Chat;
		private const CHAT_BUTTON_MIN_WIDTH:int = 80;
		
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
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			if (loaderInfo.parameters)
				LiveCodingSettings.setUpParameters(loaderInfo.parameters);
				
			
			var resetTimer:Function;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, resetTimer = bind(_compileTimer.reset));
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function ():void {
				resetTimer();
				_mouseUIFlag = true;
			});
			stage.addEventListener(Event.MOUSE_LEAVE, clearMouseUIFlag);
			stage.addEventListener(MouseEvent.MOUSE_UP, clearMouseUIFlag);
			
			ContextMenuBuilder.getInstance().buildMenu(this, _editor, true);
			
			_client = new ChatClient;
			_client.init(root.loaderInfo.parameters);
			
			_chatButton = new ChatButton;
			var duration:int = 300;
			var startTime:int;
			var tweening:Boolean = false;
			var buttonXTo:int, buttonXFrom:int, chatXTo:int, chatXFrom:int;
			const LEFT:uint = _width - 288;
			_chatButton.x = _width - CHAT_BUTTON_MIN_WIDTH;
			
			_chatButton.addEventListener(MouseEvent.CLICK, function ():void {
				if (tweening) return;
				
				tweening = true;
				_chatButton.toggle();
				if (_chatButton.isOpen()) {
					buttonXTo = chatXTo = _width - 288;
					buttonXFrom = _width - CHAT_BUTTON_MIN_WIDTH;
					chatXFrom = _width;
				} else {
					buttonXFrom = chatXFrom = _width - 288;
					buttonXTo = _width - CHAT_BUTTON_MIN_WIDTH;
					chatXTo = _width;
					updateSize();
				}
				
				startTime = getTimer();
				addEventListener(Event.ENTER_FRAME, tweener);
			});
			
			function tweener(e:Event):void {
				var time:int = getTimer() - startTime;
				
				if (time > duration) {
					_chatButton.x = buttonXTo; _chat.x = chatXTo;
					removeEventListener(Event.ENTER_FRAME, tweener);
					tweening = false;
					if (_chatButton.isOpen()) updateSize();
					return;
				}
				
				var t:Number = time / duration;
				var u:Number;
				t = t * (2 - t);
				u = 1 - t;
				
				_chatButton.x = t * buttonXTo + u * buttonXFrom;
				_chat.x = t * chatXTo + u * chatXFrom;
			}
			
			_chat = new Chat(_client);
			_chat.x = _width - 288;
			_chat.y = 20;
			addChild(_chat);
			
			addChild(_chatButton);
			_chatButton.setSize(288, 20);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onResize);
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
			if (_chatButton.isOpen()) {
				_editor.setSize(_width - 288, _height);
				_scaleDownButton.x = _width - _scaleDownButton.width - 288 -15;
				_scaleDownButton.y = 0;
			} else {
				_editor.setSize(_width, _height);
				_scaleDownButton.x = _width - _scaleDownButton.width - 15;
				_scaleDownButton.y = 20;
				
			}
			_scaleDownButton.visible = (_width > 465 || _height > 465);
			
			if (_chatButton.isOpen()) {
				_chat.x = _width - 288;
				_chatButton.x = _width -288;
			} else {
				_chatButton.x = _width - CHAT_BUTTON_MIN_WIDTH;
				_chat.x = _width;
			}
			_chat.setSize(288, _height - 20);
		}
	}
}