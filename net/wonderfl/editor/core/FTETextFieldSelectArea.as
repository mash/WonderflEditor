package net.wonderfl.editor.core 
{
	import flash.display.Shape;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class FTETextFieldSelectArea extends Shape
	{
		private static const SELECTION_COLOR:uint = 0x663333;
		public var scrollY:int;
		private var _maxWidth:int;
		private var _boxHeight:int;
		private var _startPoint:Point = new Point(NaN);
		private var _endPoint:Point = new Point(NaN);
		private var _startXpos:int;
		private var _endXPos:int;
		
		public function FTETextFieldSelectArea() 
		{
			
		}
		
		public function clear():void {
			graphics.clear();
		}
		
		public function drawSelection($startPoint:Point, $endPoint:Point):void {
			
		}
		
		public function scrollSelection($diff:int):void {
			graphics.clear();
			
		}
		
		public function set maxWidth(value:int):void 
		{
			_maxWidth = value;
		}
		
		public function set boxHeight(value:int):void 
		{
			_boxHeight = value;
		}
		
	}

}