package jp.psyark.psycode.core 
{
import flash.display.Shape;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextFieldAutoSize;
import flash.text.TextLineMetrics;
import flash.utils.setTimeout;
import jp.psyark.psycode.controls.UIControl;
import jp.psyark.psycode.controls.TextScrollBar;
import jp.psyark.psycode.controls.ScrollBar;
import jp.psyark.psycode.core.linenumber.LineNumberView;
import jp.psyark.utils.callLater;
import jp.psyark.utils.convertNewlines;
import jp.psyark.utils.CodeUtil;

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
 * TextEditAreaクラスは、テキストフィールド・行番号・スクロールバーなど
 * テキスト編集UIの基本的な機能を提供し、それらの実装を隠蔽します。
 */
public class TextEditUI extends UIControl {
	private var linumField:LineNumberView;
	private var scrollBarV:TextScrollBar;
	private var scrollBarH:TextScrollBar;
	protected var textField:TextField;
	
	private var TAB_STOP_RATIO:Number = 2.42;
	private var _selectionGraphic:Shape;
	private var _selectionColor:uint = 0x694644;
	public var fileRef:FileReference;
	private var _currentSelectionBeginIndex:int = -2;
	private var _currentSelectionEndIndex:int = -2;
	
	
	/**
	 * TextEditUIクラスのインスタンスを初期化します。
	 */
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
		
		textField = new TextField();
		textField.multiline = true;
		textField.background = false;
		textField.alwaysShowSelection = false;
		textField.type = TextFieldType.INPUT;
		textField.defaultTextFormat = fmt;
		textField.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, function (event:FocusEvent):void {
			event.preventDefault();
		});
		
		textField.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		
		fmt.align = TextFormatAlign.RIGHT;
		fmt.color = 0x666666;
		
		linumField = new LineNumberView(textField);
		linumField.setTextFormat(fmt);
		linumField.addEventListener(Event.RESIZE, linumResizeHandler);
		
		scrollBarV = new TextScrollBar(textField);
		scrollBarH = new TextScrollBar(textField, ScrollBar.HORIZONTAL);
		
		addChild(_selectionGraphic);
		addChild(textField);
		addChild(linumField);
		addChild(scrollBarV);
		addChild(scrollBarH);
		
		updateSize();
		
		textField.addEventListener(Event.SCROLL, textFieldScrollHandler);
	}
	
	
	public function getLineOffset(lineIndex:int):int {
		return textField.getLineOffset(lineIndex);
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
	
	public function save():void {
		var localName:String = CodeUtil.getDefinitionLocalName(text);
		localName ||= "untitled";
		fileRef = new FileReference();
		fileRef.save(text, localName + ".as");
	}
	
	public function setFontSize(fontSize:Number):void {
		var tabStops:Array = [];
		for (var i:int=1; i<20; i++) {
			tabStops.push(i * fontSize * 2.42);
		}
		
		var fmt:TextFormat = textField.defaultTextFormat;
		fmt.size = fontSize;
		fmt.tabStops = tabStops;
		textField.defaultTextFormat = fmt;
		
		fmt.align = TextFormatAlign.RIGHT;
		fmt.color = 0x666666;
		linumField.setTextFormat(fmt);
		
		fmt = new TextFormat();
		fmt.size = fontSize;
		fmt.tabStops = tabStops;
		textField.setTextFormat(fmt);
		
		dispatchChangeEvent();
	}
	
	
	private function textFieldScrollHandler(event:Event):void {
		dispatchEvent(event);
		drawSelection(selectionBeginIndex, selectionEndIndex);
	}
	
	private function linumResizeHandler(event:Event):void {
		updateSize();
	}
	
	
	/**
	 * テキストフィールドへのアクセスを提供します
	 */
	
	public function get lineNumWidth():int {
		return textField.x;
	}
	public function get text():String {
		return textField.text;
	}
	public function set text(value:String):void {
		textField.text = value;
		dispatchChangeEvent();
	}
	public function get selectionBeginIndex():int {
		return textField.selectionBeginIndex;
	}
	public function get selectionEndIndex():int {
		return textField.selectionEndIndex;
	}
	
	public function get scrollV():int { return textField.scrollV; }
	public function set scrollV(value:int):void {
		textField.scrollV = value;
	}
	public function get scrollH():int { return textField.scrollH; }
	public function set scrollH(value:int):void {
		textField.scrollH = value;
	}
	
	public function set selectionColor(value:uint):void 
	{
		_selectionColor = value;
	}
	
	public function getCharBoundaries(index:int):Rectangle {
		return textField.getCharBoundaries(index);
	}
	
	public function setSelection(beginIndex:int, endIndex:int):void {
		textField.setSelection(beginIndex, endIndex);
		drawSelection(beginIndex, endIndex);
	}
	public function replaceText(beginIndex:int, endIndex:int, newText:String):void {
		textField.replaceText(beginIndex, endIndex, convertNewlines(newText));
	}
	public function replaceSelectedText(newText:String):void {
		textField.replaceSelectedText(newText);
	}
	psycode_internal function setTextFormat(format:TextFormat, beginIndex:int=-1, endIndex:int=-1):void {
		textField.setTextFormat(format, beginIndex, endIndex);
	}
	psycode_internal function resetFocus():void {
		stage.focus = textField;
	}
	
	protected function dispatchChangeEvent():void {
		textField.dispatchEvent(new Event(Event.CHANGE, true));
	}
	
	
	private function onMouseDown(e:MouseEvent):void 
	{
		trace("mouse down");
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
		drawSelection(textField.selectionBeginIndex, textField.selectionEndIndex);
	}
	
	private function drawSelection(begin:int, end:int):void {
		return;
		
		//trace("drawSelection", begin, end);
		if (_currentSelectionBeginIndex == begin && _currentSelectionEndIndex == end) return;
		
		_selectionGraphic.graphics.clear();
		if (begin < end) {
			_currentSelectionBeginIndex = begin;
			_currentSelectionEndIndex = end;
			
			trace("drawSelection");
			_selectionGraphic.graphics.beginFill(_selectionColor);
			var firstLine:int = textField.getLineIndexOfChar(begin);
			var endLine:int = textField.getLineIndexOfChar(end);
			
			//trace("firstLine:", firstLine, "endLine:", endLine);
			
			var scrollIndex:int = textField.getLineOffset(textField.scrollV - 1) + textField.scrollH;
			var rect0:Rectangle = getCharBoundaries(begin);
			
			//trace("begin", rect0);
			
			var rect1:Rectangle = getCharBoundaries(end - 1);
			
			//trace("end", rect1);
			
			var rect2:Rectangle = getCharBoundaries(scrollIndex);
			rect0.x += textField.x + 2;
			rect0.y += textField.y + 2;
			rect1.x += textField.x + 2;
			rect1.y += textField.y + 2;
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
				_selectionGraphic.graphics.drawRect(rect0.left, top, textField.width - rect0.left, rect0.height);
				_selectionGraphic.graphics.drawRect(0, rect1.top, rect1.right, rect1.height);
				top += rect0.height;
				bottom = rect1.top;
				_selectionGraphic.graphics.drawRect(0, top, width, bottom - top);
			}
		}
		
		function getCharBoundaries($charIndex:int):Rectangle {
			var rect:Rectangle = textField.getCharBoundaries($charIndex);
			var line:int = textField.getLineIndexOfChar($charIndex);
			var tlm:TextLineMetrics = textField.getLineMetrics(line);
			
			if (!rect) {
				rect = new Rectangle;
				rect.x = textField.x + tlm.width + tlm.x;
				rect.y = tlm.height * line;
			}
			
			rect.y += tlm.descent;
			
			return rect;
		}
	}
	
	
	
	/**
	 * エディタのレイアウトを更新します。
	 */
	protected override function updateSize():void {
		linumField.height = height;
		textField.x = linumField.width;
		textField.width = width - scrollBarV.width - linumField.width;
		textField.height = height - scrollBarH.height;
		scrollBarV.x = width - scrollBarV.width;
		scrollBarV.height = height - scrollBarH.height;
		scrollBarH.x = linumField.width;
		scrollBarH.y = height - scrollBarH.height;
		scrollBarH.width = width - scrollBarV.width - linumField.width;
		graphics.clear();
		graphics.beginFill(0x222222);
		graphics.drawRect(0, 0, width, height);
		drawSelection(textField.selectionBeginIndex, textField.selectionEndIndex);
	}
}	
}