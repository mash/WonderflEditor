package net.wonderfl.chat 
{
	import adobe.utils.CustomActions;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import net.wonderfl.component.core.UIComponent;
	import net.wonderfl.utils.listenOnce;
	import net.wonderfl.utils.removeFromParent;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ChatResizeButton extends UIComponent
	{
		private var _cursor:ChatResizeButtonMouseCursor;
		private var _watchingMouse:Boolean = false;
		
		public function ChatResizeButton() 
		{
			listenOnce(this, Event.ADDED_TO_STAGE, init);
		}
		
		private function init():void
		{
			mouseChildren = false;
			
			_cursor = new ChatResizeButtonMouseCursor;
			addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
		}
		
		private function mouseOut(e:MouseEvent):void 
		{
			Mouse.show();
			removeFromParent(_cursor);
		}
		
		private function mouseOver(e:MouseEvent):void 
		{
			Mouse.hide();
			addChild(_cursor);
			watchMouse();
		}
		
		private function watchMouse():void
		{
			if (_watchingMouse) return;
			_watchingMouse = true;
			addEventListener(Event.ENTER_FRAME, _watchMouse);
		}
		
		private function _watchMouse(e:Event):void 
		{
			_cursor.x = mouseX;
			_cursor.y = mouseY;
		}
		
		
		override protected function updateSize():void 
		{
			graphics.clear();
			graphics.beginFill(0, 0);
			graphics.drawRect(0, - (_height >> 1), _width, _height);
			graphics.endFill();
			
			graphics.lineStyle(1, ChatStyle.MESSAGE_ITEM_HEADER);
			graphics.moveTo(0, 0);
			graphics.lineTo(_width, 0);
		}
		
	}

}
