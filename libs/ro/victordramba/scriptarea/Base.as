package ro.victordramba.scriptarea
{
	import flash.display.Sprite;

	public class Base extends Sprite
	{
		public function Base()
		{
			super();
		}
		
		private var _width:int;
		private var _height:int;
		override public function set width(value:Number):void
		{
			if (value == _width) return;
			_width = value;
			updateSize()
		}
		override public function get width():Number
		{
			return _width;
		}
		override public function set height(value:Number):void
		{
			if (_height == value) return;
			_height = value;
			updateSize()
		}
		override public function get height():Number
		{
			return _height;
		}
		
		protected function updateSize():void
		{
			graphics.clear();
			graphics.beginFill(0, 1);
			//graphics.lineStyle(0);
			graphics.drawRect(-50, 0, _width+50, _height);
		}
	}
}