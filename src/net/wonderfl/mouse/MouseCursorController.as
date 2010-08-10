package net.wonderfl.mouse 
{
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class MouseCursorController
	{
		private static var _currentCursor:String = "arrow";
		private static var _eventHandlers:Object = { };
		public static function resetMouseCursor(e:MouseEvent = null):void {
			Mouse.cursor = _currentCursor;
		}
		public static function getOverStateHandler($mouseCursor:String):Function {
			var handler:Function = _eventHandlers[$mouseCursor];
			
			if (handler == null) {
				handler = _eventHandlers[$mouseCursor] = function (e:MouseEvent = null):void {
					if (e) e.stopPropagation();
					_currentCursor = Mouse.cursor;
					Mouse.cursor = $mouseCursor;
				};
			}
			
			return handler;
		}
		
		public static function setOverState($target:InteractiveObject, $mouseCursor:String):void {
			$target.addEventListener(MouseEvent.MOUSE_OVER, getOverStateHandler($mouseCursor));
			$target.addEventListener(MouseEvent.MOUSE_OUT, resetMouseCursor);
		}
	}

}