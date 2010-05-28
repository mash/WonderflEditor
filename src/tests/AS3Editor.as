package tests 
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	import net.wonderfl.editor.core.UIFTETextInput;
	import net.wonderfl.editor.IEditor;
	import net.wonderfl.editor.LineNumberField;
	import net.wonderfl.editor.core.UIComponent;
	import net.wonderfl.editor.core.UIFTETextField;
	import net.wonderfl.editor.error.ErrorMessage;
	import net.wonderfl.editor.manager.CodeAssistManager;
	import net.wonderfl.editor.minibuilder.ASParserController;
	import net.wonderfl.editor.scroll.TextHScroll;
	import net.wonderfl.editor.scroll.TextVScroll;
	import net.wonderfl.editor.utils.calcFontBox;
	import ro.minibuilder.main.editor.Location;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class AS3Editor extends UIComponent implements IEditor
	{
		private const CHECK_MOUSE_DURATION:int = 500;
		private var _errors:Array = [];
		private var changeRevalIID:int;
		private var _field:UIFTETextInput;
		private var _codeAssistManager:CodeAssistManager;
		private var lineNums:LineNumberField;
		private var _vScroll:TextVScroll;
		private var _hScroll:TextHScroll;
		private var _boxWidth:int;
		private var _this:AS3Editor;
		private var _parser:ASParserController;
		
		public function AS3Editor() 
		{
			_this = this;
			_field = new UIFTETextInput;
			addChild(_field);
			
			
			_boxWidth = calcFontBox(_field.defaultTextFormat).width;
			
			
			addEventListener(FocusEvent.FOCUS_IN, function(e:FocusEvent):void {
				stage.focus = _field;
			});
			
			addEventListener(FocusEvent.KEY_FOCUS_CHANGE, function(e:Event):void {
				e.preventDefault();	
			});
			
			_field.addEventListener(Event.SCROLL, onTextScroll);
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
			
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_parser = new ASParserController(stage, _this);
			_codeAssistManager = new CodeAssistManager(_field, _parser, stage, onComplete);
			_field.addPlugIn(_codeAssistManager);
			
			
			//setTimeout(checkMouse, CHECK_MOUSE_DURATION);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function ():void {
				//checkMouse();
			});
			addEventListener(Event.CHANGE, onChange);
			//addEventListener(Event.SCROLL, onScroll);
		}
		
		private function onComplete():void
		{
			
		}
		
		private function onChange(e:Event):void
		{
			if (triggerAssist())
				_codeAssistManager.triggerAssist();
			else
				_parser.sourceChanged(text, '');
				
			lineNums.draw();
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
			//trace('on h scroll : ' + _hScroll.value);
			_field.scrollH = _hScroll.value;
//			_field.x = lineNums.width - _hScroll.value * _boxWidth;
		}
		
		private function onTextScroll(e:Event):void 
		{
			//_hScroll.setThumbPercent(_width / _field.maxWidth);
			//_hScroll.setSliderParams(1, _field.width / _boxWidth, _hScroll.value);
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
		
		public function clearErrors():void {
			_errors.length = 0;
			setErrorPositions([]);
			draw();
		}
		
		public function setFontSize($size:int):void {
			
		}
		
		private function setErrorPositions($errors:Array):void
		{
			
		}
		
		public function setError($row:int, $col:int, $message:String):void {
			_errors.push(new ErrorMessage([$row, $col, $message]));
			// draw error positions
			setErrorPositions(_errors.map(
				function ($error:ErrorMessage, $index:int, $array:Array):int {
					return $error.row;
				}
			));
			
			draw();
		}
		
		protected function triggerAssist():Boolean
		{
			// refactor
			var str:String = text.substring(Math.max(0, _field.caretIndex-30), _field.caretIndex);
			str = str.split('').reverse().join('');
			return (/^(?:\(|\:|\.|\ssa\b|\swen\b|\ssdnetxe)/.test(str))
		}
		
		public function loadSource(source:String, filePath:String):void
		{
			text = source.replace(/(\n|\r\n)/g, '\r');
			//fileName = filePath;
			//ctrl.sourceChanged(text, fileName);
			_parser.sourceChanged(_field.text, '');
		}
		
		public function findDefinition():Location
		{
			return _parser.findDefinition(_field.caretIndex);
		}
		
		
		private function draw():void
		{
			
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