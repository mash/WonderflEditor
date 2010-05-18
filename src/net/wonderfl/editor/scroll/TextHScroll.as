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
			_height = MINIMUM_THUMB_WIDTH;
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
			
			if (oldValue != $value) {
				dispatchEvent(new Event(Event.SCROLL));
			}
		}
		
		override public function setThumbPercent($value:Number):void 
		{
			_handle.width = $value * (_width - MINIMUM_THUMB_WIDTH);
			_handleMax = _width - _handle.width - MINIMUM_THUMB_WIDTH;
			_handle.visible = ($value < 1);
		}
		
		private function onScroll(e:Event):void 
		{
			//_handle.width = _width * _target.visibleColumns / (_target.width / boxWidth);
			//_trackWidth = _width - _handle.width;
		}
		
		override public function set height(value:Number):void  { }
		
		
		protected function onDrop(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onDrop);
			stage.removeEventListener(Event.ENTER_FRAME, checkMouse);
			_handle.stopDrag();
		}
		
		override protected function updateSize():void {
			graphics.clear();
			graphics.beginFill(0);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
			
			graphics.beginFill(0x111111);
			graphics.drawRect(0, 0, _width - MINIMUM_THUMB_WIDTH, _height);
			graphics.endFill();
		}
	}
}

