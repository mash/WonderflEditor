package  
{
	import com.adobe.serialization.json.JSON;
	import com.bit101.components.PushButton;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import net.wonderfl.chat.Chat;
	import net.wonderfl.chat.ChatArea;
	import net.wonderfl.chat.ChatButton;
	import net.wonderfl.chat.ChatMessage;
	import net.wonderfl.chat.ChatTextArea;
	import net.wonderfl.chat.ChatClient;
	import net.wonderfl.component.core.UIComponent;
	import net.wonderfl.component.scroll.VScrollBar;
	import net.wonderfl.editor.livecoding.LiveCodingEvent;
	
	/**
	 * @author kobayashi-taro
	 */
	public class ScrollBarTest extends UIComponent
	{
		private var _client:ChatClient;
		private var _code:String;
		
		public function ScrollBarTest() 
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			trace(JSON.encode(loaderInfo.parameters));
			
			var params:Object = root.loaderInfo.parameters;
			
			CONFIG::useExternalInterface {
				if (ExternalInterface.available) {
					_code = ExternalInterface.call("Wonderfl.Compiler.get_initial_code");
					ExternalInterface.addCallback("xi_get_code", js_xi_get_code);
					ExternalInterface.addCallback("xi_set_error", trace);
					ExternalInterface.addCallback("xi_clear_errors", trace);
					ExternalInterface.addCallback("xi_swf_reloaded", trace);
				}
				
				function getValue($paramName:String):String {
					return '"' + params[$paramName] + '"';
				}
			}			
			
			_client = new ChatClient;
			_client.init(params);
			
			var button:ChatButton = new ChatButton;
			var buttonMinWidth:int = 80;
			var duration:int = 300;
			var startTime:int;
			var tweening:Boolean = false;
			var buttonXTo:int, buttonXFrom:int, chatXTo:int, chatXFrom:int;
			const LEFT:uint = 465 - 288;
			button.x = 465 - buttonMinWidth;
			
			button.addEventListener(MouseEvent.CLICK, function ():void {
				if (tweening) return;
				
				tweening = true;
				button.toggle();
				if (button.isOpen()) {
					buttonXTo = chatXTo = LEFT;
					buttonXFrom = 465 - buttonMinWidth;
					chatXFrom = 465;
				} else {
					buttonXFrom = chatXFrom = LEFT;
					buttonXTo = 465 - buttonMinWidth;
					chatXTo = 465;
				}
				startTime = getTimer();
				addEventListener(Event.ENTER_FRAME, tweener);
			});
			
			function tweener(e:Event):void {
				var time:int = getTimer() - startTime;
				
				if (time > duration) {
					button.x = buttonXTo; chat.x = chatXTo;
					removeEventListener(Event.ENTER_FRAME, tweener);
					tweening = false;
					return;
				}
				
				var t:Number = time / duration;
				var u:Number;
				t = t * (2 - t);
				u = 1 - t;
				
				button.x = t * buttonXTo + u * buttonXFrom;
				chat.x = t * chatXTo + u * chatXFrom;
			}
			
			var chat:Chat = new Chat(_client);
			chat.x = 465;
			chat.y = 20;
			addChild(chat);
			chat.setSize(288, 465 - 20);
			
			addChild(button);
			button.setSize(288, 20);
		}
		
		private function js_xi_get_code():String
		{
			return encodeURIComponent(_code);
		}
	}
}