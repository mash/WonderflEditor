package net.wonderfl.editor.manager 
{
	import flash.events.KeyboardEvent;
	
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public interface IKeyboadEventManager 
	{
		function keyDownHandler($event:KeyboardEvent):Boolean;
		function get imeMode():Boolean;
	}
	
}