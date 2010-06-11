package net.wonderfl.editor.manager 
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import net.wonderfl.editor.we_internal;
	import net.wonderfl.editor.core.FTETextField;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class SelectionManager
	{
		private var _field:FTETextField;
		private var NL:String =  '\n';
		private var _lastCol:int;
		private var _text:String;
		private var _caret:int;
		private var _selEnd:int;
		private var _selStart:int;
		private var _length:int;
		
		public function SelectionManager($field:FTETextField) 
		{
			_field = $field;
		}
		
		public function keyDownHandler($event:KeyboardEvent):Boolean {
			var k:int = $event.keyCode;
			var handled:Boolean = true;
			_text = _field.we_internal::_text;
			_selStart = _field.we_internal::_selStart;
			_selEnd = _field.we_internal::_selEnd;
			_caret = _field.we_internal::_caret;
			_length = _text.length;
			
			var tmp:int;
			if (_selStart > _selEnd) {
				tmp = _selStart;
				_selStart = _selEnd;
				_selEnd = tmp;
			}
			
			switch (k) {
			case Keyboard.LEFT:
				handleLeftArrow($event);
				break;
			case Keyboard.UP:
				handleUpArrow($event);
				break;
			case Keyboard.RIGHT:
				handleRightArrow($event);
				break;
			case Keyboard.DOWN:
				handleDownArrow($event);
				break;
			case Keyboard.HOME:
				handleHomeKey($event);
				break;
			case Keyboard.END:
				handleEndKey($event);
				break;
			case Keyboard.PAGE_DOWN:
				handlePageDownKey($event);
				break;
			case Keyboard.PAGE_UP:
				handlePageUpKey($event);
				break;
			default:
				handled = false;
				break;
			}
			
			

			
			//save last column
			if (k != Keyboard.UP && k != Keyboard.DOWN && k != Keyboard.TAB)
				saveLastCol();
			
			if (handled) {
				_field.we_internal::_caret = _caret;
				
				if (!$event.shiftKey && k != Keyboard.TAB) {
					//_field.we_internal::igonoreCursor = true;
					_field._setSelection(_caret, _caret, true);
				} else {
					_field.updateCaret();
					_field.we_internal::checkScrollToCursor();
				}
					
					//_field.updateCaret();
				//_field.we_internal::checkScrollToCursor();
			}
			
			return handled;
		}
		
		public function saveLastCol():void
		{
			_lastCol = _caret - _field.text.lastIndexOf(NL, _caret-1) - 1;
		}
		
		private function findWordBound(start:int, left:Boolean):int
		{
			if (left)
			{
				while (/\w/.test(_text.charAt(start))) start--;
				return start + 1;
			}
			else
			{ 
				while (/\w/.test(_text.charAt(start))) start++;
				return start;
			}
		}
		
		private function extendSel($left:Boolean):void
		{
			//trace("SelectionManager.extendSel > $left : " + $left);
			
			if ($left) {
				trace("_caret : " + _caret + ", _selStart : " + _selStart);
				if (_caret < _selStart)
					_field._setSelection(_caret, _selEnd);
				else
					_field._setSelection(_selStart, _caret);
			} else {
				if (_caret > _selEnd)
					_field._setSelection(_selStart, _caret);
				else
					_field._setSelection(_caret, _selEnd);
			}
		}
		
		private function handleLeftArrow($event:KeyboardEvent):void
		{
			if ($event.ctrlKey)
			{
				_caret = Math.max(0, findWordBound(_caret - 2, true));
				if ($event.shiftKey) extendSel(true);
			}
			else
			{
				//if we have a selection, goto begin of selection
				if (!$event.shiftKey && _selStart != _selEnd) 
					_caret = _selStart;
				else if (_caret > 0) {
					_caret -= 1;
					if ($event.shiftKey) extendSel(true);
				}
			}
		}
		
		private function handleUpArrow($event:KeyboardEvent):void
		{
			var i:int = _text.lastIndexOf(NL, Math.min(_selStart, _caret)-1);
			var lineBegin:int = i;
			if (i != -1)
			{
				i = _text.lastIndexOf(NL, i - 1);
				if (i != -1) _caret = i + 1;
				else _caret = 0;
				
				//restore col
				if (lineBegin - _caret > _lastCol)
					_caret += _lastCol;
				else
					_caret = lineBegin;
					
				if ($event.shiftKey) extendSel(true);
			}
		}
		
		private function handleRightArrow($event:KeyboardEvent):void
		{
			var re:RegExp;
			if ($event.ctrlKey) {
				re = /\b/g;
				re.lastIndex = _caret + 1;
				re.exec(_text);
				_caret = re.lastIndex;
			} else {
				//if we have a selection, goto end of selection
				if (!$event.shiftKey && _selStart != _selEnd)
					_caret = _selEnd;
				else if (_caret < _length) {
					_caret += 1;
				}
			}
			
			if ($event.shiftKey) extendSel(false);
		}
		
		private function handleDownArrow(e:KeyboardEvent):void
		{
			//look for next NL
			var i:int = _text.indexOf(NL, _caret);
			if (i != -1) { 
				_caret = i + 1;
			
				//line = lines[line.index+1];
				
				i = _text.indexOf(NL, _caret);
				if (i == -1) i = _text.length;
				
				//restore col
				if (i - _caret > _lastCol)
					_caret += _lastCol;
				else
					_caret = i;
					
				if (e.shiftKey) extendSel(false);
			}
		}
		
		private function handleHomeKey($event:KeyboardEvent):void
		{
			var i:int;
			if ($event.ctrlKey)
				_caret = 0;
			else
			{
				var start:int = i = _text.lastIndexOf(NL, _caret-1) + 1;
				var ch:String;
				while ((ch=_text.charAt(i))=='\t' || ch==' ') i++;
				_caret = _caret == i ? start : i;
			}
			if ($event.shiftKey) extendSel(true);
		}
		
		private function handleEndKey($event:KeyboardEvent):void
		{
			var i:int;
			if ($event.ctrlKey)
				_caret = _text.length;
			else
			{
				i = _text.indexOf(NL, _caret);
				_caret = i == -1 ? _text.length : i;
			}
			if ($event.shiftKey) extendSel(false);
		}
		
		private function handlePageDownKey($event:KeyboardEvent):void
		{
			for (var i:int = 0, pos:int = _caret; i <= _field.visibleRows; i++) 
			{
				pos = _text.indexOf(NL, pos+1);
				if (pos == -1)
				{
					_caret = _text.length;
					break;
				}
				_caret = pos+1;
			}
		}
		
		private function handlePageUpKey($event:KeyboardEvent):void
		{
			for (var i:int = 0, pos:int = _caret; i <= _field.visibleRows; i++) 
			{
				pos = _text.lastIndexOf(NL, pos - 1);
				if (pos == -1)
				{
					_caret = 0;
					break;
				}
				_caret = pos + 1;
			}
		}
		
		
	}
}