package net.wonderfl.thread 
{
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ThreadTask
	{
		private var _currentSlice:Function;
		private var _slices:Array = [];
		private var _jobKiller:Function;
		private static var _id:int = 0;
		public var id:int;
		
		
		public function ThreadTask($slices:Array, $jobKiller:Function) {
			_slices = $slices;
			id = _id++;
		}
		
		
		public function kill():void {
			if (_jobKiller != null)
				_jobKiller();
				
			_slices.length = 0;
			_currentSlice = null;
		}
		/**
		 * @return false : this job end
		 *         true  : this job is not complete yet
		 */
		public function runSlice():Boolean {
			if (_currentSlice == null) {
				if (_slices.length == 0)
					return false;
					
				_currentSlice = _slices.shift();
			}
			
			var hasNext:Boolean = _currentSlice();
			if (!hasNext) {
				_currentSlice = null;
			}
			
			return hasNext || _slices.length;
		}
	}
}