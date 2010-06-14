package net.wonderfl.editor.manager 
{
	import flash.events.KeyboardEvent;
	import flash.net.FileReference;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import jp.psyark.utils.CodeUtil;
	import net.wonderfl.editor.core.FTETextField;
	import net.wonderfl.editor.core.UIFTETextField;
	import net.wonderfl.editor.minibuilder.ASParserController;
	import net.wonderfl.editor.utils.isMXML;
	import ro.minibuilder.main.editor.Location;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class EditorHotkeyManager implements IKeyboadEventManager
	{
		private var _field:UIFTETextField;
		private var _savePositions:Vector.<int>;
		private var _parser:ASParserController;
		private var _lastCol:int;
		private var fileRef:FileReference;
		
		public function EditorHotkeyManager($field:UIFTETextField, $parser:ASParserController) 
		{
			_field = $field;
			_parser = $parser;
			_savePositions = new Vector.<int>;
		}
		
		public function keyDownHandler($event:KeyboardEvent):Boolean
		{
			var result:Boolean = true;
			var char:String = String.fromCharCode($event.charCode);
			
			switch($event.keyCode) {
			case Keyboard.F3:
				searchWord($event.shiftKey);
				break;
			case Keyboard.F4:
				if ($event.shiftKey)
					gotoPreviousPosition();
				else
					gotoDefinition();
				break;
			default:
				if ($event.ctrlKey) {
					return handleKeybinds($event);
				} else 
					result = false;
				break;
			}
			
			return result;
		}
		
		private function handleKeybinds($event:KeyboardEvent):Boolean
		{
			var result:Boolean = true;
			switch($event.keyCode) {
			case 66: // Ctrl + B
				prevChar();
				break;
			case 68: // Ctrl + D
				deleteNextChar();
				break;
			case 70: // Ctrl + F
				nextChar();
				break;
			case 74: // Ctrl + J
				handleJ($event);
				break;
			case 78: // Ctrl + N
				nextLine();
				break;
			case 80: // Ctrl + P
				previousLine();
				break;
			case 83: // Ctrl + S
				saveCode();
				break;
			default : 
				result = false;
			}
			
			return result;
		}
		
		public function saveCode():void
		{
			var text:String = (Capabilities.os.indexOf('Windows') != -1) ? _field.text.replace(/\n/g, '\r\n') : _field.text;
			var localName:String = CodeUtil.getDefinitionLocalName(text);
			localName ||= "untitled";
			fileRef = new FileReference();
			fileRef.save(text, localName + (isMXML(text) ? ".mxml" : ".as"));
		}
		
		private function previousLine():void
		{
			var caret:int = _field.caretIndex;
			var i:int = _field.text.lastIndexOf(FTETextField.NL, caret - 1);
			var lineBegin:int = i;
			if (i != -1)
			{
				i = _field.text.lastIndexOf(FTETextField.NL, i - 1);
				if (i != -1) caret = i + 1;
				else caret = 0;
				
				//restore col
				if (lineBegin - caret > _lastCol)
					caret += _lastCol;
				else
					caret = lineBegin;
			}
			
			_field.setSelection(caret, caret);
		}
		
		private function nextLine():void
		{
			var caret:int = _field.caretIndex;
			var i:int = _field.text.indexOf(FTETextField.NL, caret);
			if (i != -1) { 
				caret = i + 1;
			
				i = _field.text.indexOf(FTETextField.NL, caret);
				if (i == -1) i = _field.length;
				
				//restore col
				if (i - caret > _lastCol)
					caret += _lastCol;
				else
					caret = i;
			}
			
			_field.setSelection(caret, caret);
		}
		
		private function deleteNextChar():void
		{
			var caret:int = _field.caretIndex;
			if (caret < _field.length) _field.replaceText(caret, caret + 1, '');
		}
		
		private function handleJ($event:KeyboardEvent):void {
			var i:int = _field.text.lastIndexOf(FTETextField.NL, _field.caretIndex - 1); 
			var str:String = _field.text.substring(i + 1, _field.caretIndex).match(/^\s*/)[0];
			if (_field.text.charAt(_field.caretIndex - 1) == '{') str += '    ';
			_field.replaceSelection(FTETextField.NL + str);	
		}
		
		private function prevChar():void
		{
			if (_field.caretIndex > 0) {
				_field.setSelection(_field.caretIndex - 1, _field.caretIndex - 1);
			}
		}
		
		private function nextChar():void
		{
			if (_field.caretIndex < _field.length - 1) {
				_field.setSelection(_field.caretIndex + 1, _field.caretIndex + 1);
			}
		}
		
		private function searchWord($reverse:Boolean):void
		{
			var word:String;
			var start:int;
			var end:int;
			var temp:int;
			if (_field.selectionBeginIndex != _field.selectionEndIndex) {
				start = _field.selectionBeginIndex;
				end = _field.selectionEndIndex;
				
				if (end < start) {
					temp = end;
					end = start;
					start = temp;
				}
				
			} else {
				start = _field.findWordBound(_field.caretIndex, true);
				end = _field.findWordBound(_field.caretIndex, false);
			}
			word = _field.text.substring(start, end);
			
			var pos:int;
			if ($reverse) {
				pos = _field.text.lastIndexOf(word, start - 1);
				if (pos > -1) {
					_field.setSelection(pos, pos + word.length);
				} else {
					pos = _field.text.lastIndexOf(word, _field.length);
					if (pos > - 1)
						_field.setSelection(pos, pos + word.length);
				}
			} else {
				pos = _field.text.indexOf(word, end + 1);
				if (pos > -1) {
					_field.setSelection(pos, pos + word.length);
				} else {
					pos = _field.text.indexOf(word, 0);
					if (pos > - 1)
						_field.setSelection(pos, pos + word.length);
				}
			}
		}
		
		private function gotoPreviousPosition():void
		{
			if (_savePositions.length) {
				var pos:int = _savePositions.pop();
				_field.setSelection(pos, pos);
			}
		}
		
		private function clearSavePositions():void
		{
			_savePositions.length = 0;
		}
		
		private function gotoDefinition():void
		{
			if (_savePositions.length > 4) _savePositions.shift();
			
			var location:Location = _parser.findDefinition(_field.caretIndex);
			if (location) {
				_savePositions.push(_field.caretIndex);
				_field.setSelection(location.pos, location.pos);
			}
		}
		
	}

}