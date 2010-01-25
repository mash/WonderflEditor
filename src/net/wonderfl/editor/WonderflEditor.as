package net.wonderfl.editor 
{
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextFormat;
import flash.text.TextLineMetrics;
import flash.utils.clearTimeout;
import flash.utils.getTimer;
import flash.utils.setTimeout;
import net.wonderfl.controls.Editor;
import net.wonderfl.editor.error.ErrorMessage;

import net.wonderfl.editor.completion.AutoCompletion;
import ro.victordramba.thread.ThreadsController;
/**
 * ...
 * @author kobayashi-taro
 */
[Event(name = "change", type = "flash.events.Event")]
public class WonderflEditor extends Editor
{
	private static const ERROR_COLOR:uint = 0x5d2917;
	private static const CHECK_MOUSE_DURATION:int = 500;
	private var _ctrl:ASParserController;
	private var _runs:Array = [];
	private var _autoCompletion:AutoCompletion;
	private var _errors:Array = [];
	private var _fileName:String = "";
	private var _toolTip:ToolTip;
	
	public function WonderflEditor() 
	{
		var _this:WonderflEditor = this;
		var notificationLayer:Sprite;
		addChild(notificationLayer = new Sprite);
		
		notificationLayer.mouseEnabled = false;
		notificationLayer.mouseChildren = false;
		
		notificationLayer.addChild(_toolTip = new ToolTip);
		_toolTip.visible = false;
		
		addEventListener(Event.ADDED_TO_STAGE, function ():void {
			_ctrl = new ASParserController(stage, _this);
			
			_autoCompletion = new AutoCompletion(_this, _ctrl, stage, onAssistComplete);
			_autoCompletion.addEventListener(Event.SELECT, codeHintSelectHandler);
			addChild(_autoCompletion);
			_autoCompletion.deactivate();
			
			setTimeout(checkMouse, CHECK_MOUSE_DURATION);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function ():void {
				checkMouse();
			});
			addEventListener(Event.CHANGE, onChange);
		});
	}
	
	private function checkMouse():void
	{
		var len:int = _errors.length;
		var i:int;
		var msg:ErrorMessage;
		var rect:Rectangle;
		for (i = 0; i < len; ++i) {
			msg = _errors[i];
			rect = msg.rect;
			
			if (rect.left < mouseX && mouseX < rect.right &&
				rect.top < mouseY && mouseY < rect.bottom) {
				
				_toolTip.setMessage(msg.message);
				_toolTip.x = rect.x;
				_toolTip.y = rect.y + rect.height;
				_toolTip.visible = true;
				
				return;
			}
		}
		_toolTip.visible = false;
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
		/* stop autocompletion when the source is MXML */
		if (text.charAt(0) == "<" && isMXML(text)) return false;
		
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
			textField.setTextFormat(tfm, $run.begin, $run.end);
		});
		
		trace('coloring' +  (getTimer() - t) + ' ms');
	}
	
	public function clearErrors():void {
		_errors.length = 0;
		setErrorPositions([]);
		draw();
	}
	
	public function setError($row:int, $col:int, $message:String):void {
		_errors.push(new ErrorMessage([$row, $col, $message]));
		
		// draw error positions
		setErrorPositions(_errors.map(errosCallback));
		
		draw();
	}
	
	private function errosCallback($item:ErrorMessage, $index:int, $arr:Array):int {
		return $item.row;
	}
				
	override protected function drawErrorMessages():void 
	{
		var top:int = scrollV - 1;
		var bottom:int = textField.bottomScrollV - 1;
		var len:int = _errors.length;
		var row:int;
		var msg:ErrorMessage;
		var tlm:TextLineMetrics;
		var rect:Rectangle;
		
		trace("scrollV: " + scrollV);
		
		graphics.beginFill(ERROR_COLOR);
		for (var i:int = 0; i < len; ++i) {
			msg = _errors[i];
			row = msg.row;
			try {
				tlm = textField.getLineMetrics(row);
				rect = textField.getCharBoundaries(textField.getLineOffset(row));
				msg.rect.x = rect.x;
				msg.rect.y = rect.y - linumField.getLinePos(scrollV - 1);
				msg.rect.width = width;
				msg.rect.height = tlm.height;
				_errors[i] = msg;
			} catch (e:Error) {
				continue;
			}
			//if (row >= top && row <= bottom) {
				rect = msg.rect;
				graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
			//}
		}
		graphics.endFill();
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