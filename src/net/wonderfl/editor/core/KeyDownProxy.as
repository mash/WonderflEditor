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
		private var _keyDownTimeout:uint;
		private var _keyDownHandler:Function;
		private var _keyEventDispatchers:Object = {};
		private var _target:InteractiveObject;
		private var _watchKeys:Array;
		
		public function KeyDownProxy($target:InteractiveObject, $keyDownHandler:Function, $watchKeys:Array) {
			_watchKeys = $watchKeys;
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
			if (_watchKeys.indexOf(e.keyCode) > -1) {
				if (_keyEventDispatchers[e.keyCode] == null) {
					clearTimeout(_keyDownTimeout);
					var keyWatcher:Function = bind(e);
					_keyEventDispatchers[e.keyCode] = keyWatcher;
					_keyDownTimeout = setTimeout(
						function ():void {
								_engine.addEventListener(Event.ENTER_FRAME, keyWatcher);
						}, 120);
					_keyDownHandler(e);
				}
			} else {
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
			clearTimeout(_keyDownTimeout);
			var keyWatcher:Function = _keyEventDispatchers[e.keyCode];
			if (keyWatcher != null) {
				_engine.removeEventListener(Event.ENTER_FRAME, keyWatcher);
				_keyEventDispatchers[e.keyCode] = null;
			}
		}
	}

}