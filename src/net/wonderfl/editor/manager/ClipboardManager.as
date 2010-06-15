package net.wonderfl.editor.manager 
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import net.wonderfl.editor.core.UIFTETextField;
	
	/**
	 * @author kobayashi-taro
	 */
	public class ClipboardManager implements IKeyboadEventManager
	{
		private static var _this:ClipboardManager;
		private var _editable:Boolean;
		private var _field:UIFTETextField;
		private var _keyMap:Object;
		
		public static function getInstance():ClipboardManager { return _this; }
		public function ClipboardManager($field:UIFTETextField, $editable:Boolean = false) 
		{
			_field = $field;
			_editable = $editable;
			_this = this;
			_keyMap = { };
			_keyMap[Keyboard.INSERT] = copy
		}
		
		public function keyDownHandler($event:KeyboardEvent):Boolean
		{
			var handled:Boolean = false;
			var operation:Function;
			
			if ($event.ctrlKey) {
				operation = _keyMap[$event];
				if (operation != null) operation();
			}
			
			return handled;
		}
		
		public function copy():void {
			if (_field.selectionBeginIndex != _field.selectionEndIndex) {
				try {
					var text:String = _field.text.substring(_field.selectionBeginIndex, _field.selectionEndIndex);
					text = (Capabilities.os.indexOf('Windows') != -1) ? text.replace(/\n/gm, "\r\n") : text;
					Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, text);
				} catch (e:SecurityError) {}// cannot copy
			}
		}
		
		public function cut():void {
			copy();
			_field.replaceSelection('');
			_field.dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function paste():void {
			try {
				if (!Clipboard.generalClipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)) return;
				var str:String = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
				if (str)
				{
					_field.replaceSelection(str);
					_field.dispatchEvent(new Event(Event.CHANGE));
				}
			} catch (e:SecurityError) { };//can't paste
		}
		
	}

}