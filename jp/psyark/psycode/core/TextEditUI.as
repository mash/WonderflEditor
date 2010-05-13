package jp.psyark.psycode.core 
{
import adobe.utils.CustomActions;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextFieldAutoSize;
import flash.text.TextLineMetrics;
import flash.utils.setTimeout;
import jp.psyark.psycode.controls.UIControl;
import jp.psyark.psycode.controls.TextScrollBar;
import jp.psyark.psycode.controls.ScrollBar;
import net.wonderfl.editor.IEditor;
import net.wonderfl.editor.IScriptArea;
import jp.psyark.utils.callLater;
import jp.psyark.utils.convertNewlines;
import jp.psyark.utils.CodeUtil;
import net.wonderfl.controls.EditorScrollBar;
import net.wonderfl.editor.LineNumberView;
import net.wonderfl.editor.livecoding.LiveCodingControllerView;

import flash.events.Event;
import flash.events.FocusEvent;
import flash.net.FileReference;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.ui.Keyboard;

/**
 * @private
 */
public class TextEditUI extends UIControl implements IScriptArea {
	protected var linumField:LineNumberView;
	protected var scrollBarV:EditorScrollBar;
	protected var scrollBarH:TextScrollBar;
	protected var _textField:TextField;
	
	private var TAB_STOP_RATIO:Number = 2.42;
	private var _selectionGraphic:Shape;
	private var _selectionColor:uint = 0x694644;
	public var fileRef:FileReference;
	private var _currentSelectionBeginIndex:int = -2;
	private var _currentSelectionEndIndex:int = -2;
	private var _frameSprite:Sprite;
	protected var _liveCodingController:LiveCodingControllerView;
	private var _text:String = '';
	
	
	public function TextEditUI() {
		var tabStops:Array = [];
		for (var i:int=1; i<20; i++) {
			tabStops.push(13 * TAB_STOP_RATIO * i);
		}
		var fmt:TextFormat = new TextFormat("_typewriter", 13, 0xffffff);
		fmt.tabStops = tabStops;
		fmt.leading = 1;
		
		
		_selectionGraphic = new Shape;
		_selectionGraphic.alpha = 0.5;
		
		_textField = new TextField();
		_textField.multiline = true;
		_textField.background = false;
		_textField.alwaysShowSelection = false;
		_textField.type = TextFieldType.INPUT;
		_textField.defaultTextFormat = fmt;
		_textField.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, function (event:FocusEvent):void {
			event.preventDefault();
		});
		
		_textField.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		
		fmt.align = TextFormatAlign.RIGHT;
		fmt.color = 0x666666;
		
		linumField = new LineNumberView(this);
		linumField.setTextFormat(fmt);
		linumField.addEventListener(Event.RESIZE, linumResizeHandler);
		
		scrollBarV = new EditorScrollBar(_textField);
		scrollBarH = new TextScrollBar(_textField, ScrollBar.HORIZONTAL);
		
		_frameSprite = new Sprite;
		//scrollBarV.alpha = 0.3;
		
		addChild(_selectionGraphic);
		addChild(_textField);
		addChild(linumField);
		addChild(_frameSprite);
		addChild(scrollBarV);
		addChild(scrollBarH);
		addChild(_liveCodingController = new LiveCodingControllerView);
		
		updateSize();
		
		_textField.addEventListener(Event.SCROLL, textFieldScrollHandler);
	}
	
	
	public function getLineOffset(lineIndex:int):int {
		return _textField.getLineOffset(lineIndex);
	}
	
	public function open():void {
		fileRef = new FileReference();
		fileRef.addEventListener(Event.SELECT, function (event:Event):void {
			fileRef.load();
		});
		fileRef.addEventListener(Event.COMPLETE, function (event:Event):void {
			text = convertNewlines(String(fileRef.data));
		});
		fileRef.browse();
	}
	
	public function setErrorPositions($positions:Array):void {
		var len:int = $positions.length;
		var i:int;
		var row:int;
		var rect:Rectangle;
		var positions:Array = [];
		var lastLine:int = textField.numLines;
		
		for (i = 0; i < len; ++i) {
			row = $positions[i];
			rect = new Rectangle;
			
			if (row <= lastLine) {
				rect.height = 1 / lastLine;
				rect.y = row / lastLine;
				positions.push(rect);
			}
		}
		
		scrollBarV.setErrorPositions(positions);
	}
	
	public function get lastLineIndex():int
	{
		var lastCharIndex:int = _textField.length - 1;
		if (lastCharIndex < 1) return 0;
		
		return _textField.getLineIndexOfChar(lastCharIndex);
	}
	
	public function save():void {
		var localName:String = CodeUtil.getDefinitionLocalName(text);
		localName ||= "untitled";
		fileRef = new FileReference();
		fileRef.save(text.replace(/\r/g, '\r\n'), localName + ".as");
	}
	
	public function setFontSize(fontSize:Number):void {
		var tabStops:Array = [];
		for (var i:int=1; i<20; i++) {
			tabStops.push(i * fontSize * 2.42);
		}
		
		var fmt:TextFormat = _textField.defaultTextFormat;
		fmt.size = fontSize;
		fmt.tabStops = tabStops;
		_textField.defaultTextFormat = fmt;
		
		fmt.align = TextFormatAlign.RIGHT;
		fmt.color = 0x666666;
		linumField.setTextFormat(fmt);
		
		fmt = new TextFormat();
		fmt.size = fontSize;
		fmt.tabStops = tabStops;
		_textField.setTextFormat(fmt);
		
		dispatchChangeEvent();
	}
	
	
	private function textFieldScrollHandler(event:Event):void {
		dispatchEvent(event);
		drawSelection(selectionBeginIndex, selectionEndIndex);
	}
	
	private function linumResizeHandler(event:Event):void {
		updateSize();
	}
	

	
	public function get lineNumWidth():int {
		return _textField.x;
	}
	public function get text():String {
		return _textField.text;
	}
	public function set text(value:String):void {
		_text = value;
		_textField.text = value;
		dispatchChangeEvent();
	}
	public function get selectionBeginIndex():int {
		return _textField.selectionBeginIndex;
	}
	public function get selectionEndIndex():int {
		return _textField.selectionEndIndex;
	}
	
	public function get scrollV():int { return _textField.scrollV; }
	public function set scrollV(value:int):void {
		_textField.scrollV = value;
	}
	public function get scrollH():int { return _textField.scrollH; }
	public function set scrollH(value:int):void {
		_textField.scrollH = value;
	}
	
	public function set selectionColor(value:uint):void 
	{
		_selectionColor = value;
	}
	
	public function get textField():TextField { return _textField; }
	
	public function getCharBoundaries(index:int):Rectangle {
		return _textField.getCharBoundaries(index);
	}
	
	public function setSelection(beginIndex:int, endIndex:int):void {
		_textField.setSelection(beginIndex, endIndex);
	}
	public function replaceText(beginIndex:int, endIndex:int, newText:String):void {
		_textField.replaceText(beginIndex, endIndex, convertNewlines(newText));
	}
	public function replaceSelectedText(newText:String):void {
		_textField.replaceSelectedText(newText);
	}
	psycode_internal function setTextFormat(format:TextFormat, beginIndex:int=-1, endIndex:int=-1):void {
		_textField.setTextFormat(format, beginIndex, endIndex);
	}
	psycode_internal function resetFocus():void {
		stage.focus = _textField;
	}
	
	protected function dispatchChangeEvent():void {
		_textField.dispatchEvent(new Event(Event.CHANGE, true));
	}
	
	
	private function onMouseDown(e:MouseEvent):void 
	{
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	}
	
	private function onMouseUp(e:MouseEvent):void 
	{
		stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	}
	
	private function onMouseMove(e:MouseEvent):void 
	{
		drawSelection(_textField.selectionBeginIndex, _textField.selectionEndIndex);
		draw();
	}
	
	/* abstruct */
	protected function drawErrorMessages():void {}
	
	private function drawSelection(begin:int, end:int):void {
		return;
		
		//trace("drawSelection", begin, end);
		if (_currentSelectionBeginIndex == begin && _currentSelectionEndIndex == end) return;
		
		_selectionGraphic.graphics.clear();
		if (begin < end) {
			_currentSelectionBeginIndex = begin;
			_currentSelectionEndIndex = end;
			
			//trace("drawSelection");
			_selectionGraphic.graphics.beginFill(_selectionColor);
			var firstLine:int = _textField.getLineIndexOfChar(begin);
			var endLine:int = _textField.getLineIndexOfChar(end);
			
			//trace("firstLine:", firstLine, "endLine:", endLine);
			
			var scrollIndex:int = _textField.getLineOffset(_textField.scrollV - 1) + _textField.scrollH;
			var rect0:Rectangle = getCharBoundaries(begin);
			
			//trace("begin", rect0);
			
			var rect1:Rectangle = getCharBoundaries(end - 1);
			
			//trace("end", rect1);
			
			var rect2:Rectangle = getCharBoundaries(scrollIndex);
			rect0.x += _textField.x + 2;
			rect0.y += _textField.y + 2;
			rect1.x += _textField.x + 2;
			rect1.y += _textField.y + 2;
			rect0.x -= rect2.x;
			rect1.x -= rect2.x;
			rect0.y -= rect2.y;
			rect1.y -= rect2.y;
			
			var top:Number;
			var bottom:Number;
			top = rect0.top;
			top = (top > rect1.top) ? rect1.top : top;
			bottom = rect0.bottom;
			bottom = (bottom < rect1.bottom) ? rect1.bottom : bottom;
			if (firstLine == endLine) {
				_selectionGraphic.graphics.drawRect(rect0.left, top, rect1.right - rect0.left, bottom - top);
			} else {
				_selectionGraphic.graphics.drawRect(rect0.left, top, _textField.width - rect0.left, rect0.height);
				_selectionGraphic.graphics.drawRect(0, rect1.top, rect1.right, rect1.height);
				top += rect0.height;
				bottom = rect1.top;
				_selectionGraphic.graphics.drawRect(0, top, width, bottom - top);
			}
		}
		
		function getCharBoundaries($charIndex:int):Rectangle {
			var rect:Rectangle = _textField.getCharBoundaries($charIndex);
			var line:int = _textField.getLineIndexOfChar($charIndex);
			var tlm:TextLineMetrics = _textField.getLineMetrics(line);
			
			if (!rect) {
				rect = new Rectangle;
				rect.x = _textField.x + tlm.width + tlm.x;
				rect.y = tlm.height * line;
			}
			
			rect.y += tlm.descent;
			
			return rect;
		}
	}
	
	
	protected function draw():void {
		graphics.clear();
		graphics.beginFill(0x222222);
		graphics.drawRect(0, 0, width, height);
		
		_frameSprite.graphics.clear();
		_frameSprite.graphics.beginFill(0x222222);
		_frameSprite.graphics.drawRect(0, 0, linumField.width, scrollBarH.height);
		_frameSprite.graphics.drawRect(scrollBarH.x + scrollBarH.width, 0, scrollBarV.width, scrollBarH.height);
		_frameSprite.graphics.endFill();
		
		drawErrorMessages();
	}
	

	protected override function updateSize():void {
		_liveCodingController.width = width - scrollBarV.width;
		linumField.height = height - _liveCodingController.height;
		linumField.y = _liveCodingController.height;
		
		_textField.x = linumField.width;
		_textField.y = _liveCodingController.height;
		_textField.width = width - scrollBarV.width - linumField.width;
		_textField.height = height - scrollBarH.height - _liveCodingController.height;
		
		scrollBarV.x = width - scrollBarV.width;
		scrollBarV.y = _liveCodingController.height;
		scrollBarV.height = height - scrollBarH.height -_liveCodingController.height;
		
		scrollBarH.x = linumField.width;
		scrollBarH.y = height - scrollBarH.height;
		scrollBarH.width = width - scrollBarV.width - linumField.width;
		_frameSprite.y = scrollBarH.y;
		
		linumField.updateLinePos(true);
		draw();
	}
}	
}