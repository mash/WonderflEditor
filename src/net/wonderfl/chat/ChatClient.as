package net.wonderfl.chat 
{
	import com.adobe.serialization.json.JSON;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import net.wonderfl.editor.livecoding.LiveCodingEvent;
	import net.wonderfl.editor.livecoding.SocketBroadCaster;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	[Event(name = 'LiveCodingEvent_JOINED', type = 'net.wonderfl.editor.livecoding.LiveCodingEvent')]
	[Event(name = 'LiveCodingEvent_CHAT_RECEIVED', type = 'net.wonderfl.editor.livecoding.LiveCodingEvent')]
	public class ChatClient extends EventDispatcher
	{
        private var broadcaster:SocketBroadCaster;
		private var _userName:String;
		private var _iconURL:String;
		
		public function init($initObject:Object):void {
			_userName = $initObject["viewer.displayName"];
			_iconURL = $initObject["viewer.iconURL"];
			
			broadcaster = new SocketBroadCaster;
			broadcaster.addEventListener(LiveCodingEvent.CHAT_RECEIVED, dispatchEvent);
			broadcaster.addEventListener(LiveCodingEvent.JOINED, dispatchEvent);
		}
		
		public function chat($message:String):void {
			broadcaster.chat($message);
		}
	}

}