package net.wonderfl.editor.core 
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import net.wonderfl.editor.manager.ClipboardManager;
	import net.wonderfl.editor.manager.EditManager;
	import net.wonderfl.editor.manager.IMEManager;
	import net.wonderfl.editor.manager.SelectionManager;
	import net.wonderfl.editor.we_internal;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class UIFTETextInput extends UIFTETextField
	{
		private var _selectionManager:SelectionManager;
		private var _clipboardManager:ClipboardManager;
		private var _imeManager:IMEManager;
		private var _editManager:EditManager;
		use namespace we_internal;

		public function UIFTETextInput() 
		{
			super();
			
			
			_selectionManager = new SelectionManager(this);
			_editManager = new EditManager(this);
			
			addEventListener(Event.CUT, onCut);
			addEventListener(Event.PASTE, onPaste);
		}
		
		override protected function onKeyDown(e:KeyboardEvent):void
		{
			_preventDefault = false;
//			trace('onKeyDown _caret : ' + _caret + ' keyCode : ' + e.keyCode + <>_selStart : {_selStart} _selEnd : {_selEnd}</>);
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
			else if (c == 'z' && e.ctrlKey)
			{
				undo();
				dipatchChange();
				return;
			}
			else if (c == 'y' && e.ctrlKey)
			{
				redo();
				dipatchChange();
				return;
			}
			
			if (k == Keyboard.CONTROL || k == Keyboard.SHIFT || e.keyCode == 3/*ALT*/ || e.keyCode == Keyboard.ESCAPE)
				return;
				
			if (_editManager.keyDownHandler(e)) {
				_preventDefault = true;
				dipatchChange();
				return;
			}
			
			_selectionManager.keyDownHandler(e);
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