package net.wonderfl.editor.error 
{
	import flash.display.Sprite;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import net.wonderfl.utils.removeAllChildren;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ErrorMessageToolTip extends Sprite {
		private var _factory:TextBlock;
		private var _elf:ElementFormat;
		
		public function ErrorMessageToolTip() {
			mouseEnabled = mouseChildren = false;
			_factory = new TextBlock;
			_elf = new ElementFormat;
		}
		
		public function show($message:String):void {
			removeAllChildren(this);
			
			_factory.content = new TextElement($message, _elf.clone());
			
			var line:TextLine = _factory.createTextLine();
			line.x = 2;
			line.y = line.height + 2;
			addChild(line);
			
			graphics.clear();
			graphics.beginFill(0xf4dfcb);
			graphics.drawRect(0, 0, line.width + 4, line.height + 4);
			graphics.endFill();
		}
	}

}