package net.wonderfl.editor.coloring 
{
	import ro.victordramba.thread.IThread;
	
	/**
	 * @author kobayashi-taro
	 */
	public class TextColoringThread implements IThread
	{
		private var _formats:Format;
		
		public function TextColoringThread() 
		{
			
		}
		
		/* INTERFACE ro.victordramba.thread.IThread */
		
		public function runSlice():Boolean
		{
			return false;
		}
		
		public function kill():void
		{
			
		}
	}
}

class Format {
	public var next:Format;
	public var prev:Format;
	
}