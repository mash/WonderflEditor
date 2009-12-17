package net.wonderfl.controls 
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import jp.psyark.psycode.controls.UIControl;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ToolTip extends UIControl
	{
		public static var PADDING:int = 10;
		private var _textField:TextField;
		private var _isShowing:Boolean = false;
		
		public function ToolTip() 
		{
			_textField = new TextField;
			_textField.multiline = true;
			_textField.wordWrap = true;
			addChild(_textField);
			deactivate();
		}
		
		public function show():void {
			_isShowing = true;
			visible = true;
		}
		
		public function deactivate():void {
			_isShowing = false;
			visible = false;
		}
		
		public function isShowing():Boolean {
			return _isShowing;
		}
		
		public function set text(value:String):void {
			_textField.text = value;
			_textField.height = _textField.textHeight + 4;
			height = _textField.textHeight + PADDING * 2;
		}
		
		public function set textFormat(value:TextFormat):void {
			_textField.defaultTextFormat = value;
			_textField.setTextFormat(value);
		}
		
		override protected function updateSize():void 
		{
			graphics.clear();
			graphics.beginFill(0x1a1a1a);
			graphics.drawRect( 0, 0, width, height);
			
			_textField.x = _textField.y = PADDING;
			_textField.width = width - PADDING * 2;
			_textField.height = height - PADDING * 2;
		}
	}

}