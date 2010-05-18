package net.wonderfl.editor.core 
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class UIComponent extends Sprite
	{
		protected var _width:int = 100;
		protected var _height:int = 100;
		
		public function UIComponent() 
		{
		}
		
		override public function get width():Number { return _width; }
		
		override public function set width(value:Number):void 
		{
			var w:int = value >> 0;
			if (w != _width) {
				_width = w;
				updateSize();
			}
		}
		
		override public function get height():Number { return _height; }
		
		override public function set height(value:Number):void 
		{
			var h:int = value >> 0;
			if (h != _height) {
				_height = h;
				updateSize();
			}
		}
		
		public function setSize($width:Number, $height:Number):void {
			_width = $width >> 0;
			_height = $height >> 0;
			updateSize();
		}
		
		protected function updateSize():void { }
	}
}