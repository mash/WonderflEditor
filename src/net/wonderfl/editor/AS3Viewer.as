package net.wonderfl.editor 
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import net.wonderfl.editor.core.UIComponent;
	import net.wonderfl.editor.core.UIFTETextField;
	import net.wonderfl.editor.scroll.TextHScroll;
	import net.wonderfl.editor.scroll.TextVScroll;
	import net.wonderfl.editor.utils.calcFontBox;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class AS3Viewer extends UIComponent implements IEditor
	{
		private var changeRevalIID:int;
		private var _field:UIFTETextField;
		private var lineNums:LineNumberField;
		private var _vScroll:TextVScroll;
		private var _hScroll:TextHScroll;
		private var _boxWidth:int;
		
		public function AS3Viewer() 
		{
			_field = new UIFTETextField;
			addChild(_field);
			_boxWidth = _field.boxWidth;
			
			addEventListener(FocusEvent.FOCUS_IN, function(e:FocusEvent):void {
				stage.focus = _field;
			});
			
			addEventListener(FocusEvent.KEY_FOCUS_CHANGE, function(e:Event):void {
				e.preventDefault();	
			});
			
			_field.addEventListener(Event.RESIZE, onFieldResize);
			
			lineNums = new LineNumberField(_field);
			addChild(lineNums);
			lineNums.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
				_field.onMouseDown(e);
				stage.addEventListener(MouseEvent.MOUSE_UP, numStageMouseUp);
			});
			lineNums.addEventListener(Event.RESIZE, function ():void {
				_field.x = lineNums.width;
				_field.width = _width - lineNums.width;
			});
			
			_vScroll = new TextVScroll(_field);
			_hScroll = new TextHScroll(_field);
			_hScroll.addEventListener(Event.SCROLL, onHScroll);
			addChild(_vScroll);
			addChild(_hScroll);
		}
		
		private function onFieldResize(e:Event):void 
		{
			_hScroll.setThumbPercent((_width - lineNums.width - 15) / _field.maxWidth);
			
			var maxH:int = ((_field.maxWidth - _width + lineNums.width + 15) / _field.boxWidth) >> 0;
			maxH = (maxH < 0) ? 0 : maxH;
			maxH++;
			
			_hScroll.setSliderParams(1, maxH, _hScroll.value);
		}
		
		private function onHScroll(e:Event):void 
		{
			_field.scrollH = _hScroll.value;
		}
		
		private function numStageMouseUp(e:Event):void
		{
			stage.focus = _field;
			stage.removeEventListener(MouseEvent.MOUSE_UP, numStageMouseUp);
		}
		
		override protected function updateSize():void 
		{
			_field.height = _height - _hScroll.height;
			_field.width = _width - lineNums.width - _vScroll.width;
			_vScroll.height = _height;
			_hScroll.width = _width;
			_vScroll.x = _width - _vScroll.width;
			_hScroll.y = _field.height;
			lineNums.height = _field.height;
		}
		
		public function copy():void {
			_field.onCopy();
		}
		
		public function selectAll():void {
			_field.onSelectAll(null);
		}
		
		public function applyFormatRuns():void
		{
			_field.applyFormatRuns();
		}
		
		public function addFormatRun(beginIndex:int, endIndex:int, bold:Boolean, italic:Boolean, color:String):void
		{
			_field.addFormatRun(beginIndex, endIndex, bold, italic, color);
		}
		
		public function set scrollY(value:int):void {
			_field.scrollY = value;
		}
		
		public function set scrollH(value:int):void {
			_field.scrollH = value;
		}
		
		public function updateLineNumbers():void {
			lineNums.draw();
		}
		
		public function get selectionBeginIndex():int { return _field.selectionBeginIndex; }
		public function get selectionEndIndex():int { return _field.selectionEndIndex; }
		
		public function clearFormatRuns():void
		{
			_field.clearFormatRuns();
		}
		
		public function setSelection($selectionBeginIndex:int, $selectionEndIndex:int):void {
			_field.setSelection($selectionBeginIndex, $selectionEndIndex);
		}
		
		public function get text():String {
			return _field.text;
		}
		
		public function set text(value:String):void {
			_field.text = value;
		}
		
	}

}