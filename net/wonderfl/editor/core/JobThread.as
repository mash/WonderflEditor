package net.wonderfl.editor.core 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class JobThread
	{
		private static var _engine:Sprite = new Sprite;
		private static var _que:Array = [];
		private static var _cancelFlag:Boolean = false;
		private static var _running:Boolean = false;
		private static var _currentJob:Function = null;
		
		public static function abort():void {
			terminate();
		}
		
		public static function addJob($job:Function):void {
			_que.push($job);
			
			trace('job added : ' + _que.length);
		}
		
		public static function run():void {
			_running = true;
			
			if (!_engine.hasEventListener(Event.ENTER_FRAME))
				_engine.addEventListener(Event.ENTER_FRAME, executer);
		}
		
		static public function get running():Boolean { return _running; }
		
		private static function executer(e:Event):void {
			if (_cancelFlag) {
				terminate();
				return;
			}
			
			var tick:int = getTimer();
			
			while (getTimer() - tick < 33) {
				if (_currentJob == null) {
					if (_que.length == 0) {
						terminate();
						return;
					}
					
					_currentJob = _que.shift();
					trace(_que.length + ' jobs left');
				}
				
				if (!_currentJob()) {
					_currentJob = null;
				}
			}
		}
		
		
		private static function terminate():void {
			trace('job complete');
			_engine.removeEventListener(Event.ENTER_FRAME, executer);
			_currentJob = null;
			_que.length = 0;
			_running = false;
			_cancelFlag = false;
		}
	}

}