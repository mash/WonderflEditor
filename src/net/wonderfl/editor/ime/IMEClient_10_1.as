package net.wonderfl.editor.ime 
{
	import flash.events.IMEEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.ime.CompositionAttributeRange;
	import flash.text.ime.IIMEClient;
	import net.wonderfl.editor.core.UIFTETextInput;
	import net.wonderfl.editor.manager.IKeyboadEventManager;
	
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class IMEClient_10_1 extends AbstractIMEClient implements IKeyboadEventManager, IIMEClient
	{
		private var _selectionAnchorIndex:int;
		private var _selectionActiveIndex:int;
		private var _imeLength:int;
		private var _prevAnchorIndex:int;
		
		public function IMEClient_10_1($field:UIFTETextInput) 
		{
			super($field);
			
			_imeField.background = true;
			_imeField.backgroundColor = 0xCC6666;
			_imeField.mouseEnabled = false;
			_imeField.mouseWheelEnabled = false;
			_imeField.tabEnabled = false;
			_imeField.width = _imeField.height = 0;
			
			_field.addEventListener(IMEEvent["IME_START_COMPOSITION"], imeStartComposition);
		}
		
		private function setIMEFieldPosition():void {
			var point:Point = _field.getPointForIndex(_field.selectionBeginIndex);
			_imeField.x = point.x;
			_imeField.y = point.y;
		}
		
		private function imeStartComposition(e:IMEEvent):void 
		{
			e["imeClient"] = this;
			if (_field.selectionBeginIndex == _field.selectionEndIndex)
				setIMEFieldPosition();
		}
		
		private function log(...args):void {
			CONFIG::IME { trace('IME Client for 10.1 :: ' + args); }
		}
		
		override public function keyDownHandler($event:KeyboardEvent):Boolean
		{
			log(<>keyCode : {$event.keyCode}</>);
			return _imeLength > 0;
		}
		
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
			log(<>selectionAnchorIndex : {_selectionAnchorIndex}</>);
			return _selectionAnchorIndex;
		}
		
		public function get selectionActiveIndex():int
		{
			log(<>selectionActiveIndex : {_selectionActiveIndex}</>);
			return _selectionActiveIndex;
		}
		
		public function updateComposition(text:String, attributes:Vector.<CompositionAttributeRange>, compositionStartIndex:int, compositionEndIndex:int):void
		{
			_imeLength = text.length;
			var len:int = attributes.length;
			var attr:CompositionAttributeRange;
			log(<>text : {text}, start : {compositionStartIndex}, end : {compositionEndIndex}</>);
			var textRuns:Array = [];
			var selectionFound:Boolean = false;
			for (var i:int = 0; i < len; ++i) 
			{
				attr = attributes[i];
				log(<>i : {i}, relativeStart : {attr.relativeStart}, relativeEnd : {attr.relativeEnd}</>);
				//
				var run:String = text.substring(attr.relativeStart, attr.relativeEnd);
				if (compositionStartIndex == attr.relativeStart)
					setSelection();
				textRuns.push(run);
			}
			
			if (!selectionFound) {
				for (i = 0; i < len; ++i) {
					attr = attributes[i];
					if (attr.relativeStart == _prevAnchorIndex) {
						run = textRuns[i];
						setSelection();
						textRuns[i] = run;
					}
				}
			}
			
			_prevAnchorIndex = _selectionAnchorIndex;
			
			var face:String = _field.defaultTextFormat.font;
			_imeField.htmlText = '<font color="#ffffff" face="' + face + '">' + textRuns.join('') + '</font>';
			_imeField.width = _imeField.textWidth + 4;
			_imeField.height = _imeField.textHeight + 4;
			
			function setSelection():void {
				run = '<u>' + run + '</u>';
				_selectionActiveIndex = attr.relativeEnd;
				_selectionAnchorIndex = compositionStartIndex;
				selectionFound = true;
			}
		}
		
		// called when the user has confirmed the word
		public function confirmComposition(text:String = null, preserveSelection:Boolean = false):void
		{
			log(<>confirmComposition text : {text}, preserveSelection : {preserveSelection}</>);
			_imeField.text = '';
			_imeField.width = _imeField.height = 0;
		}
		
		public function getTextBounds(startIndex:int, endIndex:int):Rectangle
		{
			if (startIndex < 0 || endIndex < 0 || startIndex > _imeField.length || endIndex > _imeField.length) return new Rectangle;
			log(<>getTextBounds start : {startIndex}, end : {endIndex}</>);
			
			endIndex = (endIndex == _imeField.length) ? _imeField.length - 1 : endIndex;
			endIndex = (endIndex < 0) ? 0 : endIndex;
			
			var startPoint:Point = _imeField.getCharBoundaries(startIndex).topLeft;
			var endCharBoundaries:Rectangle = _imeField.getCharBoundaries(endIndex);
			var endPoint:Point = endCharBoundaries.bottomRight;
			var rect:Rectangle = new Rectangle;
			rect.topLeft = startPoint.add(new Point(0, _field.boxHeight));
			rect.bottomRight = endPoint;
			
			if (_field.selectionBeginIndex == _field.selectionEndIndex) {
				rect.x += _imeField.x;
				rect.y += _imeField.y;
			} else {
				setIMEFieldPosition();
				rect.height = _field.boxHeight;
				rect.x = _imeField.x;
				rect.y = _imeField.y;
			}
			
			log(_imeField.text.substring(startIndex, endIndex), rect);
			return rect;
		}
		
		public function selectRange(anchorIndex:int, activeIndex:int):void
		{
			log(<>selectRange anchorIndex : {anchorIndex}, activeIndex : {activeIndex}</>);
		}
		
		// this method will only called when selection area exists and then ime starts
		public function getTextInRange(startIndex:int, endIndex:int):String
		{
			return _field.text.substring(_field.selectionBeginIndex, _field.selectionEndIndex);
		}
		
	}

}