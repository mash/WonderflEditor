package net.wonderfl.editor 
{
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public interface IScriptArea 
	{
		function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void;
		function get lastLineIndex():int;
		function get text():String;
		function get textField():TextField;
	}
	
}