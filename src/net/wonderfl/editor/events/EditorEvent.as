package net.wonderfl.editor.events 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class EditorEvent extends Event
	{
		public static const REDO:String = "redo";
		public static const UNDO:String = "undo";
		
		public function EditorEvent($type:String) 
		{
			super($type);
		}
		
	}

}