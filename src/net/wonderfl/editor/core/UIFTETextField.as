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
	import net.wonderfl.editor.ITextArea;
	import net.wonderfl.editor.we_internal;
	import net.wonderfl.editor.manager.ClipboardManager;
	import net.wonderfl.editor.manager.IKeyboadEventManager;
	import net.wonderfl.editor.manager.KeyDownProxy;
	import net.wonderfl.editor.manager.SelectionManager;
	import net.wonderfl.editor.utils.bind;
	import org.libspark.ui.SWFWheel;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class UIFTETextField extends FTETextField implements ITextArea
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
		protected var _clipboardManager:ClipboardManager;
		private var _double:Boolean;
		
		use namespace we_internal;
		
		public function UIFTETextField() 
		{
			super();
			_selectionManager = new SelectionManager(this);
			_plugins = new Vector.<IKeyboadEventManager>;
			_plugins.push(_clipboardManager = new ClipboardManager(this));
			
			focusRect = false;
			_this = this;
			
			new KeyDownProxy(this, onKeyDown, [Keyboard.DOWN, Keyboard.UP, Keyboard.PAGE_DOWN, Keyboard.PAGE_UP, Keyboard.LEFT, Keyboard.RIGHT, 66, 70]);
			addEventListener(FocusEvent.KEY_FOCUS_CHANGE, function(e:FocusEvent):void {
				e.preventDefault();
				e.stopImmediatePropagation();
			});
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(Event.ADDED_TO_STAGE, function __init():void {
				removeEventListener(Event.ADDED_TO_STAGE, __init);
				stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			});
			addEventListener(MouseEvent.MOUSE_OVER, function ():void {
				Mouse.cursor = MouseCursor.IBEAM;
			});
			
			
			addEventListener(Event.COPY, bind(_clipboardManager.copy));
			addEventListener(Event.SELECT_ALL, onSelectAll);
		}
		
		public function addPlugIn($plugin:IKeyboadEventManager):void {
			_plugins.push($plugin);
		}
		
		
		public function setScrollYByBar($value:int):void {
			_igonoreCursor = true;
			scrollY = $value;
		}
		
		private function onDoubleClick():void {
			_double = true;
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
				
		public function onSelectAll(e:Event):void
		{
			_setSelection(0, _text.length, true);
		}
		
		public function onMouseDown(e:MouseEvent):void
		{
			var p:Point = new Point;
			
			we_internal::_preventHScroll = true;
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
				we_internal::_preventHScroll = true;
				
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
				we_internal::_preventHScroll = true;
				
				var t:int = getTimer();
				if (t - prevMouseUpTime < 250) {
					if (_double) {
						onTrippleClick();
					} else {
						onDoubleClick();
					}
					prevMouseUpTime = t;
					return;
				}
				
				_double = false;
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
		
		override protected function drawComplete():Boolean { 
			SWFWheel.item = this;
			return false;
		}
		
		private function onTrippleClick():void
		{
			_double = false;
			_selectionManager.selectCurrentLine();
		}
		
		protected function onKeyDown(e:KeyboardEvent):void
		{
			_preventDefault = false;
			var k:int = e.keyCode;
			var i:int;
			
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