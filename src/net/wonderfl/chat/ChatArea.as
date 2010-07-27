package net.wonderfl.chat 
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import net.wonderfl.component.core.UIComponent;
	import net.wonderfl.component.scroll.VScrollBar;
	import net.wonderfl.font.FontSetting;
	import net.wonderfl.utils.bind;
	import net.wonderfl.utils.listenOnce;
	import net.wonderfl.utils.removeFromParent;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ChatArea extends UIComponent
	{
		private var _messages:Array = [];
		private var _scrollV:int;
		private var _scroll:VScrollBar;
		private var _maxScrollV:int;
		private var _pageSize:int;
		private var _prevMouseUpTime:int;
		private var _prevMouseCursor:String = MouseCursor.ARROW;
		private var _itemContainer:Sprite;
		private var _drag:Boolean;
		private var _this:ChatArea;
		
		public function ChatArea() 
		{
			listenOnce(this, Event.ADDED_TO_STAGE, init);
		}
		
		private function init():void
		{
			addChild(_itemContainer = new Sprite);
			
			_this = this;
			focusRect = false;
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			addEventListener(MouseEvent.ROLL_OVER, onThisRollOver);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			addEventListener(Event.COPY, onCopy);
			addEventListener(MouseEvent.MOUSE_WHEEL, function (e:MouseEvent):void {
				scrollV = _scrollV + e.delta;
			});
			
			var timer:Timer = new Timer(5000);
			timer.addEventListener(TimerEvent.TIMER, function ():void {
				_messages.forEach(function ($item:ChatMessage, $index:int, $array:Array):void {
					$item.updateTime();
				});
			});
			timer.start();
		}
		
		private function onCopy(e:Event):void 
		{
			var len:int = _messages.length;
			var message:ChatMessage;
			var selectedText:String = "";
			var selection:String;
			for (var i:int = 0; i < len; ++i) 
			{
				message = _messages[i];
				selection = message.getSelectedText();
				if (selection.length) {
					selectedText += selection;
				}
			}
			
			try {
				Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, selectedText);
			} catch (e:SecurityError) { trace(e); }
			
		}
		
		private function onThisRollOver(e:MouseEvent):void 
		{
			if (e.target === this) {
				_prevMouseCursor = Mouse.cursor;
				Mouse.cursor = MouseCursor.IBEAM;
			}
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			var p:Point = new Point(mouseX, mouseY);
			if (p.y < 0 || p.y > _height) return;
			var dragStart:Point = p.clone();
			var prevScrollV:int = _scrollV;
			
			if (!_drag) {
				_drag = true;
				stage.addEventListener(Event.ENTER_FRAME, onMouseMove);
			}
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

			var scrollDelta:int = 0;

			function onMouseMove(e:Event):void
			{
				if (mouseY < 0)
					scrollDelta = -1;
				else if (mouseY > _height)
					scrollDelta = 1;
				else
					scrollDelta = 0;

				if (scrollDelta != 0) scrollV = _scrollV + scrollDelta;

				p.x = mouseX; p.y = mouseY;
				setSelection(dragStart.subtract(new Point(0, FontSetting.LINE_HEIGHT * (_scrollV - prevScrollV))), p);
			}

			function onMouseUp(e:MouseEvent):void
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				stage.removeEventListener(Event.ENTER_FRAME, onMouseMove);
				_drag = false;
				
				var t:int = getTimer();
				if (t - _prevMouseUpTime < 250) {
					onDoubleClick();
					_prevMouseUpTime = t;
					return;
				}

				_prevMouseUpTime = t;
				p.x = mouseX; p.y = mouseY;
				setSelection(dragStart.subtract(new Point(0, FontSetting.LINE_HEIGHT * (_scrollV - prevScrollV))), p);
				if (stage.focus != _this)
					stage.focus = _this;
			}
		}
		
		private function setSelection($startPoint:Point, $endPoint:Point):void
		{
			trace("ChatArea.setSelection > $startPoint : " + $startPoint + ", $endPoint : " + $endPoint);
			var s:int = getTimer();
			var yMin:int = $startPoint.y;
			var yMax:int = $endPoint.y;
			
			if (yMax < yMin) {
				var t:int = yMin;
				yMin = yMax;
				yMax = t;
				var p:Point = $startPoint;
				$startPoint = $endPoint;
				$endPoint = p;
			}
			
			var len:int = _messages.length;
			var message:ChatMessage;
			var selectedMessages:Array = [];
			for (var i:int = 0; i < len; ++i) 
			{
				message = _messages[i];
				if (message.y + message.height > yMin && message.y < yMax) {
					selectedMessages.push(message);
				} else message.clearSelection();
			}
			
			if (!selectedMessages.length) return;
			var localize:Point;
			message = selectedMessages.shift();
			if (message) {
				localize = new Point(0, message.y);
				message.selectArea($startPoint.subtract(localize), $endPoint.subtract(localize));
			}
			if (!selectedMessages.length) return;
			message = selectedMessages.pop();
			if (message) {
				localize = new Point(0, message.y);
				message.selectArea($startPoint.subtract(localize), $endPoint.subtract(localize));
			}
			len = selectedMessages.length;
			for (i = 0; i < len; ++i) 
			{
				message = selectedMessages[i];
				message.selectAll();
			}
		}
		
		private function onDoubleClick():void {
			var len:int = _messages.length;
			var message:ChatMessage;
			for (var i:int = 0; i < len; ++i) {
				message = _messages[i];
				if (message.y + message.height > mouseY && message.y < mouseY) {
					message.onDoubleClick();
					break;
				}
			}
			//var pos:int = getIndexForPoint(new Point(mouseX, mouseY));
			//_setSelection(findWordBound(pos, true), findWordBound(pos, false), true);
		}
		
		public function appendItem($message:ChatMessage):void
		{
			$message.width = _width;
			_messages.unshift($message);
			
			calcMaxScrollV();
		}
		
		private function calcMaxScrollV():void
		{
			var len:int = _messages.length;
			var lines:int = 0;
			var message:ChatMessage;
			for (var i:int = 0; i < len; ++i) 
			{
				message = _messages[i];
				lines += message.height + FontSetting.LINE_HEIGHT;
			}
			
			lines = Math.ceil(lines / FontSetting.LINE_HEIGHT);
			
			_maxScrollV = (_pageSize < lines) ? lines - _pageSize : 0;
			++_maxScrollV;
			
			if (_maxScrollV > 1) {
				if (_scroll == null) {
					_scroll = new VScrollBar;
					_scroll.height = _height;
					_scroll.addEventListener(Event.SCROLL, onScroll);
					_scroll.addEventListener(MouseEvent.MOUSE_OVER, onScrollRollOver);
					_scroll.addEventListener(MouseEvent.MOUSE_OUT, onRollOut);
				}
				
				_scroll.x = _width - _scroll.width;
				_scroll.valueForPageSize = _pageSize;
				_scroll.valueForMinPos = 1;
				_scroll.valueForMaxPos = _maxScrollV;
				_scroll.height = _height;
				_scroll.drawHandle();
				
				if (!_scroll.parent) addChild(_scroll);
				updateMessageSize(_width - _scroll.width);
			} else if (_scroll && _scroll.parent) {
				removeChild(_scroll);
				updateMessageSize(_width);
			}
		}
		
		private function updateMessageSize($width:int):void {
			_messages.forEach(function ($item:ChatMessage, $index:int, $array:Array):void {
				$item.width = $width;
			});
		}
		
		private function onRollOut(e:MouseEvent):void 
		{
			Mouse.cursor = _prevMouseCursor;
		}
		
		private function onScrollRollOver(e:MouseEvent):void 
		{
			_prevMouseCursor = Mouse.cursor;
			Mouse.cursor = MouseCursor.BUTTON;
		}
		
		private function onScroll(e:Event):void 
		{
			scrollV = _scroll.value;
		}
		
		private function updateView():void {
			var len:int = _messages.length;
			var message:ChatMessage;
			var messageHeight:int;
			var yPos:int = -FontSetting.LINE_HEIGHT * (_scrollV - 1);
			trace("_scrollV : " + _scrollV);
			
			for (var i:int = 0; i < len; ++i) 
			{
				message = _messages[i];
				message.y = yPos;
				message.viewHeight = _height;
				messageHeight = message.height;
				
				if (message.parent) {
					if (yPos + messageHeight < 0 || yPos > _height) {
						_itemContainer.removeChild(message);
					}
				} else if (yPos + messageHeight >= 0 && yPos < _height) {
					_itemContainer.addChild(message);
				}
				message.updateView();
				
				yPos += messageHeight + FontSetting.LINE_HEIGHT;
			}
		}
		
		override protected function updateSize():void 
		{
			graphics.clear();
			graphics.beginFill(ChatStyle.CHAT_BACKGROUND);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
			
			_pageSize = (_height / FontSetting.LINE_HEIGHT) >> 0;
			calcMaxScrollV();
			updateView();
			
			trace("height : " + _height + " _pageSize : " + _pageSize);
			
			if (_scroll) _scroll.height = _height;
		}
		
		public function get scrollV():int { return _scrollV; }
		public function set scrollV(value:int):void 
		{
			value = (value < 1) ? 1 : value;
			value = (value > _maxScrollV) ? _maxScrollV : value;
			
			_scrollV = value;
			updateView();
		}
		
		public function get maxScrollV():int { return _maxScrollV; }
		public function get pageSize():int { return _pageSize; }
	}
}