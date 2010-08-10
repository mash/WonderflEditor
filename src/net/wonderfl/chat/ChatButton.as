package net.wonderfl.chat 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.GraphicElement;
	import flash.text.engine.GroupElement;
	import flash.text.engine.TextBaseline;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.ui.MouseCursor;
	import net.wonderfl.component.core.UIComponent;
	import net.wonderfl.editor.font.FontSetting;
	import net.wonderfl.mouse.MouseCursorController;
	import net.wonderfl.utils.listenOnce;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ChatButton extends UIComponent
	{
		private static const LEFT_OF_TEXT:uint = 15;
		private var _open:Boolean = false;
		private var _elf:ElementFormat;
		private var _factory:TextBlock;
		private var _label:TextLine;
		private var _numMessages:int = 0;
		private var _arrowScale:Number = 1;
		private var _arrow:ChatButtonArrow;
		
		public function ChatButton() 
		{
			MouseCursorController.setOverState(this, MouseCursor.BUTTON);
			_elf = new ElementFormat(new FontDescription(FontSetting.GOTHIC_FONT), 10);
			_elf.color = 0xffffff;
			_elf.dominantBaseline = TextBaseline.IDEOGRAPHIC_CENTER;
			
			_arrow = new ChatButtonArrow;
			_factory = new TextBlock;
			
			updateSize();
		}
		
		public function toggle():void {
			_open = !_open;
			
			_arrowScale *= -1;
			_arrow.scaleX = _arrowScale;
			
			if (_open) {
				setNumber(0);
			}
			
			updateSize();
		}
		
		public function increaseNumMessages():void {
			setNumber(++_numMessages);
		}
		
		private function setNumber($number:int):void {
			if (_label) removeChild(_label);
			
			_numMessages = $number;
			_factory.content = new GroupElement(Vector.<ContentElement>([
				new GraphicElement(_arrow, _arrow.width + 2, _arrow.height, _elf.clone()),
				new TextElement('Chat' + ($number ? ' (' + $number + ')' : ''), _elf.clone())
			]));
			_label = _factory.createTextLine();
			_label.y = _label.height + 4;
			_label.x = LEFT_OF_TEXT;
			addChild(_label);
			
			drawBackground();
		}
		
		private function drawBackground():void {
			graphics.clear();
			
			if (_numMessages) {
				graphics.beginFill(ChatStyle.CHAT_NOTIFICATION);
			} else {
				graphics.beginFill(0);
			}
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}
		
		override protected function updateSize():void 
		{
			setNumber(0);
			drawBackground();
		}
		
		public function isOpen():Boolean {
			return _open;
		}
		
	}

}
