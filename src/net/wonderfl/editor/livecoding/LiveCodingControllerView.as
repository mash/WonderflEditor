package net.wonderfl.editor.livecoding 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.describeType;
	import flash.utils.getTimer;
	import net.wonderfl.component.core.UIComponent;
	import net.wonderfl.editor.font.FontSetting;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class LiveCodingControllerView extends UIComponent {
		[Embed(source = '../../../../../assets/on_live.png')]
		private var _onClass:Class;
		private var _onImage:Bitmap = new _onClass;
		[Embed(source = '../../../../../assets/start_live.png')]
		private var _startClass:Class;
		private var _timerCounter:int;
		private var _tfTimer:TextField;
		private var _tfViewer:TextField;
		private var _isLive:Boolean;
		private var _time:int;
		private var _clickable:Boolean = true;
		
		public function LiveCodingControllerView() 
		{
			var sp:Sprite = new Sprite;
			sp.buttonMode = true;
			sp.tabEnabled = false;
			sp.addChild(new _startClass);
			sp.addChild(_onImage);
			addChild(sp);
			
			sp.addEventListener(MouseEvent.CLICK, function ():void {
				if (!_clickable) return;
				_clickable = false;
				
				if (_isLive)
					isLive = stopLive();
				else
					startLive();
			});
			
			sp.addEventListener(MouseEvent.ROLL_OVER, function () :void {
				_onImage.visible = true;
			});
			
			sp.addEventListener(MouseEvent.ROLL_OUT, function ():void {
				_onImage.visible = _isLive;
			});
			
			LiveCoding.onJoin = function ():void {
				isLive = true;
				_timerCounter = 9;
				_time = getTimer();
				addEventListener(Event.ENTER_FRAME, updateTimer);
			};
			
			LiveCoding.onMemberUpdate = updateViewerCount;
			
			
			addChild(_tfTimer = new TextField);
			addChild(_tfViewer = new TextField);
			
			_tfTimer.embedFonts = _tfViewer.embedFonts = true;
			
			var tfm:TextFormat = new TextFormat(FontSetting.GOTHIC_FONT, 8, 0xffffff);
			_tfTimer.defaultTextFormat = tfm;
			_tfViewer.defaultTextFormat = tfm;
			
			//trace(font, font.fontStyle, font.fontName, font.fontType);
			
			_tfTimer.text = 'Time: ';
			_tfViewer.text = 'viewer: ';
			
			_tfTimer.height = _tfTimer.textHeight + 4;
			_tfViewer.height = _tfViewer.textHeight + 4;
			updatePosition();
			height = sp.height;
			
			isLive = false;
			setViewCount(0);
		}
		
		private function set isLive(value:Boolean):void {
			_tfTimer.visible = value;
			_tfViewer.visible = value;
			_onImage.visible = value;
			_clickable = true;
			
			_isLive = value;
		}
		
		private function startLive():Boolean {
			_tfTimer.width = 0;
			_tfViewer.width = 0;
			LiveCoding.start();
			
			return true;
		}
		
		private function stopLive():Boolean {
			LiveCoding.stop();
			removeEventListener(Event.ENTER_FRAME, updateTimer);
			
			return false;
		}
		
		private function updateTimer(e:Event):void 
		{
			if (_timerCounter++ == 9) {
				_tfTimer.text = 'Time: ' + calcTimeString((getTimer() - _time)/1000);
				updatePosition();
				_timerCounter = 0;
			}
		}
		
		private function calcTimeString($time:int):String
		{
			var result:Array = [];
			var i:int = 0;
			while (i++ < 2 || $time > 0) {
				result.unshift(fillString($time % 60));
				$time /= 60;
			} 
			
			return result.join(':');
		}
		
		private function fillString($n:int):String {
			return ($n < 10) ? '0' + $n : '' + $n;
		}
		
		public function updateViewerCount($event:LiveCodingEvent):void {
			setViewCount(parseInt($event.data.count));
		}
		
		private function setViewCount($count:int):void {
			_tfViewer.text = 'Viewer' + (($count > 1) ? 's' : '') + ': ' + $count;
			updatePosition();
		}
		
		public function updatePosition():void {
			var w:int;
			w = _tfViewer.textWidth + 4;
			_tfViewer.width = (w > _tfViewer.width) ? w : _tfViewer.width;
			w = _tfTimer.textWidth + 4;
			_tfTimer.width = (w > _tfTimer.width) ? w : _tfTimer.width;
			_tfTimer.x = _onImage.width + 10;
			_tfViewer.x = _tfTimer.x + _tfTimer.width + 10;
		}
		
		override protected function updateSize():void 
		{
			updatePosition();
		}
	}

}