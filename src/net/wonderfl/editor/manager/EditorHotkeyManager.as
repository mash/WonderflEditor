package net.wonderfl.editor.manager 
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import net.wonderfl.editor.core.UIFTETextInput;
	import net.wonderfl.editor.minibuilder.ASParserController;
	import ro.minibuilder.main.editor.Location;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class EditorHotkeyManager implements IKeyboadEventManager
	{
		private var _field:UIFTETextInput;
		private var _savePositions:Vector.<int>;
		private var _parser:ASParserController;
		
		public function EditorHotkeyManager($field:UIFTETextInput, $parser:ASParserController) 
		{
			_field = $field;
			_parser = $parser;
			_savePositions = new Vector.<int>;
		}
		
		public function get imeMode():Boolean
		{
			return false;
		}
		
		public function keyDownHandler($event:KeyboardEvent):Boolean
		{
			var result:Boolean = true;
			
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
				result = false;
				break;
			}
			
			return result;
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