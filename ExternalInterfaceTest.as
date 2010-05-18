package
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	import net.hires.debug.Stats;
	
	public class ExternalInterfaceTest extends Sprite
	{
		private var _bd:BitmapData;
		private var _count:int = 0;
		private var _tf:TextField;
		
		public function ExternalInterfaceTest()
		{
			addChild(new Stats);
			_bd = new BitmapData(100, 100);
			_tf = new TextField;
			_tf.x = 100;
			addChild(_tf);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private var _func:Function = new Function;
		
		private function onEnterFrame(e:Event):void {
			for (var i:int = 0; i < 100; ++i) {
				ExternalInterface.addCallback(
					"func_" + _count++,
					_func
				);
				
				if (_count > 100) {
					/*ExternalInterface.call(
					'(function () {delete window["ExternalInterfaceTest"]["func_' + (_count - 100) + '"];})();'
					);*/
					//trace('(function () {delete window["ExternalInterfaceTest"]["func_' + (_count - 100) + '"];})();');
					//ExternalInterface.addCallback("func_" + (_count - 100), null);
					//ExternalInterface.call('(function () {window["ExternalInterfaceTest"][func_'+(_count - 100)+'] = null;})()');
				}
				
				_tf.text = _count + '';
				_tf.width = _tf.textWidth + 4;
				
				
				if (_count > 1000) {
					_count %= 1000;
				}
			}
		}
	}
}