package net.wonderfl.chat 
{
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import net.wonderfl.component.core.UIComponent;
	import net.wonderfl.component.scroll.VScrollBar;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ChatTextArea extends UIComponent
	{
		private var tf:TextField;
		private var scroll:VScrollBar;
		private var _totalLines:int;
		
		public function ChatTextArea() 
		{
			tf = new TextField;
			tf.type = TextFieldType.INPUT;
			tf.multiline = true;
			tf.wordWrap = false;
			tf.addEventListener(Event.CHANGE, onChange);
			tf.addEventListener(Event.SCROLL, onTextScroll);
			addChild(tf);
			
			scroll = new VScrollBar;
			scroll.valueForMaxPos = 1;
			scroll.value = 1;
			scroll.handleMinimumSize = 12;
			scroll.addEventListener(Event.SCROLL, onScroll);
			addChild(scroll);
			
		}
		
		private function onChange(e:Event):void 
		{
			scroll.valueForMaxPos = tf.maxScrollV;
			_totalLines = tf.text.split(/[\r\n]/).length;
			scroll.valueForPageSize = (_totalLines - tf.maxScrollV);
			scroll.drawHandle();
			scroll.value = tf.scrollV;
		}
		
		private function onTextScroll(e:Event):void 
		{
			scroll.value = tf.scrollV;
		}
		
		private function onScroll(e:Event):void 
		{
			tf.scrollV = scroll.value;
		}
		
		override protected function updateSize():void 
		{
			tf.width = _width - scroll.width;
			tf.height = _height;
			
			scroll.valueForPageSize = (_totalLines - tf.maxScrollV);
			scroll.x = tf.width;
			scroll.height = _height;
			
			graphics.clear();
			graphics.beginFill(0xffffff);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}
		
		public function get text():String { return tf.text; }
		public function set text($value:String):void {
			tf.text = $value;
		}
	}

}