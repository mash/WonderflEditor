package net.wonderfl.editor 
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.TextFormat;
	import net.wonderfl.editor.core.UIComponent;
	import net.wonderfl.editor.core.FTETextField;
	import net.wonderfl.editor.utils.calcFontBox;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	[Event(name = 'resize', type = 'flash.events.Event')]
	public class LineNumberField extends UIComponent
	{
		private var _fte:FTETextField;
		private var _defaultTextFormat:TextFormat;
		private var _block:TextBlock;
		private var _scrollY:int = -1;
		
		public function LineNumberField($fte:FTETextField) 
		{
			_fte = $fte;
			_block = new TextBlock;
			mouseChildren = mouseEnabled = false;
			
			_defaultTextFormat = $fte.defaultTextFormat;
			_fte.addEventListener(Event.SCROLL, onScroll);
			_width = 0;
			
			onScroll(null);
		}
		
		private function onScroll(e:Event):void 
		{
			if (_scrollY != _fte.scrollY) {
				_scrollY = _fte.scrollY;
				draw();
			}
		}
		
		public function draw():void {
			var line:TextLine;
			
			while (numChildren)	removeChildAt(0);
			
			var box:Rectangle = calcFontBox(_defaultTextFormat);
			var rows:int = _fte.visibleRows;
			var start:int = _scrollY;
			var end:int = start + rows;
			var arr:Array = [];
			
			for (var i:int = start; i <= end; ++i) 
			{
				arr[i - start] = i;
			}
			
			var elementFormat:ElementFormat = new ElementFormat(new FontDescription(_defaultTextFormat.font), _defaultTextFormat.size + 0, 0xffffff);
			var textElement:TextElement = new TextElement(arr.join('\n'), elementFormat);
			_block.content = textElement;
			
			var w:int = 0;
			line = _block.createTextLine(null, TextLine.MAX_LINE_WIDTH);
			while (line) {
				w = (w < line.textWidth) ? line.textWidth : w;
				addChild(line);
				line = _block.createTextLine(line, TextLine.MAX_LINE_WIDTH);
			}
			w += 4;
			i = 0;
			line = getChildAt(0) as TextLine;
			while (line) {
				line.x = w - line.textWidth;
				line.y = box.height * i++ - 2;
				line = line.nextLine;
			}
			
			w += 4;
			if (_width != w) {
				_width = w;
				
				dispatchEvent(new Event(Event.RESIZE));
			}
			_height = i * box.height - 2;
			
			graphics.clear();
			graphics.beginFill(0);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}
		
		
		override protected function updateSize():void 
		{
			draw();
		}
		
		public function set defaultTextFormat(value:TextFormat):void 
		{
			_defaultTextFormat = value;
		}
	}
}