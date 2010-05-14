package net.wonderfl.editor.core 
{
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class Job
	{
		private var _currentSlice:Function;
		private var _slices:Array = [];
		private static var _id:int = 0;
		public var id:int;
		public var timestamp:int;
		
		public function Job($slices:Array) {
			_slices = $slices;
			id = _id++;
			timestamp = getTimer();
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
			
			if (!_currentSlice()) {
				_currentSlice = null;
			}
			
			return true;
		}
	}
}