package net.wonderfl.editor.core 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
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
	public class URLLinkElement extends Sprite
	{
		private var _block:TextBlock;
		private var _text:TextElement;
		private var _hover:Shape;
		private var _underline:Shape;
		private var _url:String;
		private var _overFormat:ElementFormat;
		private var _outFormat:ElementFormat;
		
		public function URLLinkElement($url:String, $elf:ElementFormat) 
		{
			_block = new TextBlock;
			_text = new TextElement($url, $elf, this);
			_block.content = _text;
			_url = $url;
			
			mouseChildren = false;
			
			_overFormat = $elf.clone();
			_overFormat.color = 0;
			_outFormat = $elf.clone();
			updateView();
			
			
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			var line:TextLine = _block.firstLine;
			var rect:Rectangle = line.mirrorRegions[0].bounds;
			var metrics:FontMetrics = _overFormat.getFontMetrics();
			
			_hover = new Shape;
			_hover.graphics.beginFill(0xf39c64);
			_hover.graphics.drawRect(line.x + rect.x, line.y + rect.y - 2, rect.width, metrics.underlineOffset + 4 - rect.y);
			_hover.graphics.endFill();
			
			_underline = new Shape;
			_underline.graphics.lineStyle(1, _outFormat.color);
			_underline.graphics.moveTo(line.x + rect.x, line.y + metrics.underlineOffset + 2);
			_underline.graphics.lineTo(line.x + rect.x + rect.width, line.y + metrics.underlineOffset + 2);
			
			addChild(_hover);
			addChild(_underline);
			addChild(_block.firstLine);
			
			onMouseOut(null);
		}
		
		private function onMouseUp(e:MouseEvent):void 
		{
			navigateToURL(new URLRequest(_url), "_blank");
		}
		
		private function onMouseOver(e:MouseEvent):void 
		{
			Mouse.cursor = MouseCursor.BUTTON;
			_underline.visible = false;
			_hover.visible = true;
			_text.elementFormat = _overFormat.clone();
			updateView();
		}
		
		private function onMouseOut(e:MouseEvent):void 
		{
			Mouse.cursor = MouseCursor.IBEAM;
			_underline.visible = true;
			_hover.visible = false;
			_text.elementFormat = _outFormat.clone();
			updateView();
		}
		
		override public function get height():Number { return _block.firstLine.height; }
		override public function get width():Number { return _block.firstLine.width; }
		
		
		private function updateView():void {
			// link is a single line
			var line:TextLine = _block.firstLine;
			if (line) {
				_block.releaseLines(_block.firstLine, _block.lastLine);
				removeChild(line);
				line.flushAtomData();
			}
			
			line = _block.createTextLine(null, 1000000);
			line.y = line.textHeight;
			addChild(line);
		}
		
	}

}