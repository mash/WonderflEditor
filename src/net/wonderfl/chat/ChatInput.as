package net.wonderfl.chat 
{
	import flash.display.Shape;
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
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import net.wonderfl.component.core.UIComponent;
	import net.wonderfl.editor.font.FontSetting;
	import net.wonderfl.mouse.MouseCursorController;
	import net.wonderfl.utils.bind;
	import net.wonderfl.utils.listenOnce;
	import net.wonderfl.utils.removeFromParent;
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
		private var _preventFollowingTextInput:Boolean;
		
		public function ChatInput($inputHandler:Function) 
		{
			_defaultHandler = $inputHandler;
			_input = new TextField;
			_input.type = TextFieldType.INPUT;
			_input.defaultTextFormat = new TextFormat(FontSetting.GOTHIC_FONT);
			_input.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			_input.addEventListener(TextEvent.TEXT_INPUT, textInput);
			MouseCursorController.setOverState(_input, MouseCursor.IBEAM);
			
			_input.border = true;
			_input.borderColor = 0x666666;
			_input.background = true;
			_input.multiline = true;
			_input.backgroundColor = 0xffffff;
			addChild(_input);
			
			var factory:TextBlock = new TextBlock;
			factory.content = new TextElement('Post', new ElementFormat(new FontDescription(FontSetting.GOTHIC_FONT), 10, 0xffffff));
			var line:TextLine = factory.createTextLine();
			line.y = line.height;
			line.x = (70 - line.width) >> 1;
			
			_spButton = new Sprite;
			_spButton.graphics.beginFill(0xd6151b);
			_spButton.graphics.drawRect(0, 0, 70, 15);
			_spButton.graphics.endFill();
			_spButton.addChild(line);
			_spButton.mouseChildren = false;
			_spButton.addEventListener(MouseEvent.CLICK, _defaultHandler);
			addChild(_spButton);
			
			var overShape:Shape = new Shape;
			var prevCursor:String;
			overShape.graphics.beginFill(0xffffff, 0.5);
			overShape.graphics.drawRect(0, 0, 70, 15);
			overShape.graphics.endFill();
			_spButton.addEventListener(MouseEvent.MOUSE_OVER, function ():void {
				_spButton.addChild(overShape);
				MouseCursorController.getOverStateHandler(MouseCursor.BUTTON)();
			});
			_spButton.addEventListener(MouseEvent.MOUSE_OUT, function ():void {
				removeFromParent(overShape);
				MouseCursorController.resetMouseCursor();
			});
		}
		
		public function disable():void {
			_input.backgroundColor = 0x666666;
			_input.mouseEnabled = false;
			_spButton.mouseEnabled = false;
			_spButton.graphics.clear();
			_spButton.graphics.beginFill(0x666666);
			_spButton.graphics.drawRect(0, 0, 70, 15);
			_spButton.graphics.endFill();
			
			addChild(new ChatSignUp);
		}
		
		private function keyDown(e:KeyboardEvent):void 
		{
			if (e.shiftKey && e.keyCode == Keyboard.ENTER) {
				_input.replaceSelectedText('\n');
			}
		}
		
		private function textInput(e:TextEvent):void 
		{
			if (e.text == '\n') {
				_defaultHandler(null);
				e.preventDefault();
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
