package net.wonderfl.editor.manager 
{
	import adobe.utils.CustomActions;
	import flash.events.IMEEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.IME;
	import flash.text.ime.CompositionAttributeRange;
	import flash.text.ime.IIMEClient;
	import flash.text.TextField;
	import net.wonderfl.editor.we_internal;
	import net.wonderfl.editor.core.UIFTETextInput;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class IMEManager implements IIMEClient
	{
		private var _field:UIFTETextInput;
		private var _imeTF:TextField;
		private var _imeMode:Boolean = false;
		private var _imeLength:int = 0;
		private var _imeStartComposition:Boolean = false;
		
		public function IMEManager($field:UIFTETextInput) 
		{
			_field = $field;
			_imeTF = _field.we_internal::inputTF;
			//_imeTF.visible = false;
			_imeTF.addEventListener(TextEvent.TEXT_INPUT, onIMEInput);
			_field.addEventListener("imeStartComposition", imeStartCompositionHandler);
		}
		
        private function imeStartCompositionHandler(e:IMEEvent):void 
        {
			e["imeClient"] = this;
			++_imeLength;
			_imeStartComposition = true;
            trace(e);
        }
		
		private function onIMEInput(e:TextEvent):void 
		{
			trace('== IME INPUT [' + e.text + '] ==');
            _imeMode = false;
            //_imeTF.visible = false;
			_imeLength = 0;
			_imeStartComposition = false;
		}
		
		public function onKeyDown($event:KeyboardEvent):void {
            if (IME.enabled && IME.conversionMode != "ALPHANUMERIC_HALF") {
                if (!_imeMode) {
					trace('== IME MODE ON ==');
					_field.resetIMETFPosition();
                    _imeMode = true;
                    _imeTF.text = '';
                    //_imeTF.visible = true;
                    if (_field.stage.focus != _imeTF) _field.stage.focus = _imeTF;
                }
            } else if (_imeMode) {
				trace('== IME MODE OFF ==');
                _imeMode = false;
                   _imeTF.text = '';
                //_imeTF.visible = false;
                _field.stage.focus = _field;
            }
		}
		
		/* INTERFACE flash.text.ime.IIMEClient */
		
		public function get compositionStartIndex():int
		{
			return _field.we_internal::_caret;
		}
		
		public function get compositionEndIndex():int
		{
			return _field.we_internal::_caret;
		}
		
		public function get verticalTextLayout():Boolean
		{
			return false;
		}
		
		public function get selectionAnchorIndex():int
		{
			return 0;
		}
		
		public function get selectionActiveIndex():int
		{
			return 0;
			
		}
		
		public function updateComposition(text:String, attributes:Vector.<CompositionAttributeRange>, compositionStartIndex:int, compositionEndIndex:int):void
		{
			trace(<>updateComposition : {arguments}</>);
			
			var len:int = attributes.length;
			var attr:CompositionAttributeRange;
			for (var i:int = 0; i < len; ++i) 
			{
				attr = attributes[i];
				trace(<>i : {i}, relativeStart : {attr.relativeStart}, relativeEnd : {attr.relativeEnd}</>);
			}
			
		}
		
		public function confirmComposition(text:String = null, preserveSelection:Boolean = false):void
		{
			
		}
		
		public function getTextBounds(startIndex:int, endIndex:int):Rectangle
		{
			return new Rectangle(100, 100, 200, 20);
		}
		
		public function selectRange(anchorIndex:int, activeIndex:int):void
		{
		}
		
		public function getTextInRange(startIndex:int, endIndex:int):String
		{
			if (startIndex < -1 || endIndex < -1 || startIndex > (_field.length - 1) || endIndex > (_field.length - 1))
				return null;
			
			// Make sure they're in the right order
			if (endIndex < startIndex)
			{
				var tempIndex:int = endIndex;
				endIndex = startIndex;
				startIndex = tempIndex;
			}
			
			if (startIndex == -1)
				startIndex = 0;
			
			return _field.text.substring(startIndex, endIndex);
		}
		
		public function get imeMode():Boolean { return _imeMode; }
		
		public function get imeStartComposition():Boolean { return _imeStartComposition; }
		
	}

}