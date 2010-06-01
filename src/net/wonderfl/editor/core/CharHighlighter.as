package net.wonderfl.editor.core 
{
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class CharHighlighter extends Sprite
	{
		private var MAX_COUNT:int = 48;
		private var _frameCount:int = 0;
		
		public function CharHighlighter() {
			mouseEnabled = false;
		}
		
		public function highlight($xpos:int, $ypos:int, $width:int, $height:int):void {
			graphics.clear();
			graphics.beginFill(0x455fac);
			graphics.drawRect($xpos, $ypos, $width, $height);
			graphics.endFill();
			
			if (_frameCount == 0)
				addEventListener(Event.ENTER_FRAME, fadeOutTween);
				
			_frameCount = MAX_COUNT;
		}
		
		private function fadeOutTween(e:Event):void {
			if (--_frameCount < 0) {
				_frameCount = 0;
				removeEventListener(Event.ENTER_FRAME, fadeOutTween);
			} else {
				// easing quad
				alpha = (_frameCount / MAX_COUNT);
			}
		}
		
	}

}