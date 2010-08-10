package net.wonderfl.chat 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontMetrics;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineMirrorRegion;
	import flash.ui.MouseCursor;
	import net.wonderfl.editor.font.FontSetting;
	import net.wonderfl.mouse.MouseCursorController;
	import net.wonderfl.utils.bind;
	import net.wonderfl.utils.removeFromParent;
	
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ChatSignUp extends Sprite
	{
		private var _line:TextLine;
		private var _outFormat:ElementFormat;
		private var _overFormat:ElementFormat;
		private var _factory:TextBlock;
		private var _underline:Shape;
		private var _over:Shape;
		
		public function ChatSignUp() 
		{
			mouseChildren = false;
			_overFormat = new ElementFormat(new FontDescription(FontSetting.GOTHIC_FONT));
			_outFormat = _overFormat.clone();
			_outFormat.color = 0xffffff;
			
			_factory = new TextBlock;
			
			var loginURL:String = '';
			(ExternalInterface.call('function(){return location.href;}') || "").replace(
				/wonderfl\.net(.+)/,
				function ($match:String, $redirectURL:String, $index:int, $str:String):String {
					loginURL = '/login?redirect=' + $redirectURL;
					return "";
				}
			);
			
			addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			addEventListener(MouseEvent.CLICK, bind(navigateToURL, [new URLRequest(loginURL), "_self"]));
			
			mouseOut(null);
		}
		
		private function updateText($format:ElementFormat):void {
			removeFromParent(_line);
			_factory.content = new TextElement('Sign up to chat!', $format.clone(),	this);
			_line = _factory.createTextLine();
			_line.x = 13 + ((268 - _line.width) >> 1);
			_line.y = _line.height + 4;
			
		}
		
		private function initShapes($regions:Vector.<TextLineMirrorRegion>):void {
			var region:TextLineMirrorRegion = $regions[0];
			if (region == null) return;
			
			var rect:Rectangle = region.bounds;
			var metrics:FontMetrics = _overFormat.getFontMetrics();
			var yPos:int = _line.y;
			
			_underline = new Shape;
			_underline.graphics.lineStyle(1, _outFormat.color);
			_underline.x = _line.x;
			_underline.graphics.moveTo(rect.x, yPos + metrics.underlineOffset + 2);
			_underline.graphics.lineTo(rect.right, yPos + metrics.underlineOffset + 2);
			
			_over = new Shape;
			_over.graphics.beginFill(0xf39c64);
			_over.graphics.drawRect(rect.x, yPos + rect.y - 2, rect.width, metrics.underlineOffset + 4 - rect.y);
			_over.graphics.endFill();
			_over.x = _line.x;
		}
		
		private function mouseOver(e:MouseEvent):void 
		{
			MouseCursorController.getOverStateHandler(MouseCursor.BUTTON)();
			updateText(_overFormat);
			removeFromParent(_underline);
			addChild(_over);
			addChild(_line);
		}
		
		private function mouseOut(e:MouseEvent):void 
		{
			MouseCursorController.resetMouseCursor();
			updateText(_outFormat);
			
			if (_underline == null) {
				initShapes(_line.mirrorRegions);
			}
			
			removeFromParent(_over);
			addChild(_underline);
			addChild(_line);
		}
		
	}

}