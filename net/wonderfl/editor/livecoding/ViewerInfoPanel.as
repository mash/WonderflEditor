package net.wonderfl.editor.livecoding 
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.Style;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import jp.psyark.psycode.controls.UIControl;
	import mx.effects.easing.Quadratic;
	/**
	 * @author kobayashi-taro
	 */
	public class ViewerInfoPanel extends UIControl
	{
		[Embed(source = '../../../../../assets/on_live.png')]
		private var _onClass:Class;
		private var _onImage:Bitmap = new _onClass;
		private var _tfTimer:TextField;
		private var _tfViewer:TextField;
		private var _elapsed_time:int = 0;
		private var _timerCounter:int;
		private var _time:int;
		private var _blink_count:int = 0;
		private var _isSync:Boolean = true;
		private const BLINK_PERIOD:int = 50;
		private var _syncButton:CheckBox;
		
		public function ViewerInfoPanel() 
		{
			var sp:Sprite = new Sprite;
			sp.buttonMode = true;
			sp.tabEnabled = false;
			sp.addChild(_onImage);
			addChild(sp);
			
			addChild(_tfTimer = new TextField);
			addChild(_tfViewer = new TextField);
			
			var tfm:TextFormat = new TextFormat("PF Ronda Seven", 8, Style.LABEL_TEXT)
			_tfTimer.defaultTextFormat = tfm;
			_tfViewer.defaultTextFormat = tfm;
			_tfTimer.embedFonts = _tfViewer.embedFonts = true;
			_tfTimer.text = 'Time: ';
			_tfViewer.text = 'viewer: ';
			
			_syncButton = new CheckBox(this, _onImage.width + 5, 5, 'Sync', function ():void {
				_isSync = !_isSync;
			});
			_syncButton.selected = true;
			
			_tfTimer.width = _tfViewer.width = 0;
			_tfTimer.height = _tfTimer.textHeight + 4;
			_tfViewer.height = _tfViewer.textHeight + 4;
			updatePosition();
			height = sp.height;
			
			setViewCount(0);
		}
		
		public function updatePosition():void {
			var w:int;
			w = _tfViewer.textWidth + 4;
			_tfViewer.width = (w > _tfViewer.width) ? w : _tfViewer.width;
			w = _tfTimer.textWidth + 4;
			_tfTimer.width = (w > _tfTimer.width) ? w : _tfTimer.width;
			_tfViewer.x = width - _tfViewer.width - 10;
			_tfTimer.x = _tfViewer.x - _tfTimer.width - 10;
			//_syncButton.x = _tfTimer.x - _syncButton.width - 30;
		}
		
		public function onMemberUpdate($event:LiveCodingEvent):void {
			setViewCount(parseInt($event.data.count));
		}
		
		private function setViewCount($count:int):void {
			_tfViewer.text = 'Viewer' + (($count > 1) ? 's' : '')+ ': ' + $count;
			updatePosition();
		}
		
		public function set elapsed_time(value:int):void 
		{
			_elapsed_time = value;
			_timerCounter = 9;
			_time = getTimer();
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		public function get isSync():Boolean { return _isSync; }
		
		private function update(e:Event):void 
		{
			_onImage.alpha = Quadratic.easeOut((_blink_count > BLINK_PERIOD) ? 2 * BLINK_PERIOD - _blink_count : _blink_count,
											  0, 1, BLINK_PERIOD);
			_blink_count++;
			_blink_count %= 2 * BLINK_PERIOD;
			
			updateTimer(e);
		}
		
		public function stop():void {
			removeEventListener(Event.ENTER_FRAME, update);
		}
		
		public function restart():void {
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		
		private function updateTimer(e:Event):void 
		{
			if (_timerCounter++ == 9) {
				_tfTimer.text = 'Time: ' + calcTimeString(_elapsed_time + (getTimer() - _time)/1000);
				updatePosition();
				_timerCounter = 0;
			}
		}
		
		override protected function updateSize():void 
		{
			graphics.clear();
			graphics.beginFill(0x222222);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
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
	}
}