package net.wonderfl.editor.livecoding 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.getTimer;
	import net.wonderfl.editor.ITextArea;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class LiveCodingBroadcaster implements ILiveEditor
	{
		private var _onJoin:Function;
		private var _onMemberUpdate:Function;
		private static const TICK:int = 6;
		private var _queue:LiveCommandQueue = new LiveCommandQueue;
		private var _executer:Sprite = new Sprite;
		private var _isReady:Boolean;
		private var _broadcaster:SocketBroadCaster = new SocketBroadCaster;
		private var _commandCount:int;
		private var _editor:ITextArea;
				
		public function LiveCodingBroadcaster() 
		{
			_broadcaster.addEventListener(Event.CONNECT, function ():void {
				_broadcaster.join( LiveCodingSettings.room, LiveCodingSettings.ticket);
			});
			_broadcaster.addEventListener(LiveCodingEvent.JOINED, startBroadCasting);
			_broadcaster.addEventListener(LiveCodingEvent.MEMBERS_UPDATED, __onMemberUpdate);
			_broadcaster.addEventListener(IOErrorEvent.IO_ERROR, new Function);
		}
		
		public function startLiveCoding():void {
			_isReady = false;
			_broadcaster.connect(LiveCodingSettings.server, LiveCodingSettings.port);
			_queue.length = 0;
			_executer.addEventListener(Event.ENTER_FRAME, execute);
		}
		
		public function endLiveCoding():void {
			closeLiveCoding();
			flush();
			_broadcaster.close();
			_executer.removeEventListener(Event.ENTER_FRAME, execute);
		}
		
		private function flush():void
		{
			while (_queue.length > 0) {
				var command:LiveCommand = _queue.next;
				_broadcaster.send.apply(null, command.arguments);
			}
		}
		
		private function startBroadCasting(e:LiveCodingEvent):void 
		{
			_isReady = true;
				
			if (_onJoin != null) _onJoin();
		}
		
		private function __onMemberUpdate(e:LiveCodingEvent):void 
		{
			if (_onMemberUpdate != null)
				_onMemberUpdate(e);
				
			sendCurrentText();
		}
		
		private function execute(e:Event):void 
		{
			if (!_isReady) return;
			
			if (_queue.length) {
				var t:int = getTimer();
				var command:LiveCommand;
				
				while ( t - getTimer() < TICK) {
					if (_queue.length == 0) break;
					
					command = _queue.next;
					_broadcaster.send.apply(null, command.arguments);
				}
			}
		}
		
		public function setSelection($selectionBeginIndex:int, $selectionEndIndex:int):void
		{
			_queue.pushCommand(new LiveCommand(LiveCoding.SET_SELECTION, $selectionBeginIndex, $selectionEndIndex));
			checkCount();
		}
		
		public function replaceText($beginIndex:int, $endIndex:int, $newText:String):void
		{
			_queue.pushCommand(new LiveCommand(LiveCoding.REPLACE_TEXT, $beginIndex, $endIndex, $newText));
			checkCount();
		}
		
		public function sendCurrentText():void
		{
			_queue.pushCommand(new LiveCommand(LiveCoding.SEND_CURRENT_TEXT, _editor.text));
			_commandCount = 1;
		}
		
		private function checkCount():void {
			if (++_commandCount == 99) sendCurrentText();
		}
		
		public function closeLiveCoding():void
		{
			_queue.pushCommand(new LiveCommand(LiveCoding.CLOSED));
		}
		
		public function onSWFReloaded():void
		{
			_queue.pushCommand(new LiveCommand(LiveCoding.SWF_RELOADED));
		}
		
		public function setScrollV($scrollV:int):void
		{
			_queue.pushCommand(new LiveCommand(LiveCoding.SCROLL_V, $scrollV));
		}
		
		public function setScrollH($scrollH:int):void
		{
			_queue.pushCommand(new LiveCommand(LiveCoding.SCROLL_H, $scrollH));
		}
		
		public function set onJoin(value:Function):void 
		{
			_onJoin = value;
		}
		
		public function set onMemberUpdate(value:Function):void 
		{
			_onMemberUpdate = value;
		}
		
		public function get commandCount():int { return _commandCount; }
		
		public function set editor(value:ITextArea):void 
		{
			_editor = value;
		}
		
	}

}