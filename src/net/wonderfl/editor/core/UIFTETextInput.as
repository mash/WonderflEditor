package net.wonderfl.editor.core 
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import net.wonderfl.editor.ime.IMEClient_10_0;
	import net.wonderfl.editor.ime.IMEClient_10_1;
	import net.wonderfl.editor.manager.ClipboardManager;
	import net.wonderfl.editor.manager.EditManager;
	import net.wonderfl.editor.manager.IKeyboadEventManager;
	import net.wonderfl.editor.manager.SelectionManager;
	import net.wonderfl.editor.utils.versionTest;
	import net.wonderfl.editor.we_internal;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class UIFTETextInput extends UIFTETextField
	{
		private static var MATCH:Object = {
			')' : '(', ']' : '[', '」' : '「', '）' : '（', '｝' : '｛', '】' : '【', '〉' : '〈', '］': '［',
			'》' : '《', '』' : '『'
		}
		we_internal var _imeField:TextField;
		private var _selectionManager:SelectionManager;
		private var _clipboardManager:ClipboardManager;
		private var _imeManager:IKeyboadEventManager;
		private var _plugins:Vector.<IKeyboadEventManager>;
		private var _editManager:EditManager;
		use namespace we_internal;

		public function UIFTETextInput() 
		{
			super();
			
			_selectionManager = new SelectionManager(this);
			_editManager = new EditManager(this);
			
			_plugins = new Vector.<IKeyboadEventManager>;
			
			_imeField = new TextField;
			_imeField.height = boxHeight;
			_container.addChild(_imeField);
			_container.addChild(cursor);
			if (versionTest(10, 1)) {
				_imeField.type = TextFieldType.DYNAMIC;
				_imeManager = new IMEClient_10_1(this);
			} else {
				_imeField.type = TextFieldType.INPUT;
				_imeManager = new IMEClient_10_0(this);
			}
			
			addEventListener(TextEvent.TEXT_INPUT, onInputText);
			addEventListener(Event.CUT, onCut);
			addEventListener(Event.PASTE, onPaste);
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function addPlugIn($plugin:IKeyboadEventManager):void {
			_plugins.push($plugin);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function ():void {
				if (stage.focus != _imeField && _imeManager.imeMode) {
					trace('focus -> _imeField');
					resetIMETFPosition();
					stage.focus = _imeField;
				}
			});
			stage.focus = this;
		}
		
		override protected function onKeyDown(e:KeyboardEvent):void
		{
			//resetIMETFPosition();
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
				dispatchChange();
				return;
			}
			else if (c == 'y' && e.ctrlKey)
			{
				redo();
				dispatchChange();
				return;
			}
			
			if (k == Keyboard.CONTROL || k == Keyboard.SHIFT || e.keyCode == 3/*ALT*/ || e.keyCode == Keyboard.ESCAPE)
				return;
			
			var len:int = _plugins.length;
			for (i = 0; i < len; ++i) {
				if (_plugins[i].keyDownHandler(e))
					return;
			}
			
			cursor.visible = !_imeManager.keyDownHandler(e);
			
			if (_editManager.keyDownHandler(e)) {
				_preventDefault = true;
				dispatchChange();
				return;
			}
			
			_selectionManager.keyDownHandler(e);
			//resetIMETFPosition();
		}
		
		public function preventFollowingTextInput():void {
			_preventDefault = true;
		}
		
		protected function onInputText(e:TextEvent):void
		{
			if (_preventDefault) return;
			
			if (e.text in MATCH) {
				findPreviousMatch(MATCH[e.text], e.text, _caret)
			}
			
			replaceSelection(e.text);
			_setSelection(_caret, _caret);
			saveLastCol();
			checkScrollToCursor();
			
			dispatchChange();
			
			e.stopPropagation();
		}
		
		override protected function drawComplete():Boolean 
		{
			resetIMETFPosition();
			
			return false;
		}
		
		public function resetIMETFPosition():void {
			if (_imeManager.imeMode) {
				var point:Point = getPointForIndex(_caret);
				_imeField.x = point.x - 2;
				_imeField.y = point.y - 2;
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
					dispatchChange();
				}
			} catch (e:SecurityError) { };//can't paste
		}
		
		private function onCut(e:Event=null):void
		{
			onCopy();
			replaceSelection('');
			dispatchChange();
		}
	}

}