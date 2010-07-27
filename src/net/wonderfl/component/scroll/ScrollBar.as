package net.wonderfl.component.scroll 
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import net.wonderfl.component.core.UIComponent;
	import net.wonderfl.utils.bind;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	[Event(name = 'scroll', type = 'flash.events.Event')]
	public class ScrollBar extends UIComponent
	{
		protected var _handle:ScrollBarHandle;
		protected var _handleMax:int = 0;
		protected var _handlePos:int = 0;
		protected var _prevMouse:Number;
		protected var _mouseDiff:Number;
		protected var _handleMinimumSize:int = 12;
		protected var _handleSize:int;
		protected var _valueForMaxPos:Number = 1;
		protected var _valueForMinPos:Number = 0;
		protected var _valueForPageSize:Number = 0;
		protected var _value:Number = 0;
		
		public function ScrollBar() 
		{
			_height = _width = _handleMinimumSize;
			
			_handle = new ScrollBarHandle;
			_handle.addEventListener(MouseEvent.MOUSE_DOWN, _onDrag);
			addChild(_handle);
			
			addEventListener(MouseEvent.MOUSE_DOWN, _barClicked);
		}
		
		private function _onDrag(e:MouseEvent):void 
		{
			onDrag();
			stage.addEventListener(MouseEvent.MOUSE_UP, onDrop);
			stage.addEventListener(Event.ENTER_FRAME, checkMouse);
		}
		
		private function onDrop(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onDrop);
			stage.removeEventListener(Event.ENTER_FRAME, checkMouse);
		}
		
		
		private function setMouseCursor($cursor:String):void {
			Mouse.cursor = $cursor;
		}
		
		private function _barClicked(e:MouseEvent):void 
		{
			if (e.target != e.currentTarget) {
				e.stopPropagation();
				e.stopImmediatePropagation();
				return;
			}
			barClicked();
			calcValueFromHandlePos();
			updateHandlePos();
			dispatchScrollEvent();
		}
		
		protected function dispatchScrollEvent():void {
			dispatchEvent(new Event(Event.SCROLL));
		}
		
		protected function truncateHandlePos($value:Number):void {
			$value = ($value < 0) ? 0 : $value;
			$value = ($value > _handleMax) ? _handleMax : $value;
			_handlePos = $value;
		}
		
		protected function calcValueFromHandlePos():void {
			_value = _handlePos / _handleMax * (_valueForMaxPos - _valueForMinPos) + _valueForMinPos;
		}
		
		protected function calcHandleSize():void {
			trace("ScrollBar.calcHandleSize " + _valueForPageSize + " _valueForMaxPos " + _valueForMaxPos);
			
			_handleSize = _valueForPageSize / (_valueForPageSize + _valueForMaxPos - _valueForMinPos) * _height;
			_handleSize = (_handleSize < _handleMinimumSize) ? _handleMinimumSize : _handleSize;
		}
		
		override protected function updateSize():void 
		{
			drawHandle();
		}

		public function get value():Number { return _value; }
		public function get handleMinimumSize():int { return _handleMinimumSize; }
		public function set handleMinimumSize(value:int):void 
		{
			_handleMinimumSize = value;
		}
		
		public function set valueForMaxPos(value:Number):void 
		{
			_valueForMaxPos = value;
			drawHandle();
		}
		
		public function set valueForMinPos(value:Number):void 
		{
			_valueForMinPos = value;
			drawHandle();
		}
		
		public function set value($value:Number):void 
		{
			_value = $value;
			truncateHandlePos(($value - _valueForMinPos) / (_valueForMaxPos - _valueForMinPos) * _handleMax);
			updateHandlePos();
		}
		
		public function set valueForPageSize(value:Number):void 
		{
			_valueForPageSize = value;
		}
		
		public function setValues($valueForMinPos:Number, $valueForMaxPos:Number, $valueForPageSize:Number, $value:Number):void {
			_valueForMinPos = $valueForMinPos;
			_valueForMaxPos = $valueForMaxPos;
			_valueForPageSize = $valueForPageSize;
			_value = $value;
			drawHandle();
		}
		
		protected function checkMouse(e:Event):void { }
		public function drawHandle():void { }
		public function updateHandlePos():void { }
		protected function barClicked():void { }
		protected function onDrag():void { }
	}

}