package net.wonderfl.editor.livecoding 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import net.wonderfl.editor.AS3Editor;
	import net.wonderfl.utils.removeFromParent;
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
				
				setIsLive(_isLive ? stopLive() : startLive());
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
		
		private function setIsLive(value:Boolean):void {
			_onImage.visible = value;
			_clickable = true;
			_isLive = value;
		}
		
		private function startLive():Boolean {
			connect();
			start();
			LiveCoding.start();
			
			return true;
		}
		
		private function stopLive():Boolean {
			stop();
			LiveCoding.stop();
			removeFromParent(_label);
			removeFromParent(_chat);
			removeFromParent(_chatButton);
			dispatchEvent(new Event(Event.CLOSE));
			
			return false;
		}
	}

}