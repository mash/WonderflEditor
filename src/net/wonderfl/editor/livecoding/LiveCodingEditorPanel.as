package net.wonderfl.editor.livecoding 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import net.wonderfl.editor.AS3Editor;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class LiveCodingEditorPanel extends LiveCodingPanel
	{
		[Embed(source = '../../../../../assets/on_live.png')]
		private var _onClass:Class;
		private var _onImage:Bitmap = new _onClass;
		[Embed(source = '../../../../../assets/start_live.png')]
		private var _startClass:Class;
		private var _editor:AS3Editor;
		private var _clickable:Boolean = true;
		
		public function LiveCodingEditorPanel($editor:AS3Editor) 
		{
			_editor = $editor;
			_onImage.visible = false;
			
			var sp:Sprite = new Sprite;
			sp.buttonMode = true;
			sp.tabEnabled = false;
			sp.addChild(new _startClass);
			sp.addChild(_onImage);
			addChild(sp);
			
			sp.addEventListener(MouseEvent.CLICK, function ():void {
				if (!_clickable) return;
				_clickable = false;
				
				isLive = _isLive ? stopLive() : startLive();
			});
			
			sp.addEventListener(MouseEvent.ROLL_OVER, function () :void {
				_onImage.visible = !_isLive;
			});
			
			sp.addEventListener(MouseEvent.ROLL_OUT, function ():void {
				_onImage.visible = _isLive;
			});
		}
		
		public function getSocket():SocketBroadCaster {
			return _socket;
		}
		
		private function set isLive(value:Boolean):void {
			_onImage.visible = value;
			_clickable = true;
			_isLive = value;
		}
		
		private function startLive():Boolean {
			start();
			LiveCoding.start();
			
			return true;
		}
		
		private function stopLive():Boolean {
			stop();
			LiveCoding.stop();
			
			return false;
		}
		
		override public function init():void 
		{
			super.init();
			
			
		}
		
	}

}