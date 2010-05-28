package net.wonderfl.editor.ui 
{
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import net.wonderfl.editor.core.UIComponent;
	import net.wonderfl.editor.utils.removeAllChildren;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ToolTip extends UIComponent
	{
		private var _elf:ElementFormat;
		private var _isShowing:Boolean = false;
		private var _factory:TextBlock;
		
		public function ToolTip() 
		{
			_factory = new TextBlock;
			_elf = new ElementFormat;
			_elf.color = 0xffffff;
			updateSize();
			visible = false;
		}
		
		public function isShowing():Boolean {
			return _isShowing;
		}
		
		public function disposeToolTip():void {
			_isShowing = false;
			visible = false;
		}
		
		public function setTipText($text:String):void {
			removeAllChildren(this);
			_factory.content = new TextElement($text, _elf.clone());
			var line:TextLine = _factory.createTextLine();
			line.y = line.height;
			addChild(line);
			setSize(line.width, line.height);
		}
		
		public function showToolTip():void {
			_isShowing =  true;
			visible = true;
		}
		
		public function moveLocationRelatedTo($xpos:int, $ypos:int):void {
			x = $xpos;
			y = $ypos;
		}
		
		public function getSelectedValue():String {
			return 'hoge hoge';
		}
		
		override protected function updateSize():void 
		{
			graphics.clear();
			graphics.beginFill(0xff);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}
		
	}

}