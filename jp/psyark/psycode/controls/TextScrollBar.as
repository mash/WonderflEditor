package jp.psyark.psycode.controls 
{
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextLineMetrics;
import flash.utils.setTimeout;
import jp.psyark.utils.callLater;

public class TextScrollBar extends ScrollBar {
	protected var target:TextField;
	private var _prevTargetLength:int;
	
	public function TextScrollBar(target:TextField, direction:String="vertical") {
		this.target = target;
		super(direction);
		
		if (direction == VERTICAL) {
			minValue = 1;
			value = 1;
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		addEventListener(Event.CHANGE, changeHandler);
		target.addEventListener(Event.CHANGE, targetChangeHandler);
		target.addEventListener(Event.SCROLL, targetScrollHandler);
		
		targetChangeHandler(null);
		targetScrollHandler(null);
	}
	
	private function init(e:Event):void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, init);
		
		stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
	}
	
	private function onMouseWheel(e:MouseEvent):void 
	{
		target.scrollV -= e.delta;
		dispatchEvent(new Event(Event.CHANGE));
	}
	
	private function changeHandler(event:Event):void {
		if (direction == VERTICAL) {
			target.scrollV = value << 0;
		} else {
			target.scrollH = value << 0;
		}
	}
	
	private function targetChangeHandler(event:Event):void {
		correctTextFieldScrollPosition(target);
		if (direction == VERTICAL) {
			maxValue = target.maxScrollV;
			viewSize = target.bottomScrollV - target.scrollV;
			
			callLater(function ():void {
				maxValue = target.maxScrollV;
				viewSize = target.bottomScrollV - target.scrollV;
			},[],10);
			
			_prevTargetLength = target.length;
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