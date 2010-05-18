package net.wonderfl.editor 
{
	import flash.text.TextField;
	
	/**
	 * @author kobayashi-taro
	 */
	public interface IEditor 
	{
		function applyFormatRuns():void;
		function addFormatRun(beginIndex:int, endIndex:int, bold:Boolean, italic:Boolean, color:String):void;
		function clearFormatRuns():void;
		function get text():String;
	}
	
}