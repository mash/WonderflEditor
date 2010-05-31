package net.wonderfl.editor.operations {
	/**
	 * kobayashi-taro
	 */
	public class ReplaceText {
		public var startIndex:int;
		public var endIndex:int;
		public var text:String;
		public var next:ReplaceText = null;
		public var prev:ReplaceText = null;
		
		public function ReplaceText($startIndex:int, $endIndex:int, $text:String):void {
			startIndex = $startIndex;
			endIndex = $endIndex;
			text = $text;
		}
		
		CONFIG::debug
		public function toString():String {
			return <>start : {startIndex}, end : {endIndex}, text : {text}</>;
		}
	}
}