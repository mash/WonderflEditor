package net.wonderfl.editor.core 
{
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class KeyDownProxy
	{
		private static var _engine:Sprite = new Sprite;
		private var _downKey:int = -1;
		private var _keyDownTimeout:uint;
		private var _keyDownHandler:Function;
		private var _keyWatcher:Function;
		private var _target:InteractiveObject;
		
		public function KeyDownProxy($target:InteractiveObject, $keyDownHandler:Function) {
			addProxy($target, $keyDownHandler);
		}
		
		public function addProxy($target:InteractiveObject, $keyDownHandler:Function):void {
			_target = $target;
			_keyDownHandler = $keyDownHandler;
			
			_target.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_target.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		public function removeProxy():void {
			_target.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_target.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode != _downKey) {
				clearTimeout(_keyDownTimeout);
				_downKey = e.keyCode;
				_keyWatcher = bind(e);
				_keyDownTimeout = setTimeout(
					function ():void {
							_engine.addEventListener(Event.ENTER_FRAME, _keyWatcher);
					}, 100);
				_keyDownHandler(e);
			}
		}
		
		private function bind($event:KeyboardEvent):Function
		{
			return function (e:Event):void {
				_keyDownHandler($event);
			};
		}
		
		private function onKeyUp(e:KeyboardEvent):void 
		{
			_downKey = -1;
			clearTimeout(_keyDownTimeout);
			_engine.removeEventListener(Event.ENTER_FRAME, _keyWatcher);
		}
	}

}