package net.wonderfl.editor.livecoding 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class LiveCodingPanelEvent extends Event
	{
		public static const CHAT_WINDOW_OPEN:String = 'chatWindowOpen';
		public static const CHAT_WINDOW_CLOSE:String = 'chatWindowClose';
		
		public function LiveCodingPanelEvent($type:String) 
		{
			super($type);
		}
		
	}

}