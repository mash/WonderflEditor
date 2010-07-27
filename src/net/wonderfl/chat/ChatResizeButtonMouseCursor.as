package net.wonderfl.chat 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ChatResizeButtonMouseCursor extends Sprite
	{
		public function ChatResizeButtonMouseCursor() {
			graphics.lineStyle(1, ChatStyle.CHAT_MESSAGE);
			
			var a:int = 10;
			var b:int = 5;
			var c:int = 6;
			
			graphics.drawPath(
				Vector.<int>([1,2,2,1,2,2]), Vector.<Number>([-b,a-c,0,a,b,a-c,-b,c-a,0,-a,b,c-a])
			);
		}
		
	}

}