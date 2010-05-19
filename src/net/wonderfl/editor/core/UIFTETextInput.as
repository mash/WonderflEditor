package net.wonderfl.editor.core 
{
	import flash.events.KeyboardEvent;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class UIFTETextInput extends UIFTETextField
	{
		
		public function UIFTETextInput() 
		{
			addEventListener(Event.CUT, onCut);
			addEventListener(Event.PASTE, onPaste);
			
		}
		
		
		override protected function onKeyDown(e:KeyboardEvent):void 
		{
			super.onKeyDown(e);
			var c:String = String.fromCharCode(e.charCode);
			var k:int = e.keyCode;
			var i:int;
			if (k == Keyboard.INSERT && e.shiftKey)
			{
				onPaste();
			}
			
			else if (String.fromCharCode(e.charCode) == 'z' && e.ctrlKey)
			{
				undo();
				dipatchChange();
				return;
			}
			else if (String.fromCharCode(e.charCode) == 'y' && e.ctrlKey)
			{
				redo();
				dipatchChange();
				return;
			}
			
			super.onKeyDown(e);
			
			if (k == Keyboard.CONTROL || k == Keyboard.SHIFT || e.keyCode==3/*ALT*/ || e.keyCode==Keyboard.ESCAPE)
				return;
				
			var re:RegExp;
			var pos:int;
			
		}
		
		protected function onKeyDown(e:KeyboardEvent):void
		{
			var c:String = String.fromCharCode(e.charCode);
			var k:int = e.keyCode;
			var i:int;
			if (k == Keyboard.INSERT && e.ctrlKey)
			{
				onCopy();
			}
			else if (k == Keyboard.INSERT && e.shiftKey)
			{
				onPaste();
			}
			
			else if (String.fromCharCode(e.charCode) == 'z' && e.ctrlKey)
			{
				undo();
				dipatchChange();
				return;
			}
			else if (String.fromCharCode(e.charCode) == 'y' && e.ctrlKey)
			{
				redo();
				dipatchChange();
				return;
			}
			
			
			if (k == Keyboard.CONTROL || k == Keyboard.SHIFT || e.keyCode==3/*ALT*/ || e.keyCode==Keyboard.ESCAPE)
				return;
				
			//debug(e.charCode+' '+e.keyCode);
				
			//var line:TextLine = getLineAt(_caret);
			var re:RegExp;
			var pos:int;
			
			if (k == Keyboard.RIGHT)
			{
				if (e.ctrlKey)
				{
					re = /\b/g;
					re.lastIndex = _caret+1;
					re.exec(_text);
					_caret = re.lastIndex;
					if (e.shiftKey) extendSel(false);
				}
				else
				{
					//if we have a selection, goto end of selection
					if (!e.shiftKey && _selStart != _selEnd)
						_caret = _selEnd; 
					else if (_caret < length) {
						_caret += 1;
						if (e.shiftKey) extendSel(false);
					}
				}
			}
			else if (k == Keyboard.DOWN)
			{
				//look for next NL
				i = _text.indexOf(NL, _caret);
				if (i != -1)
				{ 
					_caret = i+1;
				
					//line = lines[line.index+1];
					
					i = _text.indexOf(NL, _caret);
					if (i==-1) i = _text.length;
					
					
					//restore col
					if (i - _caret > lastCol)
						_caret += lastCol;
					else
						_caret = i;
						
					if (e.shiftKey) extendSel(false);
				}
			}
			else if (k == Keyboard.UP)
			{
				i = _text.lastIndexOf(NL, _caret-1);
				var lineBegin:int = i;
				if (i != -1)
				{
					i = _text.lastIndexOf(NL, i-1);
					if (i != -1) _caret = i+1;
					else _caret = 0;
					
					//line = lines[line.index - 1];
					//_caret = line.start;
					
					//restore col
					if (lineBegin - _caret > lastCol)
						_caret += lastCol;
					else
						_caret = lineBegin;
						
					if (e.shiftKey) extendSel(true);
				}
			}
			else if (k == Keyboard.PAGE_UP)
			{
				for (i = 0, pos = _caret; i <= visibleRows; i++) 
				{
					pos = _text.lastIndexOf(NL, pos-1);
					if (pos == -1)
					{
						_caret = 0;
						break;
					}
					_caret = pos+1;
				}
			}
			else if (k == Keyboard.PAGE_DOWN)
			{
				for (i = 0, pos = _caret; i <= visibleRows; i++) 
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
			else if (k == Keyboard.LEFT)
			{
				if (e.ctrlKey)
				{
					_caret = Math.max(0, findWordBound(_caret-2, true));
					if (e.shiftKey) extendSel(true);
				}
				else
				{
					//if we have a selection, goto begin of selection
					if (!e.shiftKey && _selStart != _selEnd) 
						_caret = _selStart;
					else if (_caret > 0) {
						_caret -= 1;
						if (e.shiftKey) extendSel(true);
					}
				}
			}
			else if (k == Keyboard.HOME)
			{
				if (e.ctrlKey)
					_caret = 0;
				else
				{
					var start:int = i = _text.lastIndexOf(NL, _caret-1) + 1;
					var ch:String;
					while ((ch=_text.charAt(i))=='\t' || ch==' ') i++;
					_caret = _caret == i ? start : i;
				}
				if (e.shiftKey) extendSel(true);
			}
			else if (k == Keyboard.END)
			{
				if (e.ctrlKey)
					_caret = _text.length;
				else
				{
					i = _text.indexOf(NL, _caret);
					_caret = i == -1 ? _text.length : i;
				}
				if (e.shiftKey) extendSel(false);
			}
			else if (k == Keyboard.BACKSPACE)
			{
				if (_caret > 0 && _selStart == _selEnd)
				{
					replaceText(_caret-1, _caret, '');
					_caret--;
				}
				else
					replaceSelection('');
				dipatchChange();
			}
			else if (k == Keyboard.DELETE)
			{
				if (_caret < length && _selStart == _selEnd)
					replaceText(_caret, _caret+1, '');
				else
					replaceSelection('');
				dipatchChange();
			}
			else if (k == Keyboard.TAB)
			{
				if (_text.substring(_selStart, _selEnd).indexOf(NL) == -1 && !e.shiftKey)
				{
					replaceSelection('\t');
				}
				else
				{
					extend selection to full lines
					var end:int = _text.indexOf(NL, _selEnd-1);
					if (end == -1) end = _text.length-1;
					var begin:int = _text.lastIndexOf(NL, _selStart-1)+1;
					var str:String = _text.substring(begin, end);
					
					if (e.shiftKey)
						str = str.replace(/\r\s/g, '\r').replace(/^\s/, '');
					else
						str = '\t' + str.replace(/\r/g, '\r\t');
					
					replaceText(begin, end, str);
					_setSelection(begin, begin+str.length+1, true);
				}
				dipatchChange();
			}
			else if (k == Keyboard.ENTER)
			{
				i = _text.lastIndexOf(NL, _caret-1);
				str = _text.substring(i+1, _caret).match(/^\s*/)[0];
				if (_text.charAt(_caret-1) == '{') str += '\t';
				replaceSelection('\r'+str);
				dipatchChange();
			}
			else if (c == '}' && _text.charAt(_caret-1)=='\t')
			{
				replaceText(_caret-1, _caret, '}');
				dipatchChange();
			}
			else if (e.ctrlKey) return;
			else if (e.charCode!=0)
			{
				replaceSelection(c);
				dipatchChange();
				
				don't capture CTRL+Key
				if (e.ctrlKey && !e.altKey) return;
				captureInput();
				return;
			}
			else return;

			if (!e.shiftKey && k!=Keyboard.TAB)
				_setSelection(_caret, _caret);
			
			//save last column
			if (k!=Keyboard.UP && k!=Keyboard.DOWN && k!=Keyboard.TAB)
				saveLastCol();
			
			checkScrollToCursor();
			//e.updateAfterEvent();
			//captureInput();
			
			//local function
			function extendSel(left:Boolean):void
			{
				if (left)
				{
					if (_caret < _selStart)
						_setSelection(_caret, _selEnd);
					else
						_setSelection(_selStart, _caret);
				}
				else
				{
					if (_caret > _selEnd)
						_setSelection(_selStart, _caret);
					else
						_setSelection(_caret, _selEnd);
				}
			}
		}
		
		private function onPaste(e:Event=null):void
		{
			try {
				if (!Clipboard.generalClipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)) return;
				var str:String = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
				if (str)
				{
					replaceSelection(str);
					dipatchChange();
				}
			} catch (e:SecurityError) { };//can't paste
		}
		
		private function onCut(e:Event=null):void
		{
			onCopy();
			replaceSelection('');
			dipatchChange();
		}
	}

}