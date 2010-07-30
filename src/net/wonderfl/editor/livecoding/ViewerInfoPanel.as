package net.wonderfl.editor.livecoding 
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.Style;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBaseline;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.utils.getTimer;
	import mx.effects.easing.Quadratic;
	import net.wonderfl.component.core.UIComponent;;
	import net.wonderfl.editor.font.FontSetting;
	import net.wonderfl.utils.removeFromParent;
	/**
	 * @author kobayashi-taro
	 */
	public class ViewerInfoPanel extends UIComponent
	{
		[Embed(source = '../../../../../assets/on_live.png')]
		private var _onClass:Class;
		private var _onImage:Bitmap = new _onClass;
		private var _elapsed_time:int = 0;
		private var _timerCounter:int;
		private var _factory:TextBlock;
		private var _elf:ElementFormat;
		private var _time:int;
		private var _blink_count:int = 0;
		private var _isSync:Boolean = true;
		private const BLINK_PERIOD:int = 50;
		private var _syncButton:CheckBox;
		private var _label:TextLine;
		private var _strTime:String = '--:--';
		private var _strViewer:String = '-';
		
		public function ViewerInfoPanel() 
		{
			var sp:Sprite = new Sprite;
			sp.buttonMode = true;
			sp.tabEnabled = false;
			sp.addChild(_onImage);
			addChild(sp);
			
			_factory = new TextBlock;
			_elf = new ElementFormat(new FontDescription(FontSetting.GOTHIC_FONT), 10);
			_elf.color = 0xffffff;
			_elf.alignmentBaseline = TextBaseline.IDEOGRAPHIC_BOTTOM;
			
			_syncButton = new CheckBox(this, _onImage.width + 5, 5, '', function ():void {
				_isSync = !_isSync;
			});
			_syncButton.selected = true;
			
			height = 20;
			
			updateView(_strViewer, _strTime);
		}
		
		private function updateView($time:String, $viewer:String):void {
			_strTime = $time;
			_strViewer = $viewer;
			removeFromParent(_label);
			_factory.content = new TextElement(
				<>Sync    Time: {$time}  Viewer: {$viewer}</>.toString(), _elf.clone()
			);
			_label = _factory.createTextLine();
			_label.y = _label.height + 2;
			_label.x = 115;
			addChild(_label);
		}
		
		public function onMemberUpdate($event:LiveCodingEvent):void {
			updateView(_strTime, $event.data.count);
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
				updateView(calcTimeString(_elapsed_time + (getTimer() - _time) / 1000), _strViewer);
				_timerCounter = 0;
			}
		}
		
		override protected function updateSize():void 
		{
			graphics.clear();
			graphics.beginFill(0x222222);
			graphics.drawRect(0, 0, _width, _height);
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