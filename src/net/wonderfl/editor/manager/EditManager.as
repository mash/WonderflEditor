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
	public class EditManager
	{
		private var _field:FTETextField;
		private var _text:String;
		private var _selStart:int;
		private var _selEnd:int;
		private var _caret:int;
		private var _length:int;
		
		public function EditManager($field:FTETextField) 
		{
			_field = $field;
		}
		
		public function keyDownHandler($event:KeyboardEvent):Boolean {
			var k:int = $event.keyCode;
			var c:String = String.fromCharCode($event.charCode);
			var handled:Boolean = true;
			_text = _field.we_internal::_text;
			_selStart = _field.we_internal::_selStart;
			_selEnd = _field.we_internal::_selEnd;
			_caret = _field.we_internal::_caret;
			_length = _text.length;
			
			switch (k) {
			case Keyboard.DELETE:
				handleDeleteKey($event);
				break;
			case Keyboard.BACKSPACE:
				handleBackspaceKey($event);
				break;
			case Keyboard.ENTER:
				handleEnterKey($event);
				break;
			case Keyboard.TAB:
				handleTabKey($event);
				break;
			default:
				if (c == '}') {
					handleRightCurlyBrace($event);
				} else
					handled = false;
				break;
			}
			
			return handled;
		}
		
		private function handleDeleteKey($event:KeyboardEvent):void
		{
			if (_caret < _length && _selStart == _selEnd)
				_field.replaceText(_caret, _caret + 1, '');
			else {
				_field.replaceSelection('');
			}	
		}
		
		private function handleBackspaceKey($event:KeyboardEvent):void
		{
			if (_caret > 0 && _selStart == _selEnd)
			{
				_field.replaceText(_caret - 1, _caret, '');
				_caret--;
				_field.setSelection(_caret, _caret);
			}
			else
				_field.replaceSelection('');
		}
		
		private function handleEnterKey($event:KeyboardEvent):void {
			var i:int = _text.lastIndexOf(FTETextField.NL, _caret - 1); 
			var str:String = _text.substring(i + 1, _caret).match(/^\s*/)[0];
			if (_text.charAt(_caret - 1) == '{') str += '    ';
			_field.replaceSelection(FTETextField.NL + str);
		}
		
		private function handleRightCurlyBrace($event:KeyboardEvent):void {
			var i:int = 1;
			var lastLeftOne:int = _field.findPreviousMatch('{', '}', _caret);
			
			var lastNL:int = _text.lastIndexOf(FTETextField.NL, _caret - 1);
			if (_text.charAt(_caret - 1).match(/\s/) && lastLeftOne > -1 && lastNL > lastLeftOne) {
				i = _text.lastIndexOf(FTETextField.NL, lastLeftOne);
				var str:String = _text.substring(i + 1, lastLeftOne).match(/^\s*/)[0] + '}';
				_field.replaceText(lastNL + 1, _caret, str);
				i = lastNL + 1 + str.length;
				_field.setSelection(i, i);
			} else {
				_field.replaceSelection('}');
			}
		}
		
		private function handleTabKey($event:KeyboardEvent):void
		{
			if (_text.substring(_selStart, _selEnd).indexOf(FTETextField.NL) == -1 && !$event.shiftKey)
			{
				_field.replaceSelection('    ');
			}
			else
			{
				var end:int = _text.indexOf(FTETextField.NL, _selEnd-1);
				if (end == -1) end = _text.length - 1;
				var begin:int = _text.lastIndexOf(FTETextField.NL, _selStart - 1) + 1;
				var str:String = _text.substring(begin, end);
				
				if ($event.shiftKey)
					str = str.replace(/\n    /g, FTETextField.NL).replace(/^    /, '');
				else
					str = '    ' + str.replace(new RegExp(FTETextField.NL, 'g'), FTETextField.NL+'    ');
				
				_field.replaceText(begin, end, str);
				_field.setSelection(begin, begin + str.length + 1);
			}
		}
	}

}