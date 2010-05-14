package net.wonderfl.editor.core 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontMetrics;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineMirrorRegion;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class LinkElementEventMirror extends EventDispatcher
	{
		private var _decorationContainer:DisplayObjectContainer;
		private var _textLineContainer:DisplayObjectContainer;
		private var _region:TextLineMirrorRegion;
		private var _overFormat:ElementFormat;
		private var _outFormat:ElementFormat;
		private var _url:String;
		private var _hover:Shape;
		private var _underline:Shape;
		private var _line:TextLine;
		private var _text:TextElement;
		private var _lineHeight:int;
		private var _over:Boolean = false;
		private var _linkSprite:Sprite;
		
		public function LinkElementEventMirror($textLineContainer:DisplayObjectContainer, $decorationContainer:DisplayObjectContainer, $text:TextElement, $lineHeight:int) 
		{
			_textLineContainer = $textLineContainer;
			_decorationContainer = $decorationContainer;
			_text = $text;
			_url = $text.rawText;
			_overFormat = $text.elementFormat.clone();
			_overFormat.color = 0;
			_outFormat = $text.elementFormat.clone();
			_lineHeight = $lineHeight;
			
			_linkSprite = new Sprite;
			_linkSprite.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_linkSprite.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_linkSprite.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}
		
		public function draw($region:TextLineMirrorRegion):void {
			var line:TextLine = $region.textLine;
			var rect:Rectangle = $region.bounds;
			var metrics:FontMetrics = _outFormat.getFontMetrics();
			
			_line = line;
			
			_hover = new Shape;
			_hover.graphics.beginFill(0xf39c64);
			_hover.graphics.drawRect(0, rect.y - 2, rect.width, metrics.underlineOffset + 4 - rect.y);
			_hover.graphics.endFill();
			_hover.visible = false;
			
			_underline = new Shape;
			_underline.graphics.lineStyle(1, _outFormat.color);
			_underline.graphics.moveTo(0, metrics.underlineOffset + 2);
			_underline.graphics.lineTo(rect.width, metrics.underlineOffset + 2);
			
			
			_linkSprite.graphics.beginFill(0, 0);
			_linkSprite.graphics.drawRect(0, rect.y - 2, rect.width, metrics.underlineOffset + 4 - rect.y);
			_linkSprite.graphics.endFill();
			_linkSprite.x = line.x + rect.x;
			_linkSprite.y = line.y;
			
			_decorationContainer.addChild(_linkSprite);
			_linkSprite.addChild(_hover);
			_linkSprite.addChild(_underline);
		}
		
		private function onMouseUp(e:MouseEvent):void 
		{
			navigateToURL(new URLRequest(_url), "_blank");
		}
		
		private function onMouseOver(e:MouseEvent):void 
		{
			if (_over) return;
			_over = true;
			
			_text.elementFormat = _overFormat.clone();
			updateView();
			Mouse.cursor = MouseCursor.BUTTON;
		}
		
		private function onMouseOut(e:MouseEvent):void 
		{
			if (!_over) return;
			_over = false;
			
			_text.elementFormat = _outFormat.clone();
			updateView();
			Mouse.cursor = MouseCursor.IBEAM;
		}
		
		private function updateView():void
		{
			var block:TextBlock = _line.textBlock;
			while (_textLineContainer.numChildren) _textLineContainer.removeChildAt(0);
			
			var line:TextLine = block.createTextLine(null, TextLine.MAX_LINE_WIDTH);
			var i:int = 0;	
			while (line) {
				line.x = 4;
				
				line.y = _lineHeight * ++i - 2;
				_textLineContainer.addChild(line);
				line = block.createTextLine(line, TextLine.MAX_LINE_WIDTH);
			}
			
			_hover.visible = _over;
			_underline.visible = !_over;
		}
		
	}

}
