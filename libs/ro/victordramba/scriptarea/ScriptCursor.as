package ro.victordramba.scriptarea
{
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.utils.setInterval;
	import flash.utils.Timer;

	public class ScriptCursor extends Sprite
	{
		public static var height:int;
		private var _blinkTimer:Timer;
		private var _blinkRestartTimer:Timer;
		private var crs:Shape;
		
		public function ScriptCursor()
		{
			_blinkTimer = new Timer(500);
			_blinkTimer.addEventListener(TimerEvent.TIMER, function ():void {
				redraw();
			});
			_blinkRestartTimer = new Timer(300);
			_blinkRestartTimer.addEventListener(TimerEvent.TIMER, function ():void {
				_blinkTimer.start();
			});
			_blinkTimer.start();
			crs = new Shape;
			addChild(crs);
		}
		
		private function redraw():void
		{
			b = !b;
			crs.graphics.clear();
			if (b)
			{
				crs.graphics.beginFill(0xffffff, 1);
				crs.graphics.drawRect(0, 0, 2, ScriptCursor.height);
			}
		}
		
		public function pauseBlink():void
		{
			b = false;
			redraw();
			b = false;
			_blinkTimer.stop();
		}
		
		public function setSize(w:int, h:int):void
		{
			graphics.clear();
			var m:Matrix = new Matrix;
			m.createGradientBox(w, h, Math.PI/2);
			graphics.beginGradientFill(GradientType.LINEAR, [0xffffff,0xffffff], [0.04,.09],[0,255], m);
			graphics.drawRect(0, 0, w, h);
			graphics.endFill();
		}
		
		public function setX(x:int):void
		{
			pauseBlink();
			_blinkRestartTimer.stop();
			_blinkRestartTimer.reset();
			_blinkRestartTimer.start();
			crs.x = x;
		}
		
		public function getX():int
		{
			return crs.x;
		}
		
		private var b:Boolean = true;
	}
}