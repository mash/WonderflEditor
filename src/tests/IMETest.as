package  
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IMEEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.ime.CompositionAttributeRange;
	import flash.text.ime.IIMEClient;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class IMETest extends Sprite implements IIMEClient
	{
		private var _col:int;
		private var _view:TextField;
		private var _log:TextField = new TextField;
		private var _caretIndex:int;
		private var NL:String = '\r';
		private var _this:IMETest;
		private var _imeLength:int;
		private var _imeField:TextField;
		private var _selectionAnchorIndex:int;
		private var _selectionActiveIndex:int;
		
		public function IMETest() 
		{
			_this = this;
			_view = new TextField;
			addChild(_view);
			_log.border = true;
			_log.borderColor = 0;
			addChild(_log);
			_imeField = new TextField;
			_imeField.width = 0;
			_imeField.height = 0;
			addChild(_imeField);
			//_imeField.background = true;	
			//_imeField.backgroundColor = 0xff0000;
			//_imeField.textColor = 0xffffff;
			caretIndex = 0;
			
			addEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			addEventListener(TextEvent.TEXT_INPUT, onTextInput);
			addEventListener("imeStartComposition", imeStartCompositionHandler)
		}
		
		public function set caretIndex($value:int):void {
			_caretIndex = $value;
			
			var rect:Rectangle;
			// does not handle caret after breaking
			if ($value < 0) {
				rect = new Rectangle;
			} else if ($value >= _view.length) {
				$value = _view.length - 1;
				
				if ($value < 0) {
					rect = new Rectangle;
				} else {
					rect = _view.getCharBoundaries($value);
					rect.x += rect.width;
				}
			} else {
				rect = _view.getCharBoundaries($value);
			}
			
			graphics.clear();
			graphics.beginFill(0x999999);
			graphics.drawRect(rect.x, rect.y, 12, 16);
			graphics.endFill();
			
			_imeField.x = rect.x;
			_imeField.y = rect.y - 2;
		}
		
		private function imeStartCompositionHandler(e:IMEEvent):void 
		{	
			log(e);
			if (!e["imeClient"]) {
				e["imeClient"] = this;
			}
		}
		
		private function log(...args):void {
			_log.appendText(args + '\n');
			_log.scrollV = _log.maxScrollV;
		}
		
		private function onTextInput(e:TextEvent):void 
		{
			log(<>onTextInput : [{e.text}]</>);
			_view.replaceSelectedText(e.text);
			caretIndex = _caretIndex + e.text.length;
			_imeField.text = "";
			_imeField.width = 0;
			_imeField.height = 0;
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			stage.focus = this;
			stage.addEventListener(Event.RESIZE, onResize);
			stage.dispatchEvent(new Event(Event.RESIZE));
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, function ():void {
				//if (stage.focus != _this) stage.focus = _this;
			//});
		}
		
		private function onResize(e:Event):void 
		{
			var ratio:Number = 0.4;
			
			_view.width = stage.stageWidth * ratio;
			_view.height = stage.stageHeight;
			_log.x = _view.width;
			_log.width = stage.stageWidth * (1.0 - ratio);
			_log.height = _view.height;
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			log(<>keyCode : {e.keyCode}</>);
			switch (e.keyCode) {
			case Keyboard.DOWN:
				handleDownKey(e);
				break;
			case Keyboard.UP:
				handleUpKey(e);
				break;
			}
		}
		
		private function handleDownKey($event:KeyboardEvent):void
		{
			calcCol();
			var i:int = _view.text.indexOf(NL, _caretIndex) + 1;
			i += _col;
			i = (i >= _view.text.length) ? _view.text.length - 1 : 1;
			_caretIndex = (i < 0) ? 0 : i;
		}
		
		private function handleUpKey($event:KeyboardEvent):void
		{
			calcCol();
			var i:int = _view.text.lastIndexOf(NL, _caretIndex - 1) + 1;
			i += _col;
			i = (i >= _view.text.length) ? _view.text.length - 1 : 1;
			_caretIndex = (i < 0) ? 0 : i;
		}
		
		private function calcCol():void {
			var i:int = _view.text.lastIndexOf(NL, _caretIndex - 1);
			i = (i < 0) ? 0 : i;
			_col = _caretIndex - i;
		}
		
		
		/* INTERFACE flash.text.ime.IIMEClient */
		
		public function get compositionStartIndex():int
		{
			log(<>compositionStartIndex</>);
			return 0;
		}
		
		public function get compositionEndIndex():int
		{
			log(<>compositionEndIndex</>);
			return 0;
		}
		
		public function get verticalTextLayout():Boolean
		{
			return false;
		}
		
		public function get selectionAnchorIndex():int
		{
			log(<>selectionAnchorIndex</>);
			return _selectionAnchorIndex;
		}
		
		public function get selectionActiveIndex():int
		{
			log(<>selectionActiveIndex</>);
			return _selectionActiveIndex;
		}
		
		public function updateComposition(text:String, attributes:Vector.<CompositionAttributeRange>, compositionStartIndex:int, compositionEndIndex:int):void
		{
			_imeLength = text.length;
			_selectionAnchorIndex = compositionStartIndex;
			var len:int = attributes.length;
			var attr:CompositionAttributeRange;
			log(<>text : {text}, start : {compositionStartIndex}, end : {compositionEndIndex}</>);
			var textRuns:Array = [];
			for (var i:int = 0; i < len; ++i) 
			{
				attr = attributes[i];
				log(<>i : {i}, relativeStart : {attr.relativeStart}, relativeEnd : {attr.relativeEnd}</>);
				//
				var run:String = text.substring(attr.relativeStart, attr.relativeEnd);
				if (compositionStartIndex == attr.relativeStart) {
					run = '<u>' + run + '</u>';
					_selectionActiveIndex = attr.relativeEnd;
				}
				textRuns.push(run);
			}
			
			_imeField.htmlText = '<font color="#ffffff">' + textRuns.join('') + '</font>';
			_imeField.width = _imeField.textWidth + 4;
			_imeField.height = _imeField.textHeight + 4;
		}
		
		// called when the user has confirmed the word
		public function confirmComposition(text:String = null, preserveSelection:Boolean = false):void
		{
			log(<>confirmComposition text : {text}, preserveSelection : {preserveSelection}</>);
		}
		
		public function getTextBounds(startIndex:int, endIndex:int):Rectangle
		{
			if (startIndex < 0 || endIndex < 0 || startIndex > _imeField.length || endIndex > _imeField.length) return new Rectangle;
			log(<>getTextBounds start : {startIndex}, end : {endIndex}</>);
			
			var startPoint:Point = _imeField.getCharBoundaries(startIndex).topLeft;
			var endCharBoundaries:Rectangle = _imeField.getCharBoundaries(endIndex);
			var endPoint:Point = endCharBoundaries.bottomRight;
			var rect:Rectangle = new Rectangle;
			rect.topLeft = startPoint.add(new Point(0, endCharBoundaries.height));
			rect.bottomRight = endPoint;
			
			log(_imeField.text.substring(startIndex, endIndex), rect);
			return rect;
		}
		
		public function selectRange(anchorIndex:int, activeIndex:int):void
		{
			log(<>selectRange anchorIndex : {anchorIndex}, activeIndex : {activeIndex}</>);
		}
		
		public function getTextInRange(startIndex:int, endIndex:int):String
		{
			log(<>getTextInRange start : {startIndex}, end : {endIndex}</>);
			if (startIndex < 0 || startIndex >= _view.length || endIndex < 0 || endIndex >= _view.length) return null;
			
			if (endIndex < startIndex) {
				var tempIndex:int = endIndex;
				endIndex = startIndex;
				startIndex = tempIndex;
			}
			
			return _view.text.substring(startIndex, endIndex);
		}
		
	}

}