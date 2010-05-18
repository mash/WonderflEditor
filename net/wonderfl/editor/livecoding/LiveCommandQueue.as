package net.wonderfl.editor.livecoding 
{
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class LiveCommandQueue
	{
		private var _queue:Array = [];
		public function get length():int { return _queue.length; }
		public function set length(value:int):void { _queue.length = value; }
		public function get next():LiveCommand { return _queue.shift(); }
		public function pushCommand($command:LiveCommand):void {
			_queue.push($command);
		}
	}

}