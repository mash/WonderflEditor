package jp.psyark.psycode.core.linenumber 
{
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFormat;

/**
 * 行番号表示
 */
public class LineNumberView extends TextField {
	private var target:TextField;
	
	public function LineNumberView(target:TextField) {
		this.target = target;
		
		width = 30;
		//background = true;
		//backgroundColor = 0xF2F2F2;
		multiline = true;
		selectable = false;
		
		target.addEventListener(Event.CHANGE, updateView);
		target.addEventListener(Event.SCROLL, updateView);
	}
	
	public override function setTextFormat(format:TextFormat, beginIndex:int=-1, endIndex:int=-1):void {
		defaultTextFormat = format;
		super.setTextFormat(format);
		updateView(null);
	}
	
	private function updateView(event:Event):void {
		text = "000\n" + target.numLines;
		width = textWidth + 4;
		text = "";
		for (var i:int=target.scrollV; i<=target.bottomScrollV; i++) {
			appendText(i + "\n");
		}
		dispatchEvent(new Event(Event.RESIZE));
	}
}	
}