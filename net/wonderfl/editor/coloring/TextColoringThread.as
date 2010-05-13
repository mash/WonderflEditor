package net.wonderfl.editor.coloring 
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import ro.victordramba.thread.IThread;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class TextColoringThread implements IThread
	{
		public var textField:TextField;
		private var _textFormats:Array;
		private var _allFormatRuns:Array;
		private var _queIndex:int = 0;
		private var _queLength:int;
		
		public function TextColoringThread($textField:TextField) 
		{
			textField = $textField;
		}
		
		public function runSlice():Boolean
		{
			var i:int = 0;
			var $run:Object;
			var tfm:TextFormat = new TextFormat;
			if (!_textFormats || _textFormats.length == 0)
				return false;
			
			while (i++ < 16) {
				if (_queIndex == _queLength) return false;
				
				$run = _textFormats[_queIndex];
				
				
				tfm.color = parseInt("0x" + $run.color);
				tfm.bold = $run.bold;
				tfm.italic = $run.italic;
				textField.setTextFormat(tfm, $run.begin, $run.end);
				
				++_queIndex;
			}
		
			return (_queIndex < _queLength);
		}
		
		public function kill():void
		{
		}
		
		public function get textFormats():Array { return _textFormats; }
		
		public function set textFormats(value:Array):void 
		{
			_textFormats = value;
			_queLength = value.length;
		}
		
	}

}