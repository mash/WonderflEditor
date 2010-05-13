package net.wonderfl.editor.livecoding 
{
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextLineMetrics;
import net.wonderfl.editor.TextArea;
/**
 * ...
 * @author kobayashi-taro
 */
public class TextArea extends net.wonderfl.editor.TextArea
{
	private var _caret:Caret;
	private var _caretIndex:int;
	private var _selectionBeginIndex:int;
	private var _selectionEndIndex:int;
	private var _caretPos:Point;
	private var _caretSprite:Sprite;
	private var _selectionColor:uint = 0x663333;
	
	//private var _trace:Function;

	public function TextArea() 
	{
		addChild(_caretSprite = new Sprite);
		_caretSprite.addChild(_caret = new Caret(15, 0xffffff));
		_caret.x = textField.x;
		_caret.y = textField.y;
		_caret.hide();
		
		scrollBarH.addEventListener(Event.CHANGE, onChange);
		//scrollBarV.addEventListener(Event.CHANGE, onChange);
	}
	
	public function hideCaret():void { _caret.hide(); }
	
	private function onChange(e:Event):void 
	{
		//setSelection(selectionBeginIndex, selectionEndIndex);
	}
	
	public function setSelection($selectionBeginIndex:int, $selectionEndIndex:int):void {
		var b:int, bb:Rectangle;
		var e:int, eb:Rectangle;
		var graphics:Graphics = _selectionGraphics;
		_selectionBeginIndex = $selectionBeginIndex;
		_selectionEndIndex = $selectionEndIndex;
		
		graphics.clear();
		
		if ($selectionBeginIndex == $selectionEndIndex) {
			showCaret($selectionBeginIndex);
			return;
		}
		
		//_caret.hide();
		
		if ($selectionBeginIndex < $selectionEndIndex) {
			b = $selectionBeginIndex;
			e = $selectionEndIndex;
		} else {
			b = $selectionEndIndex;
			e = $selectionBeginIndex;
		}
		_selectionBeginIndex = b;
		_selectionEndIndex = _caretIndex = e;
		bb = safeCharBoundaries(b);
		eb = safeCharBoundaries(e);
		

		
		e = (e == textField.length) ? --e : e;
		
		b = textField.getLineIndexOfChar(b);
		e = textField.getLineIndexOfChar(e);
		
		//trace("line offsets", $selectionBeginIndex, $selectionEndIndex, b, e, bb, eb, text.substr($selectionBeginIndex, 10), text.substring($selectionEndIndex - 10, $selectionEndIndex));
		
		graphics.beginFill(_selectionColor);
		
		// assert b <= e
		if (b < e) {
			//trace(bb, eb);
			graphics.drawRect(bb.x, bb.y, width - bb.x, bb.height);
			graphics.drawRect(0, bb.y + bb.height, width, eb.y - bb.y - bb.height);
			graphics.drawRect(0, eb.y, eb.x, eb.height);
		} else { // b == c
			graphics.drawRect(bb.x, bb.y, eb.x - bb.x, bb.height);
		}
		
		
		graphics.endFill();
		
		showCaret(_caretIndex);
	}
	
	private function safeCharBoundaries(i:int):Rectangle {
		var rect:Rectangle;
		var line:int;
		i = (i < 0) ? 0 : i;
		if (i < textField.length) {
			rect = textField.getCharBoundaries(i);
			line = textField.getLineIndexOfChar(i);
		} else {
			line = textField.numLines - 1;
		}
		var tlm:TextLineMetrics;
		if (!rect) {
			//trace('rect not specified');
			tlm = textField.getLineMetrics(line);
			rect = new Rectangle;
			rect.x = tlm.width + 2;
			rect.height = tlm.height;
			rect.y = linumField.getLinePos(line) + 2;
		}
		
		rect.x += textField.x;
		
		return rect;
	}
	
	private function getCaretPos(i:int):Point {
		var rect:Rectangle = safeCharBoundaries(i);
		return rect ? rect.topLeft : new Point;
	}	
	
	private function showCaret(i:int):void
	{
		var rect:Rectangle = safeCharBoundaries(i);
		var pos:Point = rect.topLeft;
		_caret.x = pos.x;
		_caret.y = pos.y;
		_caret.setSize(1, rect.height);
		_caret.show();
	}
	
	override protected function draw():void 
	{
		super.draw();
		
		if (_caretSprite)
		_caretSprite.y = _selectionArea.y = -linumField.getLinePos(_textField.scrollV - 1);
	}
}

}