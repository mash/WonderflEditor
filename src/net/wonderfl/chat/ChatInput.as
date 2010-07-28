package net.wonderfl.chat 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import net.wonderfl.component.core.UIComponent;
	import net.wonderfl.editor.font.FontSetting;
	import net.wonderfl.utils.listenOnce;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ChatInput extends UIComponent
	{
		public static const MINIMUM_HEIGHT:int = 48;
		private var _defaultHandler:Function;
		private var _input:TextField;
		private var _spButton:Sprite;
		
		public function ChatInput($inputHandler:Function) 
		{
			_defaultHandler = $inputHandler;
			listenOnce(this, Event.ADDED_TO_STAGE, init);
		}
		
		private function init():void
		{
			_input = new TextField;
			_input.type = TextFieldType.INPUT;
			_input.defaultTextFormat = new TextFormat(FontSetting.GOTHIC_FONT);
			_input.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			_input.addEventListener(TextEvent.TEXT_INPUT, textInput);
			
			
			_input.border = true;
			_input.borderColor = 0x666666;
			_input.background = true;
			_input.multiline = true;
			_input.backgroundColor = 0xffffff;
			addChild(_input);
			
			var factory:TextBlock = new TextBlock;
			factory.content = new TextElement('POST', new ElementFormat(new FontDescription(FontSetting.GOTHIC_FONT), 12, 0xffffff));
			var line:TextLine = factory.createTextLine();
			line.y = line.height;
			line.x = (70 - line.width) >> 1;
			
			_spButton = new Sprite;
			_spButton.graphics.beginFill(0xb34033);
			_spButton.graphics.drawRect(0, 0, 70, 15);
			_spButton.graphics.endFill();
			_spButton.addChild(line);
			_spButton.tabEnabled = false;
			_spButton.buttonMode = true;
			_spButton.addEventListener(MouseEvent.CLICK, _defaultHandler);
			addChild(_spButton);
		}
		
		private function keyDown(e:KeyboardEvent):void 
		{
			
		}
		
		private function textInput(e:TextEvent):void 
		{
			if (e.text == '\n') {
			}
		}
		
		override protected function updateSize():void 
		{
			_height = (_height < MINIMUM_HEIGHT) ? MINIMUM_HEIGHT : _height;
			_input.width = _width - 21;
			_input.x = 10;
			_input.height = _height - 25;
			_spButton.x = _width - 81;
			_spButton.y = _height - 25;
		}
		
		public function get text():String { return _input.text; }
		public function set text($value:String):void {
			_input.text = $value;
		}
		
	}
}
