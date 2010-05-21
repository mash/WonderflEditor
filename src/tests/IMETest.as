package  
{
	/**
	 * an experimental code to implement
	 * inline ime at the flash player level
	 * (inline ime is not supported for tlf)
	 * http://forums.adobe.com/message/2057505#2057505
	 * 
	 * this sample only works for FP 10.0
	 *
	 * @author kobayashi-taro
	 * 
	 */
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.IMEEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.system.IME;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.setTimeout;
	
	public class IMETest extends Sprite 
	{
		private var _imeInlineInput:TextField;
		private var _tf:TextField;
		private var _sp:Sprite;
		private var _imeMode:Boolean;
		private var _defaultInputTarget:InteractiveObject;
		private var _caret:int;
		private var _text:String = '';
		private var _selEnd:int;
		private var _selStart:int;
		private var NL:String = '\n';
		private var lastCol:int;
		private var _lineHeight:int;
		
		public function IMETest() 
		{
			_tf = new TextField;
			_tf.mouseEnabled = false;
			//_tf.type = TextFieldType.INPUT;
			_tf.multiline = true;
			_tf.textColor = 0xffffff;
			_sp = new Sprite;
			
			_tf.text = ' ';
			var rect:Rectangle = _tf.getCharBoundaries(0);
			_tf.text = '';
			_lineHeight = rect.height;
			
			
			_imeInlineInput = new TextField;
			_imeInlineInput.type = TextFieldType.INPUT;
			_imeInlineInput.background = true;
			_imeInlineInput.textColor = 0xffffff;
			_imeInlineInput.backgroundColor = 0x333333;
			//_imeInlineInput.alpha = 0.3;
			_imeInlineInput.height = _lineHeight;
			_imeInlineInput.addEventListener(FocusEvent.FOCUS_OUT, imeFocusOut);
			_imeInlineInput.addEventListener(TextEvent.TEXT_INPUT, onIMETextInput);
			
			_imeMode = (IME.conversionMode != "ALPHANUMERIC_HALF");
			
			addChild(_tf);
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function imeFocusOut(e:FocusEvent):void 
		{
			if (stage.focus != _defaultInputTarget)
				stage.focus = _defaultInputTarget;
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			_defaultInputTarget = this;
			
			_defaultInputTarget.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_defaultInputTarget.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			_defaultInputTarget.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
//			_sp.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_defaultInputTarget.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			//_defaultInputTarget.addEventListener(IMEEvent.IME_COMPOSITION, imeComposition);
			_defaultInputTarget.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusChange);
			_defaultInputTarget.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			// 10.1
			addEventListener("imeStartComposition", imeStartCompositionHandler);
			_defaultInputTarget.addEventListener(TextEvent.TEXT_INPUT, onTextInput);
			focusRect = false;
			
			System.ime.addEventListener(IMEEvent.IME_COMPOSITION, imeComposition);
			
			addChild(_sp);
			addChild(_tf);
			addChild(_imeInlineInput);
			_imeInlineInput.visible = _imeMode;
				
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function ():void {
				if (stage.focus != _defaultInputTarget && !_imeMode) {
					stage.focus = _defaultInputTarget;
				} else if (stage.focus != _imeInlineInput && _imeMode) {
					stage.focus = _imeInlineInput;
				}
				//if (stage.focus != _defaultInputTarget)
					//stage.focus = _defaultInputTarget;
			});
			stage.focus = this;
			//setTimeout(function ():void {
				//stage.focus = _sp;
			//}, 200);
			
			stage.addEventListener(Event.RESIZE, onResize);
			stage.dispatchEvent(new Event(Event.RESIZE));
		}
		
		private function onTextInput(e:TextEvent):void 
		{
			replaceSelection(e.text);
			//_setSelection(_caret, _caret);
			//resetInlineInputFook();
			setTimeout(resetInlineInputFook, 50);
		}
		
		private function resetInlineInputFook():void {
			var i:int = Math.max(_selStart - 1, 0);
			var rect:Rectangle = _tf.getCharBoundaries(i);
			
			if (rect == null) { // this occurs when the previous char is '\n'
				var l:int = _tf.getLineIndexOfChar(i);
				trace(l);
				rect = new Rectangle(2, _lineHeight * (1 + l));
				
			}
			
			_imeInlineInput.x = rect.x + rect.width;
			_imeInlineInput.y = rect.y;
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			stage.focus = this;
		}
		
		private function onMouseOver(e:MouseEvent):void 
		{
			Mouse.cursor = MouseCursor.IBEAM;
		}
		
		private function onMouseOut(e:MouseEvent):void 
		{
			Mouse.cursor = MouseCursor.ARROW;
		}
		
		private function onFocusIn(e:FocusEvent):void 
		{
			//log(e.type, e.keyCode);
			//e.preventDefault();
		}
		
		private function onKeyFocusChange(e:FocusEvent):void 
		{
			log(e.type, e.keyCode);
		}
		
		private function onKeyUp(e:KeyboardEvent):void 
		{
			//log(e.type, e.keyCode);
		}
		
		private function imeStartCompositionHandler(e:IMEEvent):void 
		{
			
		}
		
		private function imeComposition(e:IMEEvent):void 
		{
			log(e.type, e.text);
			if (stage.focus == _imeInlineInput) {
				_imeMode = false;
				_imeInlineInput.text = '';
				_imeInlineInput.visible = false;
				stage.focus = _defaultInputTarget;
				resetInlineInputFook();
				trace(e);
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			var k:int = e.keyCode;
			resetInlineInputFook();
			
			if (k == Keyboard.BACKSPACE) { // deletes a char before selection
				var i:int = _selStart - 1;
				i = (i < 0) ? 0 : i;
				replaceText(i, _selEnd, '');
				return;
			} else if (k == Keyboard.ENTER) { // add enter
				replaceSelection('');
				return;
			}
			
			if (IME.enabled && IME.conversionMode != "ALPHANUMERIC_HALF") {
				if (!_imeMode) {
					_imeMode = true;
					_imeInlineInput.text = '';
					_imeInlineInput.visible = true;
					if (stage.focus != _imeInlineInput)
						stage.focus = _imeInlineInput;
				}
				log(e.type, e.keyCode);
			} else if (_imeMode) {
				_imeMode = false;
				_imeInlineInput.visible = false;
				stage.focus = _defaultInputTarget;
				if (k == Keyboard.CONTROL || k == Keyboard.SHIFT || e.keyCode == 3/*ALT*/ || e.keyCode == Keyboard.ESCAPE)
					return;
				//handleKeyEvent(e);
			}
		}
		
		public function replaceText(startIndex:int, endIndex:int, text:String):void
		{
			text = text.replace(/\r\n/g, NL);
			text = text.replace(/\r/g, NL);
			
			//undoBuff.push({s:startIndex, e:startIndex+text.length, t:_text.substring(startIndex, endIndex)});
			//redoBuff.length = 0;
			//_replaceText(startIndex, endIndex, text);
			_tf.replaceText(startIndex, endIndex, text);
			_selEnd = _selStart = startIndex + text.length;
		}
		
		private function saveLastCol():void
		{
			lastCol = _caret - _text.lastIndexOf(NL, _caret-1) - 1;
		}
		public function replaceSelection(text:String):void
		{
			replaceText(_selStart, _selEnd, text);
			
			//FIXME filter text
			//_setSelection(_selStart+text.length, _selStart+text.length, true);
		}
		
		private function dipatchChange():void
		{
			
		}
		
		private function updateCaret():void
		{
			_tf.setSelection(_caret, _caret);
		}
		
		private function checkScrollToCursor():void
		{
			
		}
		
		private function _setSelection(beginIndex:int, endIndex:int, caret:Boolean = false):void
		{
			_selStart = beginIndex;
			_selEnd = endIndex;
			//_tf.setSelection(beginIndex, endIndex);
			if (caret) {
				_caret = _selEnd
			}
			setTimeout(_tf.setSelection, 0, beginIndex, endIndex);
		}
		
		public function get length():int { return _text.length; }
		
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
		
		private function onIMETextInput(e:TextEvent):void 
		{
			log('imeMode', e.text);
			_imeMode = false;
			_imeInlineInput.visible = false;
			//_imeInlineInput.removeEventListener(TextEvent.TEXT_INPUT, onIMETextInput);
			//stage.focus = this;
		}
		//
		private function log(...args):void {
			//_tf.appendText(args + '\n');
			//_tf.scrollV = _tf.maxScrollV;
			trace(args);
			//ExternalInterface.call('console.log', args);
		}
		
		private function onResize(e:Event):void 
		{
			log(e.type);
			_imeInlineInput.width = stage.stageWidth;
			_tf.width = stage.stageWidth;
			_tf.height = stage.stageHeight;
			_sp.graphics.clear();
			_sp.graphics.beginFill(0);
			_sp.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_sp.graphics.endFill();
		}
		
	}

}