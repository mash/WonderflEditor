package net.wonderfl.editor.scroll 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.wonderfl.editor.core.FTETextField;
	import net.wonderfl.editor.utils.calcFontBox;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class TextHScroll extends TextScrollBar
	{
		private static const MINIMUM_THUMB_WIDTH:int = 15;
		private var boxWidth:int;
		
		public function TextHScroll($target:FTETextField) 
		{
			super($target);
			boxWidth = calcFontBox($target.defaultTextFormat).width;
			_handle.height = _height = MINIMUM_THUMB_WIDTH;
		}
		
		override protected function onDrag(e:MouseEvent):void 
		{
			_prevMouse = NaN;
			_diff = _handle.x - mouseX;
		}
		
		override protected function onTrackMouseUp(e:MouseEvent):void 
		{
			updateHandlePos(mouseX);
		}
		
		override protected function checkMouse(e:Event):void 
		{
			if (mouseX != _prevMouse) {
				updateHandlePos(_prevMouse = mouseX);
			}
		}
		
		private function updateHandlePos($pos:Number):void {
			_handle.x = truncateHandlePos($pos + _diff);
			calcValueFromHandlePos(_handle.x);
		}
		
		override public function setSliderParams($min:int, $max:int, $value:int):void 
		{
			var oldValue:int = _value;
			super.setSliderParams($min, $max, $value);
			
			_handle.x = ($value - $min) / ($max - $min) * _handleMax;
		}
		
		override public function setThumbPercent($value:Number):void 
		{
			var w:int = $value * _width;
			w = (w < MINIMUM_THUMB_WIDTH) ? MINIMUM_THUMB_WIDTH : w;
			_handle.width = w;
			_handleMax = _width - _handle.width - MINIMUM_THUMB_WIDTH;
			_handle.visible = ($value < 1);
		}
		
		override public function set height(value:Number):void  { }
		
		override protected function updateSize():void {
			graphics.clear();
			graphics.beginFill(0);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
			
			graphics.beginFill(0x111111);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}
	}
}

