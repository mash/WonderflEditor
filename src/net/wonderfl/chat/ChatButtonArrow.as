package net.wonderfl.chat 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ChatButtonArrow extends Sprite
	{
		private static const DRAW_ARROW_COMMANDS:Vector.<int> = Vector.<int>([1, 2, 2, 2]);
		private static const A:int = 3;
		private static const B:int = 3;
		private static const C:int = 2;
		
		public function ChatButtonArrow() 
		{
			graphics.beginFill(ChatStyle.CHAT_MESSAGE);
			graphics.drawPath(DRAW_ARROW_COMMANDS, Vector.<Number>([-A, B, C, 0, C, 2 * B, -A, B]));
			graphics.endFill();
		}
		
	}

}