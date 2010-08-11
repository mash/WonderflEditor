package net.wonderfl.chat
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
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontMetrics;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineMirrorRegion;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import net.wonderfl.editor.font.FontSetting;
	import net.wonderfl.thread.ThreadExecuter;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ChatLinkElementEventMirror extends EventDispatcher
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
		private var _content:ContentElement;
		private var _message:ChatMessage;

		public function ChatLinkElementEventMirror($chatMessage:ChatMessage, $textLineContainer:DisplayObjectContainer, $decorationContainer:DisplayObjectContainer, $text:TextElement, $lineHeight:int) 
		{
			_message = $chatMessage;
			_textLineContainer = $textLineContainer;
			_decorationContainer = $decorationContainer;
			_text = $text;
			_url = $text.rawText;
			_overFormat = $text.elementFormat.clone();
			_overFormat.color = 0;
			_outFormat = $text.elementFormat.clone();
			_lineHeight = $lineHeight;

			_linkSprite = new Sprite;
			_linkSprite.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_linkSprite.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_linkSprite.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}

		private var _count:int = 0;
		public function draw($region:TextLineMirrorRegion):void {
			var line:TextLine = $region.textLine;
			_content ||= line.textBlock.content;
			var rect:Rectangle = $region.bounds;
			var metrics:FontMetrics = _outFormat.getFontMetrics();
			//trace("$region : " + rect, _count++);
			trace("$region : " + rect);

			_line = line;
			var yPos:int =	line.y;
			
			_hover ||= new Shape;
			_hover.graphics.beginFill(0xf39c64);
			_hover.graphics.drawRect(rect.x, yPos + rect.y - 2, rect.width, metrics.underlineOffset + 4 - rect.y);
			_hover.graphics.endFill();
			_hover.visible = false;

			_underline ||= new Shape;
			_underline.graphics.lineStyle(1, _outFormat.color);
			_underline.graphics.moveTo(rect.x, yPos + metrics.underlineOffset + 2);
			_underline.graphics.lineTo(rect.right, yPos + metrics.underlineOffset + 2);

			_linkSprite.graphics.beginFill(0, 0);
			_linkSprite.graphics.drawRect(rect.x , yPos + rect.y - 2, rect.width, metrics.underlineOffset + 4 - rect.y);
			_linkSprite.graphics.endFill();
			_linkSprite.x = line.x;

			_decorationContainer.addChild(_linkSprite);
			_linkSprite.addChild(_hover);
			_linkSprite.addChild(_underline);
		}

		private function onMouseDown(e:MouseEvent):void 
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

			block.content = _content;
			var line:TextLine = null;
			var i:int = 0;
			var yPos:int = (FontSetting.LINE_HEIGHT >> 1) + FontSetting.LINE_HEIGHT + 2;
			while (line = block.createTextLine(line, _message.textWidth)) {
				line.x = ChatMessage.LEFT_OF_TEXT;
				line.y = yPos;
				yPos += _lineHeight;
				_textLineContainer.addChild(line);
			}

			_hover.visible = _over;
			_underline.visible = !_over;
		}

	}

}