package net.wonderfl.editor.core 
{
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
	import flash.utils.clearTimeout;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import net.wonderfl.editor.IEditor;
	import net.wonderfl.editor.we_internal;
	import net.wonderfl.editor.manager.IKeyboadEventManager;
	import net.wonderfl.editor.manager.KeyDownProxy;
	import net.wonderfl.editor.manager.SelectionManager;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class UIFTETextField extends FTETextField implements IEditor
	{
		internal var lastCol:int = 0;
		private var extChar:int;
		private var prevMouseUpTime:int = 0;
		private var _downKey:int = -1;
		private var _keyIntervalID:uint;
		private var _keyTimeOut:uint;
		private var _keyWatcher:Function;
		private var _this:UIFTETextField;
		protected var _preventDefault:Boolean;
		protected var _selectionManager:SelectionManager;
		protected var _plugins:Vector.<IKeyboadEventManager>;
		
		use namespace we_internal;
		
		public function UIFTETextField() 
		{
			super();
			_selectionManager = new SelectionManager(this);
			_plugins = new Vector.<IKeyboadEventManager>;
			
			focusRect = false;
			_this = this;
			
			new KeyDownProxy(this, onKeyDown, [Keyboard.DOWN, Keyboard.UP, Keyboard.PAGE_DOWN, Keyboard.PAGE_UP, Keyboard.LEFT, Keyboard.RIGHT, 66, 70]);
			addEventListener(FocusEvent.KEY_FOCUS_CHANGE, function(e:FocusEvent):void {
				e.preventDefault();
				e.stopImmediatePropagation();
			});
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			
			addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			
			
			addEventListener(Event.COPY, onCopy);
			addEventListener(Event.SELECT_ALL, onSelectAll);
		}
		
		public function setScrollYByBar($value:int):void {
			_igonoreCursor = true;
			scrollY = $value;
		}
		
		private function onDoubleClick():void {
			var pos:int = getIndexForPoint(new Point(mouseX, mouseY));
			_setSelection(findWordBound(pos, true), findWordBound(pos, false), true);
		}
		
		public function findWordBound(start:int, left:Boolean):int
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
			setScrollYByBar(_scrollY - e.delta);
		}
				
		public function onCopy(e:Event=null):void
		{
			if (_selStart != _selEnd)
				Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, _text.substring(_selStart, _selEnd));
		}
		
		public function onSelectAll(e:Event):void
		{
			trace('select all '+ _text.length);
			_setSelection(0, _text.length, true);
		}
		
		public function onMouseDown(e:MouseEvent):void
		{
			var p:Point = new Point;
			
			p.x = mouseX; p.y = mouseY;
			var dragStart:int;
			if (e.shiftKey)
			{
				dragStart = _caret;
				_setSelection(dragStart, getIndexForPoint(p), true);
			}
			else
			{
				dragStart = getIndexForPoint(p);
				_setSelection(dragStart, dragStart, true);
			}
			
			stage.addEventListener(Event.ENTER_FRAME, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			//var IID:int = setInterval(intervalScroll, 30);
			var scrollDelta:int = 0;
			var prevMouse:Point = new Point(NaN);
			
			function onMouseMove(e:Event):void
			{
				if (mouseY < 0)
					scrollDelta = -1;
				else if (mouseY > height)
					scrollDelta = 1;
				else
					scrollDelta = 0;
					
				if (scrollDelta != 0) {
					setScrollYByBar(_scrollY + scrollDelta);
				}
				
				p.x = mouseX; p.y = mouseY;
				if (!p.equals(prevMouse)) {
					_setSelection(dragStart, getIndexForPoint(p));
					prevMouse = p.clone();
				}
			}
			
			function onMouseUp(e:MouseEvent):void
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				stage.removeEventListener(Event.ENTER_FRAME, onMouseMove);
				
				var t:int = getTimer();
				if (t - prevMouseUpTime < 250) {
					onDoubleClick();
					prevMouseUpTime = t;
					return;
				}
				prevMouseUpTime = t;
				p.x = mouseX; p.y = mouseY;
				_setSelection(dragStart, getIndexForPoint(p), true);
				//clearInterval(IID);
				_selectionManager.saveLastCol();
			}
			
			function intervalScroll():void
			{
				if (scrollDelta != 0)
				{
					scrollY += scrollDelta;
					p.x = mouseX; p.y = mouseY;
					_setSelection(dragStart, getIndexForPoint(p));
				}
			}
		}
		
		protected function onKeyDown(e:KeyboardEvent):void
		{
			_preventDefault = false;
			var c:String = String.fromCharCode(e.charCode);
			var k:int = e.keyCode;
			var i:int;
			if (k == Keyboard.INSERT && e.ctrlKey)
			{
				onCopy();
			}
			
			if (k == Keyboard.CONTROL || k == Keyboard.SHIFT || e.keyCode == 3/*ALT*/)
				return;
			
			var len:int = _plugins.length;
			for (i = 0; i < len; ++i) {
				if (_plugins[i].keyDownHandler(e))
					return;
			}
			
			_selectionManager.keyDownHandler(e);
		}
		
		override public function _setSelection(beginIndex:int, endIndex:int, caret:Boolean = false):void 
		{
			super._setSelection(beginIndex, endIndex, caret);
			
			stage.focus = this;
		}
	}

}