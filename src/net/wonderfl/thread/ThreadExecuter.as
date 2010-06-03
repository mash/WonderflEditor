package net.wonderfl.thread 
{
	import flash.display.JointStyle;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ThreadExecuter
	{
		private static var _engine:Sprite = new Sprite;
		private static var _que:Array = [];
		private static var _running:Boolean = false;
		private static var _currentJob:ThreadTask = null;
		private static var _onComplete:Function;
		
		public static function addTask($killer:Function, ...$jobslices:Array):Class {
			_que.push(new ThreadTask($jobslices, $killer));
			Thread::debug { trace('job added : ' + _que.length); }
			
			return ThreadExecuter;
		}
		
		public static function getPendingTaks():Array {
			return _que.slice();
		}
		
		public static function killTask($id:int):void {
			_que = _que.filter(function ($item:ThreadTask, $index:int, $array:Array):Boolean {
				var result:Boolean = ($item.id != $id);
				
				if (!result) {
					$item.kill();
				}
				
				return result;
			});
		}
		public static function get length():int {
			return _que.length
		}
		
		public static function run():void {
			_running = true;
			
			if (!_engine.hasEventListener(Event.ENTER_FRAME))
				_engine.addEventListener(Event.ENTER_FRAME, executer);
		}
		
		static public function get running():Boolean { return _running; }
		
		static public function set onComplete(value:Function):void 
		{
			_onComplete = value;
		}
		
		private static function executer(e:Event):void {
			var tick:int = getTimer();
			
			while (getTimer() - tick < 25) {
				if (_currentJob == null) {
					if (_que.length == 0) {
						terminate();
						return;
					}
					
					_currentJob = _que.shift();
					Thread::debug { trace(_que.length + ' jobs left'); }
				}
				
				if (!_currentJob.runSlice()) {
					_currentJob = null;
				}
			}
		}
		
		
		private static function terminate():void {
			Thread::debug { trace('job complete'); }
			_engine.removeEventListener(Event.ENTER_FRAME, executer);
			_currentJob = null;
			_que.length = 0;
			_running = false;
			
			if (_onComplete != null)
				_onComplete();
		}
	}
}
