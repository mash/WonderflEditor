package net.wonderfl.editor.core 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
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
		private var _hover:Hover;
		private var _underline:Underline;
		private var _line:TextLine;
		private var _text:TextElement;
		private var _lineHeight:int;
		private var _over:Boolean = false;
		
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
			
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		}
		
		public function draw($region:TextLineMirrorRegion):void {
			var line:TextLine = $region.textLine;
			var rect:Rectangle = $region.bounds;
			var metrics:FontMetrics = _outFormat.getFontMetrics();
			
			_line = line;
			
			_hover = new Hover;
			_hover.graphics.beginFill(0xf39c64);
			_hover.graphics.drawRect(line.x + rect.x, line.y + rect.y - 2, rect.width, metrics.underlineOffset + 4 - rect.y);
			_hover.graphics.endFill();
			_hover.visible = false;
			
			_underline = new Underline;
			_underline.graphics.lineStyle(1, _outFormat.color);
			_underline.graphics.moveTo(line.x + rect.x, line.y + metrics.underlineOffset + 2);
			_underline.graphics.lineTo(line.x + rect.x + rect.width, line.y + metrics.underlineOffset + 2);
			
			_decorationContainer.addChild(_hover);
			_decorationContainer.addChild(_underline);
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
import flash.display.Shape;

internal class Hover extends Shape {}
internal class Underline extends Shape {}