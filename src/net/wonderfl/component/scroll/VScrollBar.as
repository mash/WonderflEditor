package net.wonderfl.component.scroll 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class VScrollBar extends ScrollBar
	{
		override protected function onDrag():void 
		{
			_prevMouse = NaN;
			_mouseDiff = _handle.y - mouseY;
		}
		
		override protected function checkMouse(e:Event):void 
		{
			var my:int = mouseY;
			if (my != _prevMouse) {
				_prevMouse = my;
				truncateHandlePos(my + _mouseDiff);
				calcValueFromHandlePos();
				updateHandlePos();
				dispatchScrollEvent();
			}
		}
		
		override protected function barClicked():void 
		{
			truncateHandlePos(mouseY);
		}
		
		override public function updateHandlePos():void 
		{
			_handle.y = _handlePos;
		}
		
		override public function drawHandle():void 
		{
			calcHandleSize();
			_handle.setSize(_width, _handleSize);
			_handleMax = _height - _handleSize;
		}
		
		override protected function updateSize():void 
		{
			trace("VScrollBar.updateSize : " + _height);
			graphics.clear();
			graphics.beginFill(0x111111);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
			super.updateSize();
		}
	}

}