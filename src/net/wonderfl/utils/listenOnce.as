package net.wonderfl.utils 
{
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public function listenOnce($dispatcher:*, type:String, listener:Function, args:Array = null):Function 
	{
		var f:Function = function ():void {
			$dispatcher.removeEventListener(type, f);
			listener.apply(null, args);
		};
		$dispatcher.addEventListener(type, f);
		return f;
	}
}