package net.wonderfl.editor.ui 
{
	import flash.geom.Rectangle;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import net.wonderfl.editor.core.UIComponent;
	import net.wonderfl.editor.utils.removeAllChildren;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ToolTip extends UIComponent
	{
		public var leftOffset:int;
		private var _elf:ElementFormat;
		private var _isShowing:Boolean = false;
		private var _factory:TextBlock;
		private const BACKGROUND_COLOR:uint = 0x99cee4;
		private var _rect:Rectangle = new Rectangle;
		
		public function ToolTip() 
		{
			_width = _height = 0;
			_factory = new TextBlock;
			_elf = new ElementFormat();
			_elf.color = 0;
			
			updateSize();
		}
		
		public function isShowing():Boolean {
			return (parent != null);
		}
		
		public function clear():void {
			removeAllChildren(this);
		}
		
		public function setPreText($text:String):void {
			var line:TextLine = getLine($text);
			line.x = -(line.width + leftOffset);
			_rect.left = line.x;
		}
		
		public function setPostText($text:String):void {
			var line:TextLine = getLine($text);
			_rect.right = line.width;
			setSize(line.width, line.height + 4);
		}
		
		private function getLine($text:String):TextLine {
			_factory.content = new TextElement($text, _elf.clone());
			var line:TextLine = _factory.createTextLine();
			line.y = line.height;
			addChild(line);
			_rect.bottom = line.height;
			
			return line;
		}
		
		public function moveLocationRelatedTo($xpos:int, $ypos:int):void {
			x = $xpos;
			y = $ypos;
		}
		
		public function getSelectedValue():String {
			return '';
		}
		
		public function draw():void {
			updateSize();
		}
		
		override protected function updateSize():void 
		{
			graphics.clear();
			graphics.beginFill(BACKGROUND_COLOR);
			graphics.drawRect(_rect.left - 2, 0, _rect.width + 4, _rect.height + 2);
			graphics.endFill();
		}
		
		public function set fontName(value:String):void 
		{
			_elf = _elf.clone();
			_elf.fontDescription = new FontDescription(value);
		}
		
	}

}