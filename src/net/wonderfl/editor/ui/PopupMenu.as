package net.wonderfl.editor.ui 
{
	import flash.display.DisplayObjectContainer;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.GroupElement;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import net.wonderfl.component.core.UIComponent;;
	import net.wonderfl.editor.utils.removeAllChildren;
	import net.wonderfl.editor.utils.removeFromParent;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class PopupMenu extends UIComponent
	{
		private static const MAX_ENTRIES:int = 10;
		private var _data:Array = [];
		private var _selectedIndex:int;
		private var _scrollPos:int = 0;
		private var _factory:TextBlock;
		private const BACKGROUND_COLOR:uint = 0xe4e4e4;
		private const SELECT_COLOR:uint = 0xCC6666;
		private var _fontName:String = '_sans';
		
		public function PopupMenu() 
		{
			_width = _height = 0;
			_factory = new TextBlock;
		}
		
		public function setListData($data:Array):void {
			_data = $data;
			draw();
		}
		
		private function draw():void
		{
			removeAllChildren(this);
			
			var end:int = _scrollPos + MAX_ENTRIES;
			end = (end >= _data.length) ? _data.length : end;
			var elf:ElementFormat = new ElementFormat(new FontDescription(_fontName));
			_factory.content = new GroupElement(Vector.<ContentElement>(
				_data.slice(_scrollPos, end).map(function ($item:String, $index:int, $array:Array):TextElement {
					elf = elf.clone();
					elf.color = 0;
					var result:TextElement = new TextElement($item + '\n', elf);
					return result;
				})
			));
			
			var line:TextLine = null;
			var i:int = 0;
			var w:int = 0;
			while (true) {
				line = _factory.createTextLine(line, TextLine.MAX_LINE_WIDTH);
				if (line == null || (i + _scrollPos) >= _data.length) break;
				w = (w < line.width) ? line.width : w;
				line.y = 15 * ++i - 2;
				line.x = 2;
				addChild(line);
			}
			
			setSize(w + 4, i * 15);
			updateSize();
		}
		
		public function set selectedIndex($index:int):void {
			if (_scrollPos + MAX_ENTRIES <= $index) {
				var temp:int = $index - MAX_ENTRIES + 1;
				temp = (temp < 0) ? 0 : temp;
				_scrollPos = temp;
			}
			
			$index %= _data.length;
			if ($index < 0) {
				$index += _data.length;
			}
			
			_selectedIndex = $index;
			_scrollPos = (_scrollPos > $index) ? $index : _scrollPos;
			
			draw();
		}
		
		public function setY($value:int):void {
			y = $value;
		}
		
		public function show($container:DisplayObjectContainer, $xpos:int, $ypos:int):void {
			x = $xpos;
			y = $ypos;
			$container.addChild(this);
		}
		
		public function dispose():void {
			removeFromParent(this);
		}
		
		public function getSelectedValue():String {
			return _data[_selectedIndex];
		}
		
		public function get data():Array { return _data; }
		
		public function set data(value:Array):void 
		{
			_data = value;
		}
		
		public function get selectedIndex():int { return _selectedIndex; }
		
		public function set fontName(value:String):void 
		{
			_fontName = value;
		}
		
		override protected function updateSize():void 
		{
			graphics.clear();
			graphics.beginFill(BACKGROUND_COLOR);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
			
			var i:int = (_selectedIndex - _scrollPos);
			i = (i > 9) ? 9 : i;
			graphics.beginFill(SELECT_COLOR);
			graphics.drawRect(0, 15 * i, _width, 15);
			graphics.endFill();
		}
	}
}