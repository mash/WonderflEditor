package ro.victordramba.scriptarea
{
	import com.victordramba.console.debug;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	/*import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;*/
	
	public class ScriptAreaEvents extends ScriptArea
	{
		private var lastCol:int = 0;		
		private var extChar:int;
		private var inputTF:TextField;
		
		public function ScriptAreaEvents()
		{
			doubleClickEnabled = true;
			focusRect = false;
			
			inputTF = new TextField;
			inputTF.type = TextFieldType.INPUT;
			inputTF.addEventListener(TextEvent.TEXT_INPUT, onInputText);
			var me:ScriptAreaEvents = this;
			inputTF.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent):void {
				if (stage) stage.focus = me;
			});
			
			
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			addEventListener(FocusEvent.KEY_FOCUS_CHANGE, function(e:FocusEvent):void {
				e.preventDefault();
				e.stopImmediatePropagation();
			});
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			addEventListener(FocusEvent.FOCUS_IN, function(e:FocusEvent):void {
				cursor.alpha = 1;
			});
			
			
			addEventListener(FocusEvent.FOCUS_OUT, function(e:FocusEvent):void {
				if (e.relatedObject != inputTF)
					cursor.alpha = 0;
			});
			
			addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			
			addEventListener(MouseEvent.DOUBLE_CLICK, function(e:Event):void {
				var pos:int = getIndexForPoint(new Point(mouseX, mouseY));
				_setSelection(findWordBound(pos, true), findWordBound(pos, false), true);
			});
			
			addEventListener(Event.CUT, onCut);
			addEventListener(Event.COPY, onCopy);
			addEventListener(Event.PASTE, onPaste);
			addEventListener(Event.SELECT_ALL, onSelectAll);
			
			addEventListener(MouseEvent.ROLL_OVER, function(e:MouseEvent):void {
				Mouse.cursor = MouseCursor.IBEAM;
			});
			addEventListener(MouseEvent.ROLL_OUT, function(e:MouseEvent):void {
				Mouse.cursor = MouseCursor.AUTO;
			});
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
		
		private function onMouseWheel(e:MouseEvent):void
		{
			scrollY -= e.delta;
			e.preventDefault();//this both don't work :((, the html page still scrolls
			e.stopImmediatePropagation();
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
		
		private function onCopy(e:Event=null):void
		{
			if (_selStart != _selEnd)
				Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, _text.substring(_selStart, _selEnd));
		}
		private function onCut(e:Event=null):void
		{
			onCopy();
			replaceSelection('');
			dipatchChange();
		}
		private function onSelectAll(e:Event):void
		{
			_setSelection(0, _text.length, true);
		}
		
		public function onMouseDown(e:MouseEvent):void
		{
			var dragStart:int;
			if (e.shiftKey)
			{
				dragStart = _caret;
				_setSelection(dragStart, getIndexForPoint(new Point(mouseX, mouseY)), true);
			}
			else
			{
				dragStart = getIndexForPoint(new Point(mouseX, mouseY));
				_setSelection(dragStart, dragStart, true);
			}
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			var IID:int = setInterval(intervalScroll, 30);
			var scrollDelta:int = 0;
			
			function onMouseMove(e:MouseEvent):void
			{
				if (mouseY < 0)
					scrollDelta = -1;
				else if (mouseY > height)
					scrollDelta = 1;
				else
					scrollDelta = 0;
				_setSelection(dragStart, getIndexForPoint(new Point(mouseX, mouseY)));
			}
			
			function onMouseUp(e:MouseEvent):void
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				_setSelection(dragStart, getIndexForPoint(new Point(mouseX, mouseY)), true);
				clearInterval(IID);
				saveLastCol();
			}
			
			function intervalScroll():void
			{
				if (scrollDelta != 0)
				{
					scrollY += scrollDelta;
					_setSelection(dragStart, getIndexForPoint(new Point(mouseX, mouseY)));
				}
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void
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
			
			/*if (extChar==0 && e.charCode > 127)
			{
				extChar = e.charCode;
				return;
			}
				
			if (extChar > 0)
			{
				c = Util.decodeUTF(e.charCode, extChar);
				extChar = 0;
			}*/
			
			
			
			
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
					//extend selection to full lines
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
			//else if (e.ctrlKey) return;
			else if (e.charCode!=0)
			{
				//replaceSelection(c);
				//dipatchChange();
				
				//don't capture CTRL+Key
				if (e.ctrlKey && !e.altKey) return;
				captureInput();
				return;
			}
			else return;

			if (!e.shiftKey && k!=Keyboard.TAB)
				_setSelection(_caret, _caret);
				
			updateCaret();
			
			//save last column
			if (k!=Keyboard.UP && k!=Keyboard.DOWN && k!=Keyboard.TAB)
				saveLastCol();
			
			checkScrollToCursor();
			e.updateAfterEvent();
			
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
		
		private function captureInput():void
		{
			if (stage && stage.focus == this)
				stage.focus = inputTF;
		}
		
		private function onInputText(e:TextEvent):void
		{
			replaceSelection(e.text);
			_setSelection(_caret, _caret);
			updateCaret();
			saveLastCol();
			checkScrollToCursor();
			e.preventDefault();
			if (stage) stage.focus = this;
			dipatchChange();				
		}
		
		private function saveLastCol():void
		{
			lastCol = _caret - _text.lastIndexOf(NL, _caret-1) - 1;
		}
		
		private function dipatchChange():void
		{
			dispatchEvent(new Event(Event.CHANGE, true, false));
		}
	}
}
