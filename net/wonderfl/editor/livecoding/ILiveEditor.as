package net.wonderfl.editor.livecoding 
{
	public interface ILiveEditor 
	{
		// to broadcast current selection and the caret pos
		function setSelection($selectionBeginIndex:int, $selectionEndIndex:int):void;
		// to broadcast current text of the editor
		function replaceText($beginIndex:int, $endIndex:int, $newText:String):void;
		// to send the current text of the editor
		function sendCurrentText():void;
		// to notify the end of live coding
		function closeLiveCoding():void;
		// to notify when swf is reloaded
		function onSWFReloaded():void;
		// to broadcast scrollV position
		function setScrollV($scrollV:int):void;
		// to broadcast scrollH position
		function setScrollH($scrollH:int):void;
	}
}