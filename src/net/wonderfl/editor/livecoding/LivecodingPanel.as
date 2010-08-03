package net.wonderfl.editor.livecoding 
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.utils.getTimer;
	import net.wonderfl.chat.Chat;
	import net.wonderfl.chat.ChatButton;
	import net.wonderfl.component.core.UIComponent;
	import net.wonderfl.editor.livecoding.LiveCodingEvent;
	import net.wonderfl.utils.listenOnce;
	import net.wonderfl.utils.removeFromParent;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class LivecodingPanel extends UIComponent
	{
		protected static const CHAT_BUTTON_MIN_WIDTH:int = 80;
		protected var _socket:SocketBroadCaster;
		protected var _host:String;
		protected var _port:int;
		protected var _isLive:Boolean = false;
		private var _chatButton:ChatButton;
		private var _chat:Chat;
		private var _elapsed_time:int;
		private var _factory:TextBlock;
		private var _elf:ElementFormat;
		private var _label:TextLine;
		private var _strTime:String = '--:--';
		private var _strViewer:String = '-';
		
		public function init():void {
			if (!root) throw new Error('add this compoent to the stage first. then, call this method!');
			
			var params:Object = root.loaderInfo.parameters;
			_host = params.server;
			_port = parseInt(params.port);
			
			_socket = new SocketBroadCaster;
			listenOnce(_socket, Event.CONNECT, _socket.join, [params.root, params.ticket]);
			_socket.addEventListener(LiveCodingEvent.CHAT_RECEIVED, chatRecieved);
			_socket.addEventListener(LiveCodingEvent.JOINED, joined);
			_socket.addEventListener(LiveCodingEvent.MEMBERS_UPDATED, membersUpdated);
			
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
					
					updateSize();
					return;
				}
				
				var t:Number = time / duration;
				var u:Number;
				t = t * (2 - t);
				u = 1 - t;
				
				_chatButton.x = t * buttonXTo + u * buttonXFrom;
				_chat.x = t * chatXTo + u * chatXFrom;
			}
			
			_chat = new Chat(_socket);
			_chat.x = _width - 288;
			_chat.y = 20;
			addChild(_chat);
			
			addChild(_chatButton);
			_chatButton.setSize(288, 20);
		}
		
		private function membersUpdated(e:LiveCodingEvent):void 
		{
			
		}
		
		private function updateView($time:String, $viewer:String):void {
			if (_strTime == $time && _strViewer == $viewer) return;
			
			_strTime = $time;
			_strViewer = $viewer;
			removeFromParent(_label);
			_factory.content = new TextElement(
				<>Time: {$time}  Viewer: {$viewer}</>.toString(), _elf.clone()
			);
			_label = _factory.createTextLine();
			_label.y = _label.height + 2;
			_label.x = 115;
			addChild(_label);
		}
		
		private function onMemberUpdate($event:LiveCodingEvent):void {
			updateView(_strTime, $event.data.count);
		}
		
		protected function joined(e:LiveCodingEvent):void 
		{
			_elapsed_time = e.data ? e.data.elapsed_time : 0;
		}
		
		protected function chatRecieved(e:LiveCodingEvent):void 
		{
		}
		
		protected function chat($message:String):void {
			_socket.chat($message, _userName, _iconURL);
		}
		
		public function connect():void {
			_socket.connect(_host, _port);
		}
		
		protected function start():void {
			
		}
		
		protected function stop():void {
			
		}
		
		override protected function updateSize():void 
		{
			
		}
	}

}