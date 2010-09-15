package net.wonderfl.editor.livecoding 
{
	import net.wonderfl.editor.ITextArea;
	/**
	 * @author kobayashi-taro
	 */
	public class LiveCoding
	{
		public static const REPLACE_TEXT:int = 0;
		public static const SET_SELECTION:int = 1;
		public static const SEND_CURRENT_TEXT:int = 2;
		public static const SWF_RELOADED:int = 3;
		public static const CLOSED:int = 4;
		public static const SCROLL_V:int = 5;
		public static const SCROLL_H:int = 6;
		
		public static var isLive:Boolean = true;
		private var _text:String = '';
		private var _prevText:String = '';
		static private var _broadCaster:LiveCodingBroadcaster;
		static private var _this:LiveCoding;
		static private var _onJoin:Function;
		
		public function LiveCoding() 
		{
			_this = this;
		}
		
		public function setSocket($socket:SocketBroadCaster):void {
			_broadCaster = new LiveCodingBroadcaster($socket);
		}
		
		public static function getInstance():LiveCoding {
			return _this ||= new LiveCoding;
		}
		
		public function setEditor(value:ITextArea):void {
			_broadCaster.editor = value;
		}
		
		public static function start():void {
			_broadCaster.startLiveCoding();
			_broadCaster.sendCurrentText();
		}
		
		public static function stop():void {
			_broadCaster.endLiveCoding();
		}
		
		public function pushCurrentSelection($selectionBeginIndex:int, $selectionEndIndex:int):void {
			_broadCaster.setSelection($selectionBeginIndex, $selectionEndIndex);
		}
		
		public function pushReplaceText($startIndex:int, $endIndex:int, $text:String):void {
			_broadCaster.replaceText($startIndex, $endIndex, $text);
		}
		
		public function pushSWFReloaded():void {
			_broadCaster.onSWFReloaded();
		}
		
		public function pushClosing():void {
			_broadCaster.closeLiveCoding();
		}
		
		public function pushScrollV($scrollV:int):void {
			_broadCaster.setScrollV($scrollV);
		}
		
		public function pushScrollH($scrollH:int):void {
			_broadCaster.setScrollH($scrollH);
		}
		
		public function get text():String { return _text; }
		
		public function set text(value:String):void 
		{
			_prevText = _text;
			_text = value;
		}
		
		public function get prevText():String { return _prevText; }
		
		public function set onJoin(value:Function):void 
		{
			_broadCaster.onJoin = value;
		}
		
		public function set onMemberUpdate(value:Function):void {
			_broadCaster.onMemberUpdate = value;
		}
		
	}

}