package net.wonderfl.chat 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBaseline;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.utils.getTimer;
	import net.wonderfl.component.core.UIComponent;
	import net.wonderfl.editor.font.FontSetting;
	import net.wonderfl.utils.listenOnce;
	
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ChatComponent extends UIComponent
	{
		private const CHAT_BUTTON_MIN_WIDTH:int = 80;
		private var _chatButton:ChatButton;
		private var _factory:TextBlock;
		private var _elf:ElementFormat;
		private var _label:TextLine;
		private var _strTime:String = '--:--';
		private var _strViewer:String = '-';
		private var _leftOfTimeLabel:int = 100;
		
		public function ChatComponent() 
		{
			listenOnce(this, Event.ADDED_TO_STAGE, init);
		}
		
		private function init():void
		{
			_factory = new TextBlock;
			_elf = new ElementFormat(new FontDescription(FontSetting.GOTHIC_FONT), 10);
			_elf.color = 0xffffff;
			_elf.alignmentBaseline = TextBaseline.IDEOGRAPHIC_BOTTOM;
			
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
			
		}
		
		override protected function updateSize():void 
		{
			if (_chatButton.isOpen()) {
				_chat.x = _width - 288;
				_chatButton.x = _width -288;
			} else {
				_chatButton.x = _width - CHAT_BUTTON_MIN_WIDTH;
				_chat.x = _width;
			}
			_chat.setSize(288, _height - 20);
		}
		
		public function set leftOfTimeLabel(value:int):void 
		{
			_leftOfTimeLabel = value;
		}
		
	}

}