package net.wonderfl.editor 
{
import flash.events.Event;
import flash.text.TextFormat;
import flash.utils.getTimer;
import net.wonderfl.controls.Editor;

import net.wonderfl.editor.completion.AutoCompletion;
import ro.victordramba.thread.ThreadsController;
/**
 * ...
 * @author kobayashi-taro
 */
[Event(name = "change", type = "flash.events.Event")]
public class WonderflEditor extends Editor
{
	private var _ctrl:ASParserController;
	private var _runs:Array = [];
	private var _autoCompletion:AutoCompletion;
	private var _fileName:String = "";
	
	public function WonderflEditor() 
	{
		var _this:WonderflEditor = this;
		addEventListener(Event.ADDED_TO_STAGE, function ():void {
			_ctrl = new ASParserController(stage, _this);
			
			_autoCompletion = new AutoCompletion(_this, _ctrl, stage, onAssistComplete);
			_autoCompletion.addEventListener(Event.SELECT, codeHintSelectHandler);
			addChild(_autoCompletion);
			_autoCompletion.deactivate();
			
			addEventListener(Event.CHANGE, onChange);
		});
	}
	
	public function get status():String
	{
		return _ctrl.status;
	}
	
	public function get percentReady():Number
	{
		return _ctrl.percentReady;
	}
	
	
	private function onAssistComplete():void
	{
		_ctrl.sourceChanged(text, _fileName);
	}
	
	private function onChange(e:Event):void
	{
		if (triggerAssist())
			_autoCompletion.triggerAssist();
			//assistMenu.triggerAssist();
		else
			_ctrl.sourceChanged(text, _fileName);
	}
	
	protected function triggerAssist():Boolean
	{
		var str:String = text.substring(Math.max(0, selectionBeginIndex-10), selectionBeginIndex);
		str = str.split('').reverse().join('');
		return (/^(?:\(|\:|\.|\s+sa\b|\swen\b|\ssdnetxe)/.test(str))
	}
	
	public function addFormatRun(beginIndex:int, endIndex:int, bold:Boolean, italic:Boolean, color:String):void
	{
		_runs.push({begin:beginIndex, end:endIndex, color:color, bold:bold, italic:italic});
	}
	
	public function clearFormatRuns():void
	{
		_runs.length = 0;
	}
	
	public function setTextFormat($textFormat:TextFormat, $begin:int = -1, $end:int = -1):void {
		textField.setTextFormat($textFormat, $begin, $end);
	}
	
	// TODO: use set htmlText instead of set text
	public function applyFormatRuns():void
	{
		var t:Number = getTimer();
		
		var tfm:TextFormat = textField.getTextFormat();
		tfm.color = 0xffffff;
		textField.setTextFormat(tfm);
		
		_runs.forEach(function ($run:Object, $index:int, $arr:Array):void {
			var tfm:TextFormat = new TextFormat;
			tfm.color = parseInt("0x" + $run.color);
			tfm.bold = $run.bold;
			tfm.italic = $run.italic;
			//trace($run.begin, $run.end, $run.color, text.substring($run.begin, $run.end));
			textField.setTextFormat(tfm, $run.begin, $run.end);
		});
		
		trace('coloring' +  (getTimer() - t) + ' ms');
	}
	
	
	/**
	 * コードヒントが選択された
	 */
	private function codeHintSelectHandler(event:Event):void {
		//preventFollowingTextInput = false;
		//var newIndex:int = textField.caretIndex - _autoCompletion.captureLength + _autoCompletion.selectedName.length;
		//replaceText(textField.caretIndex - _autoCompletion.captureLength, textField.caretIndex, _autoCompletion.selectedName);
		//setSelection(newIndex, newIndex);
		//dispatchChangeEvent();
	}
	
	
	//public function loadSource(source:String, filePath:String):void
	//{
		//text = source.replace(/(\n|\r\n)/g, '\r');
		//fileName = filePath;
		//ctrl.sourceChanged(text, fileName);
	//}
}
}