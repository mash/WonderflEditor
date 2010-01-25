package net.wonderfl.editor 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ToolTip extends Sprite
	{
		private static const BACKGROUND_COLOR:uint = 0xf4dfcb;
		private var _textField:TextField;
		private var _width:int;
		private var _height:int;
		
		public function ToolTip() 
		{
			_textField = new TextField;
			_textField.defaultTextFormat = new TextFormat("_sans", 10);
			addChild(_textField);
			
			mouseEnabled = mouseChildren = false;
			_textField.mouseEnabled = false;
		}
		
		public function setMessage($message:String):void {
			_textField.text = $message;
			_textField.width = _textField.textWidth + 4;
			_textField.height = _textField.textHeight + 4;
			
			setSize(_textField.width, _textField.height);
			draw();
		}
		
		private function draw():void {
			graphics.clear();
			graphics.beginFill(BACKGROUND_COLOR);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}
		
		public function setSize($width:int, $height:int):void {
			_width = $width;
			_height = $height;
			draw();
		}
	}
}