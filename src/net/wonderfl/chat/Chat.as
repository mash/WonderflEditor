package net.wonderfl.chat 
{
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import net.wonderfl.component.core.UIComponent;
	import net.wonderfl.editor.livecoding.LiveCodingEvent;
	import net.wonderfl.editor.livecoding.SocketBroadCaster;
	import net.wonderfl.utils.listenOnce;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class Chat extends UIComponent
	{
		private static const MARGIN:int = 20;
		private var _area:ChatArea;
		private var _resizeButton:ChatResizeButton;
		private var _input:ChatInput;
		private var _client:SocketBroadCaster;
		private var _sp:Sprite;
		private var _diffY:int;
		private var _joinedAt:Number;
		private var _localJoinedAt:Number;
		
		public function Chat($client:SocketBroadCaster) 
		{
			_client = $client;
			_client.addEventListener(LiveCodingEvent.JOINED, function joined(e:LiveCodingEvent):void {
				_client.removeEventListener(LiveCodingEvent.JOINED, joined);
				_joinedAt = Number(e.data.now);
				_localJoinedAt = (new Date).getTime();
			});
			$client.addEventListener(LiveCodingEvent.CHAT_RECEIVED, chatReceived);
			
			listenOnce(this, Event.ADDED_TO_STAGE, init);
		}
		
		private function init():void
		{
			_area = new ChatArea;
			addChild(_area);
			addChild(_sp = new Sprite);
			_input = new ChatInput(onClick);
			addChild(_input);	
			addChild(_resizeButton = new ChatResizeButton);
			
			_resizeButton.y = 50;
			_resizeButton.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			
			updateSize();
		}
		
		public function open():void {
			
		}
		
		public function close():void {
			
		}
		
		private function mouseDown(e:MouseEvent):void 
		{
			_diffY = _resizeButton.y - mouseY;
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			addEventListener(Event.ENTER_FRAME, watchMouse);
		}
		
		private function mouseUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			removeEventListener(Event.ENTER_FRAME, watchMouse);
		}
		
		private function watchMouse(e:Event):void 
		{
			var yPos:int = mouseY + _diffY;
			_resizeButton.y = Math.max(yPos, ChatInput.MINIMUM_HEIGHT);
			updateSize();
		}
		
		private function onClick(e:MouseEvent):void {
			if (_input.text) {
				var message:String = _input.text.replace(/\t/g, "    ").replace(/\r/g, "\n");
				_client.chat(message);
			}
			_input.text = "";
		}
		
		override protected function updateSize():void 
		{
			var h:int = _resizeButton.y;
			
			_input.setSize(_width, h);
			
			h += 20;
			
			_sp.graphics.clear();
			_sp.graphics.beginFill(ChatStyle.CHAT_BACKGROUND, ChatStyle.CHAT_BACKGROUND_ALPHA);
			_sp.graphics.drawRect(0, 0, _width, h);
			_sp.graphics.endFill();
			
			_resizeButton.setSize(_width, 20);
			
			_area.y = h;
			_area.setSize(_width, _height - h);
		}
		
		
		private function chatReceived(e:LiveCodingEvent):void {
			if (_area) {
				_area.appendItem(new ChatMessage(e.data, _joinedAt, _localJoinedAt));
				_area.scrollV = 1;
			}
		}
	}

}