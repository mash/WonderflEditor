package net.wonderfl.editor.scroll 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import net.wonderfl.editor.core.FTETextField;
	import net.wonderfl.editor.core.UIComponent;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class TextVScroll extends TextScrollBar
	{
		private static const MINIMUM_THUMB_HEIGHT:int = 15;
		private var _scrollY:int = -1;
		
		private var _trackHeight:int;
		private var _prevMouseY:int;
			
		public function TextVScroll($target:FTETextField) 
		{
			super($target);
			_handle.width = _width = MINIMUM_THUMB_HEIGHT;
		}
		
		override protected function onDrag(e:MouseEvent):void 
		{
			_prevMouse = NaN;
			_diff = _handle.y - mouseY;
		}
		
		override protected function onTrackMouseUp(e:MouseEvent):void 
		{
			updateHandlePos(mouseY);
		}
		
		override protected function checkMouse(e:Event):void 
		{
			if (mouseY != _prevMouse) {
				updateHandlePos(_prevMouse = mouseY);
			}
		}
		
		private function updateHandlePos($pos:Number):void {
			_handle.y = truncateHandlePos($pos + _diff);
			calcValueFromHandlePos(_handle.y);
		}
		
		override public function setSliderParams($min:int, $max:int, $value:int):void 
		{
			var oldValue:int = _value;
			super.setSliderParams($min, $max, $value);
			
			_handle.y = ($value - $min) / ($max - $min) * _handleMax;
			
			//if (oldValue != $value) {
				dispatchEvent(new Event(Event.SCROLL));
			//}
		}
		
		override public function setThumbPercent($value:Number):void 
		{
			_handle.height = $value * _height;
			_handleMax = _height - _handle.height;
			_handle.visible = ($value < 1);
		}
		
		
		override public function set width(value:Number):void {}
		
		override protected function updateSize():void {
			graphics.clear();
			graphics.beginFill(0);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
			
			graphics.beginFill(0x111111);
			graphics.drawRect(0, 0, _width, _height - MINIMUM_THUMB_HEIGHT);
			graphics.endFill();
		}
	}
}

