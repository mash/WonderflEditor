package
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	public class SetterTest extends Sprite
	{
		private var _textField:TextField;
		private const LOOP:int = 1 << 15;
		
		public function SetterTest()
		{
			_textField = new TextField;
			addChild(_textField);
			
			var t:int;
			var i:int;
			var a:A;
			var b:B;
			var c:C;
			
			
			
			t = getTimer();
			for (i = 0; i < LOOP; ++i) {
				b = new B;
				b.setValue(i);
			}
			trace((getTimer() - t) + " ms");
			
			t = getTimer();
			for (i = 0; i < LOOP; ++i) {
				a = new A;
				a.value = i;
			}
			trace((getTimer() - t) + " ms");
			
			t = getTimer();
			for (i = 0; i < LOOP; ++i) {
				c = new C;
				c.value = i;
			}
			trace((getTimer() - t) + " ms");
		}
		
		private function trace(...args):void {
			_textField.appendText(args + "\n");
			_textField.width = _textField.textWidth + 4;
			_textField.height= _textField.textHeight + 4;
		}
	}
}

class A {
	private var _value:int;
	public function set value($value:int):void {
		_value = $value;
	}
}

class B {
	private var _value:int;
	public function setValue($value:int):void {
		_value = $value;
	}
}

class C {
	public var value:int;
}