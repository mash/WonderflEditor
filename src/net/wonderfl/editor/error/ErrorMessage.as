package net.wonderfl.editor.error 
{
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ErrorMessage
	{
		private var _row:int;
		private var _column:int;
		private var _message:String;
		
		public function ErrorMessage($message:Array) {
			_row = $message[0];
			_column = $message[1];
			_message = $message[2];
		}
		
		public function get row():int { return _row - 1; }
		public function get column():int { return _column; }
		public function get message():String { return _message; }
	}
}