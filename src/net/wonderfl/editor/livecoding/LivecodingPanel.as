package net.wonderfl.editor.livecoding 
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBaseline;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import net.wonderfl.chat.Chat;
	import net.wonderfl.chat.ChatButton;
	import net.wonderfl.component.core.UIComponent;
	import net.wonderfl.editor.font.FontSetting;
	import net.wonderfl.editor.livecoding.LiveCodingEvent;
	import net.wonderfl.utils.listenOnce;
	import net.wonderfl.utils.removeFromParent;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class LiveCodingPanel extends UIComponent
	{
		protected static const CHAT_BUTTON_MIN_WIDTH:int = 80;
		protected var _socket:SocketBroadCaster;
		protected var _host:String;
		protected var _port:int;
		protected var _isLive:Boolean = false;
		protected var _label:TextLine;
		protected var _chatButton:ChatButton;
		protected var _chat:Chat;
		private var _elapsed_time:int;
		private var _factory:TextBlock;
		private var _elf:ElementFormat;
		private var _strTime:String = '--:--';
		private var _strViewer:String = '-';
		private var _time:int;
		private var _timer:Timer;
		private var _updateParent:Function;
		private var _onStart:Function;
		private var _jumpToReadPage:Function;
		
		public function setUpdateParent($updateParent:Function):void {
			_updateParent = $updateParent;
		}
		
		public function init($chatWindowOpen:Boolean = false):void {
			trace("LiveCodingPanel.init > $chatWindowOpen : " + $chatWindowOpen);
			if (_updateParent == null) throw new Error('call setUpdateParent first!');
			if (!root) throw new Error('add this compoent to the stage first. then, call this method!');
			
			var params:Object = root.loaderInfo.parameters;
			_host = params.server;
			_port = parseInt(params.port);
			
			_timer = new Timer(100);
			_timer.addEventListener(TimerEvent.TIMER, timer);
			
			_factory = new TextBlock;
			_elf = new ElementFormat(new FontDescription(FontSetting.GOTHIC_FONT), 10);
			_elf.color = 0xffffff;
			_elf.alignmentBaseline = TextBaseline.IDEOGRAPHIC_BOTTOM;
			
			_socket = new SocketBroadCaster;
			_socket.addEventListener(LiveCodingEvent.JOINED, joined);
			_socket.addEventListener(LiveCodingEvent.MEMBERS_UPDATED, membersUpdated);
			_socket.addEventListener(LiveCodingEvent.CHAT_RECEIVED, chatReceived);
			listenOnce(_socket, Event.CONNECT, _socket.join, [params.ticket]);
			_socket.addEventListener(Event.CONNECT, trace);
			
			_chatButton = new ChatButton;
			var duration:int = 300;
			var startTime:int;
			var tweening:Boolean = false;
			var buttonXTo:int, buttonXFrom:int, chatXTo:int, chatXFrom:int;
			const LEFT:uint = _width - 288;
			
			_chatButton.addEventListener(MouseEvent.CLICK, click);
			
			_chat = new Chat(_socket);
			_chat.y = 20;
			_chatButton.setSize(288, 20);
			_chatButton.x = LEFT;
			
			_height = 20;
			_chat.x = _width;
			_chatButton.x = _width - CHAT_BUTTON_MIN_WIDTH;
			if ($chatWindowOpen) {
				_chatButton.toggle();
				_onStart = function ():void {
					tweening = true;
					_chat.x = _width;
					_chatButton.x = _width - CHAT_BUTTON_MIN_WIDTH;
					buttonXTo = chatXTo = _width - 288;
					buttonXFrom = _width - CHAT_BUTTON_MIN_WIDTH;
					chatXFrom = _width;
					trace('onStart : ', _chatButton.x, _chat.x);
					startTime = getTimer();
					addEventListener(Event.ENTER_FRAME, tweener);
				};
			} else {
				_jumpToReadPage = function ():void {
					var href:String = ExternalInterface.call('function(){return location.href;}');
					href = href.replace(/\/$/, '');
					navigateToURL(new URLRequest(href + '/read'), '_self');
				}
			}
			
			function click(e:MouseEvent):void {
				if (tweening) return;
				if (_jumpToReadPage != null) {
					_jumpToReadPage();
					return;
				}
				
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
					dispatchEvent(new LiveCodingPanelEvent(LiveCodingPanelEvent.CHAT_WINDOW_CLOSE));
					
					updateSize();
				}
				
				startTime = getTimer();
				addEventListener(Event.ENTER_FRAME, tweener);
			}
			
			function tweener(e:Event):void {
				var time:int = getTimer() - startTime;
				
				if (time > duration) {
					_chatButton.x = buttonXTo; _chat.x = chatXTo;
					removeEventListener(Event.ENTER_FRAME, tweener);
					tweening = false;
					trace('tween end : ', _chatButton.x, _chat.x);
					dispatchEvent(new LiveCodingPanelEvent(LiveCodingPanelEvent.CHAT_WINDOW_OPEN));
					
					updateSize();
					return;
				}
				
				var t:Number = time / duration;
				var u:Number;
				t = t * (2 - t);
				u = 1 - t;
				
				_chatButton.x = t * buttonXTo + u * buttonXFrom;
				_chat.x = t * chatXTo + u * chatXFrom;
				trace(_chat.x, _chatButton.x, chatXFrom, chatXTo);
			}
		}
		
		private function chatReceived(e:LiveCodingEvent):void 
		{
			if (!_chatButton.isOpen()) _chatButton.increaseNumMessages();
		}
		
		public function getChatLeftPos():int {
			//return _chat.parent ? _chat.x : _width;
			return _chat.x;
		}
		
		public function isChatWindowOpen():Boolean {
			return _chatButton.isOpen();
		}
		
		private function membersUpdated($event:LiveCodingEvent):void 
		{
			updateView(_strTime, $event.data.count);
		}
		
		
		private function calcTimeString($time:int):String
		{
			var result:Array = [];
			var i:int = 0;
			while (i++ < 2 || $time > 0) {
				result.unshift(fillString($time % 60));
				$time /= 60;
			} 
			
			return result.join(':');
		}
		
		private function fillString($n:int):String {
			return ($n < 10) ? '0' + $n : '' + $n;
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
		
		private function timer(e:TimerEvent):void {
			updateView(calcTimeString(_elapsed_time + (getTimer() - _time) / 1000), _strViewer);
		}
		
		private function memberUpdate($event:LiveCodingEvent):void {
			updateView(_strTime, $event.data.count);
		}
		
		protected function joined(e:LiveCodingEvent):void 
		{
			trace("LiveCodingPanel.joined > e : " + e);
			_elapsed_time = e.data ? e.data.elapsed_time : 0;
			
			start();
		}
		
		protected function chat($message:String):void {
			_socket.chat($message);
		}
		
		public function connect():void {
			_socket.connect(_host, _port);
		}
		
		public function start():void {
			if (_onStart != null) {
				_onStart();
				_onStart = null;
			}
			
			_time = getTimer();
			timer(null);
			_timer.start();
			_isLive = true;
			addChild(_chat);
			addChild(_chatButton);
		}
		
		public function stop():void {
			_timer.stop();
			_isLive = false;
		}
		
		override protected function updateSize():void 
		{
			trace("LiveCodingPanel.updateSize");
			_chat.setSize(288, parent.height - 20);
			if (_chatButton.isOpen()) {
				_chat.x = _width - _chatButton.width;
				_chatButton.x = _width - _chatButton.width;
			} else {
				_chat.x = _width;
				_chatButton.x = _width - CHAT_BUTTON_MIN_WIDTH;
			}
			
			graphics.clear();
			graphics.beginFill(0);
			graphics.drawRect(0, 0, _width, _height);
		}
		
		public function isLive():Boolean { return _isLive; }
	}

}