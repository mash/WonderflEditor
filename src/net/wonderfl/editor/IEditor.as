package net.wonderfl.editor 
{
	
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public interface IEditor 
	{
		function selectAll():void;
		function copy():void;
		function paste():void;
		function cut():void;
		function saveCode():void;
		function get text():String;
		function get selectionBeginIndex():int;
		function get selectionEndIndex():int;
	}
	
}