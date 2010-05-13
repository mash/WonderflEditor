package net.wonderfl.editor.core 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class TextVScroll extends UIComponent
	{
		private static const MINIMUM_THUMB_HEIGHT:int = 15;
		private var _handle:TextScrollBarHandle;
		private var _target:FTETextField;
		private var _scrollY:int = -1;
		private var _trackHeight:int;
		private var _prevMouseY:int;
		private var _diff:Number;
		
		public function TextVScroll($target:FTETextField) 
		{
			_width = 15;
			_handle = new TextScrollBarHandle;
			_handle.addEventListener(MouseEvent.MOUSE_DOWN, onDrag);
			
			_target = $target;
			_target.addEventListener(Event.SCROLL, onScroll);
			
			addChild(_handle);
		}
		
		private function onScroll(e:Event):void 
		{
			_handle.y = _trackHeight * _target.scrollY / _target.maxScrollV;
		}
		
		protected function onDrag(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onDrop);
			//stage.addEventListener(MouseEvent.MOUSE_MOVE, onSlide);
			stage.addEventListener(Event.ENTER_FRAME, checkMouse);
			_prevMouseY = NaN;
			_diff = _handle.y - mouseY;
		}
		
		private function checkMouse(e:Event):void 
		{
			if (mouseY != _prevMouseY) {
				_prevMouseY = mouseY;
				var yPos:Number = _diff + _prevMouseY;
				yPos = (yPos < 0) ? 0 : yPos;
				yPos = (yPos > _trackHeight) ? _trackHeight : yPos;
				_handle.y = yPos;
				var oldValue:int = _scrollY;
				_scrollY = Math.round(_target.maxScrollV * (_handle.y / _trackHeight));
				if (oldValue != _scrollY) {
					_target.scrollY = _scrollY;
				}
			}
		}
		
		protected function onDrop(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onDrop);
			//stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSlide);
			stage.removeEventListener(Event.ENTER_FRAME, checkMouse);
			_handle.stopDrag();
		}
		
		//protected function onSlide(event:MouseEvent):void
		//{
			//var oldValue:int = _scrollY;
			//_scrollY = Math.ceil(_target.maxScrollV * (_handle.y / _trackHeight));
			//if (oldValue != _scrollY) {
				//_target.scrollY = _scrollY;
			//}
		//}
		
		override public function set width(value:Number):void {}
		
		override protected function updateSize():void {
			graphics.clear();
			graphics.beginFill(0);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
			
			graphics.beginFill(0x111111);
			graphics.drawRect(0, 0, _width, _height - MINIMUM_THUMB_HEIGHT);
			graphics.endFill();
			
			updateThumb();
		}
		
		private function updateThumb():void {
			var h:int;
			h = _height * _target.visibleRows / _target.maxScrollV;
			
			if (h >= _height)
				_handle.visible = false;
			
			h = (h < MINIMUM_THUMB_HEIGHT) ? MINIMUM_THUMB_HEIGHT : h;
			_trackHeight = _height - h - MINIMUM_THUMB_HEIGHT;
			
			_handle.setSize(_width, h);
		}
	}
}

