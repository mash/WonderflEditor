package net.wonderfl.editor 
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import mx.events.ScrollEvent;
	import mx.events.ScrollEventDirection;
	import net.wonderfl.editor.core.LineNumberField;
	import net.wonderfl.editor.core.UIComponent;
	import net.wonderfl.editor.core.UIFTETextField;
	import net.wonderfl.editor.manager.ClipboardManager;
	import net.wonderfl.editor.manager.EditorHotkeyManager;
	import net.wonderfl.editor.minibuilder.ASParserController;
	import net.wonderfl.editor.operations.SetSelection;
	import net.wonderfl.editor.scroll.TextHScroll;
	import net.wonderfl.editor.scroll.TextVScroll;
	import net.wonderfl.editor.utils.calcFontBox;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class AS3Viewer extends UIComponent implements ITextArea, IEditor
	{
		private var _parser:ASParserController;
		private var _editorHotkeyManager:EditorHotkeyManager;
		private var changeRevalIID:int;
		private var _field:UIFTETextField;
		private var lineNums:LineNumberField;
		private var _vScroll:TextVScroll;
		private var _hScroll:TextHScroll;
		private var _blackShade:Shape;
		private var _boxWidth:int;
		
		public function AS3Viewer() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_field = new UIFTETextField;
			addChild(_field);
			_boxWidth = _field.boxWidth;
			
			_parser = new ASParserController(stage, _field);
			_editorHotkeyManager = new EditorHotkeyManager(_field, _parser);
			_field.addPlugIn(_editorHotkeyManager);
			
			addEventListener(FocusEvent.FOCUS_IN, function(e:FocusEvent):void {
				stage.focus = _field;
			});
			
			addEventListener(FocusEvent.KEY_FOCUS_CHANGE, function(e:Event):void {
				e.preventDefault();	
			});
			
			_field.addEventListener(Event.RESIZE, onFieldResize);
			_field.addEventListener(ScrollEvent.SCROLL, onScroll);
			_field.addEventListener(Event.CHANGE, onChange);
			
			lineNums = new LineNumberField(_field);
			addChild(lineNums);
			lineNums.addEventListener(Event.RESIZE, function ():void {
				_field.x = lineNums.width;
				_field.width = _width - lineNums.width;
			});
			
			_vScroll = new TextVScroll(_field);
			_hScroll = new TextHScroll(_field);
			_hScroll.addEventListener(Event.CHANGE, onHScroll);
			_vScroll.addEventListener(Event.CHANGE, onVScroll);
			
			_blackShade = new Shape;
			_blackShade.graphics.beginFill(0);
			_blackShade.graphics.drawRect(0, 0, _vScroll.width, _hScroll.height);
			_blackShade.graphics.endFill();
			
			addChild(_blackShade);
			addChild(_vScroll);
			addChild(_hScroll);
		}
		
		public function saveCode():void {
			_editorHotkeyManager.saveCode();
		}
		
		public function slowDownParser():void {
			_parser.slowDownParser();
		}
		
		public function onChange(e:Event):void 
		{
			_parser.sourceChanged(_field.text, '');
		}
		
		private function onVScroll(e:Event):void 
		{
			_field.setScrollYByBar(_vScroll.value);
		}
		
		private function onScroll(e:ScrollEvent):void 
		{
			if (e.direction == ScrollEventDirection.VERTICAL) {
				_vScroll.value = e.position;
			} else { // horizontal
				_hScroll.value = e.position;
			}
			
			redrawBars();
		}
		
		private function onFieldResize(e:Event):void 
		{
			redrawBars();
		}
		
		private function redrawBars():void {
			
			_hScroll.setThumbPercent((_width - lineNums.width - 15) / _field.maxWidth);
			
			var maxH:int = ((_field.maxWidth - _width + lineNums.width + 15) / _field.boxWidth) >> 0;
			maxH = (maxH < 0) ? 0 : maxH;
			maxH++;
			
			// update position
			_hScroll.setSliderParams(0, maxH, _hScroll.value);
			
			_vScroll.setThumbPercent(_field.visibleRows / (_field.visibleRows + _field.maxScrollV));
			_vScroll.setSliderParams(0, _field.maxScrollV, _field.scrollY);
		}
		
		private function onHScroll(e:Event):void 
		{
			_field.scrollH = _hScroll.value;
		}
		
		override protected function updateSize():void 
		{
			_field.height = _height - _hScroll.height;
			_field.width = _width - lineNums.width - _vScroll.width;
			_vScroll.height = _height - _hScroll.height;
			_hScroll.width = _width - _vScroll.width;
			_vScroll.x = _width - _vScroll.width;
			_hScroll.y = _field.height;
			_blackShade.x = _vScroll.x;
			_blackShade.y = _hScroll.y;
			lineNums.height = _field.height;
		}
		
		public function copy():void {
			ClipboardManager.getInstance().copy();
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
			_field.setScrollYByBar(value);
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
		
		public function onReplaceText($beginIndex:int, $endIndex:int, $newText:String):void 
		{
			_field.replaceText($beginIndex, $endIndex, $newText);
			onChange(null);
		}
		
		public function onSetSelection($selectionBeginIndex:int, $selectionEndIndex:int):void {
			_field.setSelectionPromise = new SetSelection($selectionBeginIndex, $selectionEndIndex);
		}
		
		public function get text():String {
			return _field.text;
		}
		
		public function set text(value:String):void {
			_field.text = value;
			onChange(null);
		}
		
		/* net.wonderfl.editor.IEditor
		 * the viewer is read-only
		 */
		public function paste():void { }
		public function cut():void { }
	}

}