package jp.psyark.utils 
{
	public function callLater(func:Function, args:Array=null, frame:int=1):void {
		Helper.callLater(func, args, frame);
	}
}


import flash.display.MovieClip;
import flash.events.Event;

internal class Helper {
	private static var engine:MovieClip = new MovieClip();
	
	public static function callLater(func:Function, args:Array=null, frame:int=1):void {
		engine.addEventListener(Event.ENTER_FRAME, function(event:Event):void {
			if (--frame <= 0) {
				engine.removeEventListener(Event.ENTER_FRAME, arguments.callee);
				func.apply(null, args);
			}
		});
	}
}
