package net.wonderfl.editor.error 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ErrorRowSprite extends Sprite {
		public function ErrorRowSprite($row:int, $message:String, $mouseOver:Function) {
			addEventListener(Event.ADDED_TO_STAGE, function added(e:Event):void {
				removeEventListener(Event.ADDED_TO_STAGE, added);
				
				addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
				addEventListener(Event.REMOVED_FROM_STAGE, function removed(e:Event):void {
					removeEventListener(Event.REMOVED_FROM_STAGE, removed);
					
					removeEventListener(MouseEvent.MOUSE_OVER, mouseOver);
				});
			});
			
			function mouseOver(e:MouseEvent):void {
				$mouseOver($row, $message);
			}
		}
	}
}