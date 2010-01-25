package jp.psyark.psycode.controls 
{
import flash.events.Event;
import flash.text.TextField;

public class TextScrollBar extends ScrollBar {
	protected var target:TextField;
	
	public function TextScrollBar(target:TextField, direction:String="vertical") {
		this.target = target;
		super(direction);
		
		if (direction == VERTICAL) {
			minValue = 1;
			value = 1;
		}
		
		addEventListener(Event.CHANGE, changeHandler);
		target.addEventListener(Event.CHANGE, targetChangeHandler);
		target.addEventListener(Event.SCROLL, targetScrollHandler);
		
		targetChangeHandler(null);
		targetScrollHandler(null);
	}
	
	private function changeHandler(event:Event):void {
		if (direction == VERTICAL) {
			target.scrollV = Math.round(value);
		} else {
			target.scrollH = Math.round(value);
		}
	}
	
	private function targetChangeHandler(event:Event):void {
		correctTextFieldScrollPosition(target);
		if (direction == VERTICAL) {
			maxValue = target.maxScrollV;
			viewSize = target.bottomScrollV - target.scrollV;
		} else {
			maxValue = target.maxScrollH;
			viewSize = target.width;
		}
	}
	
	private function targetScrollHandler(event:Event):void {
		correctTextFieldScrollPosition(target);
		if (direction == VERTICAL) {
			value = target.scrollV;
		} else {
			value = target.scrollH;
		}
	}
	
	protected override function updateSize():void {
		super.updateSize();
		targetChangeHandler(null);
	}
	
	
	/**
	 * 時折不正確な値を返すTextField#scrollVが、正しい値を返すようにする
	 */
	protected static function correctTextFieldScrollPosition(target:TextField):void {
		// textWidthかtextHeightにアクセスすればOK
		target.textWidth;
		target.textHeight;
	}
}
}