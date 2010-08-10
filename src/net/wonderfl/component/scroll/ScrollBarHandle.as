package net.wonderfl.component.scroll 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.MouseCursor;
	import net.wonderfl.component.core.UIComponent;
	import net.wonderfl.mouse.MouseCursorController;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ScrollBarHandle extends UIComponent {
		private var _overSkin:Sprite;
		
		public function ScrollBarHandle() {
			_overSkin = new Sprite;
			_overSkin.visible = false;
			addChild(_overSkin);
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addEventListener(MouseEvent.MOUSE_OVER, function ():void {
				_overSkin.visible = true;
				MouseCursorController.getOverStateHandler(MouseCursor.BUTTON)();
			});
			addEventListener(MouseEvent.MOUSE_OUT, function ():void {
				_overSkin.visible = false;
				MouseCursorController.resetMouseCursor();
			});
		}
		
		override protected function updateSize():void 
		{
			graphics.clear();
			graphics.beginFill(0x444444);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
			
			_overSkin.graphics.clear();
			_overSkin.graphics.beginFill(0x666666);
			_overSkin.graphics.drawRect(0, 0, _width, _height);
			_overSkin.graphics.endFill();
		}
	}
}