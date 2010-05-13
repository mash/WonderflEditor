package net.wonderfl.editor.coloring 
{
	import flash.text.TextField;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class TextColoringTask
	{
		private var _formatRuns:Array = null;
		private var _task:Array = [];
		
		public function TextColoringTask() 
		{
			
		}
		
		public function setTextRuns($runs:Array):void {
			$runs ||= [];
			_task.length = 0;
			
			trace('formatRuns ', _formatRuns ? _formatRuns.length : 'null');
			
			var initRun:Boolean = (_formatRuns == null);
			_formatRuns ||= [];
			var run:Object;
			var runSlice:Object;
			var prevLen:int = _formatRuns.length;
			var j:int = 0;
			var len:int = $runs.length;
			var taskLength:int = 0;
			var found:Boolean;
			
			for (var i:int = 0; i < prevLen; ++i) 
			{
				runSlice = _formatRuns[i];
				runSlice.exist = false;
			}
			
			var t:int = getTimer();
			for (i = 0; i < len; ++i) 
			{
				run = $runs[i];
				found = false;
				while (j < prevLen) {
					runSlice = _formatRuns[j];
					
					if (runSlice.begin < run.begin) {
						++j;
						continue;
					} else if (runSlice.begin == run.begin) {
						found = (runSlice.end == run.end && runSlice.color == run.color);
						_formatRuns[j].exist = true;
						break;
					} else {
						found = false;
						_formatRuns[j].exist = true;
						break;
					}
				}
				
				if (!found) {
					_task[taskLength++] = run;
				}
			}
			
			if (_formatRuns.length == 0) {
				_formatRuns = $runs.slice();
			} else {
				trace('before filtering : ', _formatRuns.length);
				_formatRuns = _formatRuns.filter(function ($item:*, $index:int, $array:Array):Boolean {
					return $item.exist;
				});
			}
			
			
			trace('calc diff ', getTimer() - t, ' ms');
			
			trace('new Task Length:', _task.length, ' formatRun length ', _formatRuns.length);
		}
		
		public function getTask():Array {
			return _task.slice();
		}
		
	}

}