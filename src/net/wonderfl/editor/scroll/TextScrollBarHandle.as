package net.wonderfl.editor.scroll 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import net.wonderfl.component.core.UIComponent;;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class TextScrollBarHandle extends UIComponent {
		private var _overSkin:Sprite;
		
		public function TextScrollBarHandle() {
			_overSkin = new Sprite;
			_overSkin.visible = false;
			tabEnabled = false;
			addChild(_overSkin);
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addEventListener(MouseEvent.MOUSE_OVER, function ():void {
				_overSkin.visible = true;
			});
			addEventListener(MouseEvent.MOUSE_OUT, function ():void {
				_overSkin.visible = false;
			});
		}
		
		override protected function updateSize():void 
		{
			trace('updateSize', this, _width, _height);
			
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