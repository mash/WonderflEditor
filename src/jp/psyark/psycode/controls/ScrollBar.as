package jp.psyark.psycode.controls 
{
import flash.display.GradientType;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;

[Event(name="change", type="flash.events.Event")]
public class ScrollBar extends UIControl {
	public static const HORIZONTAL:String = "horizontal";
	public static const VERTICAL:String = "vertical";
	protected const BAR_THICKNESS:Number = 16;
	protected const MIN_HANDLE_LENGTH:Number = 14;
	
	
	protected var handle:ScrollBarHandle;
	protected var track:Sprite;
	protected var draggableSize:Number;
	private var handlePressX:Number;
	private var handlePressY:Number;
	private var dragging:Boolean = false;
	
	protected var trackColors:Array = [0xDDDDDD, 0xECECEC, 0xF5F5F5];
	protected var trackAlphas:Array = [1, 1, 1];
	protected var trackRatios:Array = [0x00, 0x2A, 0xFF];
	
	
	private var _direction:String;
	public function get direction():String {
		return _direction;
	}
	
	private var _value:Number = 0;
	public function get value():Number {
		return _value;
	}
	public function set value(v:Number):void {
		if (_value != v) {
			_value = v;
			updateHandle();
		}
	}
	
	private var _maxValue:Number = 1;
	public function get maxValue():Number {
		return _maxValue;
	}
	public function set maxValue(value:Number):void {
		if (_maxValue != value) {
			_maxValue = value;
			updateHandle();
		}
	}
	
	private var _minValue:Number = 0;
	public function get minValue():Number {
		return _minValue;
	}
	public function set minValue(value:Number):void {
		if (_minValue != value) {
			_minValue = value;
			updateHandle();
		}
	}
	
	private var _viewSize:Number = 0;
	public function get viewSize():Number {
		return _viewSize;
	}
	public function set viewSize(value:Number):void {
		if (_viewSize != value) {
			_viewSize = value;
			updateHandle();
		}
	}
	
	public override function get width():Number {
		return direction == VERTICAL ? BAR_THICKNESS : super.width;
	}
	
	public override function get height():Number {
		return direction == HORIZONTAL ? BAR_THICKNESS : super.height;
	}
	
	public function ScrollBar(direction:String="vertical") {
		if (direction == HORIZONTAL || direction == VERTICAL) {
			_direction = direction;
		} else {
			throw new ArgumentError("direction must be " + HORIZONTAL + " or " + VERTICAL + ".");
		}
		
		track = new Sprite();
		track.addEventListener(MouseEvent.MOUSE_DOWN, trackMouseDownHandler);
		addChild(track);
		
		handle = new ScrollBarHandle(direction);
		handle.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDownHandler);
		addChild(handle);
		invalidateAll();
	}
	
	protected function invalidateAll():void {
		updateTrack();
		updateHandle();
	}
	
	
	/**
	 * スクロールバーの表示を更新します。
	 */
	protected function updateTrack():void {
		var mtx:Matrix = new Matrix();
		
		track.graphics.clear();
		if (direction == VERTICAL) {
			mtx.createGradientBox(BAR_THICKNESS, height);
			//track.graphics.beginGradientFill(GradientType.LINEAR, trackColors, trackAlphas, trackRatios, mtx);
			track.graphics.beginFill(0x1a1a1a);
			track.graphics.drawRect(0, 0, BAR_THICKNESS, height);
		} else {
			mtx.createGradientBox(BAR_THICKNESS, height, Math.PI / 2);
			//track.graphics.beginGradientFill(GradientType.LINEAR, trackColors, trackAlphas, trackRatios, mtx);
			track.graphics.beginFill(0x1a1a1a);
			track.graphics.drawRect(0, 0, width, BAR_THICKNESS);
		}
	}
	
	
	protected function updateHandle():void {
		if (maxValue > minValue) {
			var t:Number = Math.max(minValue, Math.min(maxValue, value));
			if (value != t) {
				value = t;
				dispatchEvent(new Event(Event.CHANGE));
			}
			
			handle.visible = true;
			if (direction == VERTICAL) {
				var handleHeight:Number = MIN_HANDLE_LENGTH + (height - MIN_HANDLE_LENGTH) * viewSize / (maxValue - minValue + viewSize);
				draggableSize = height - handleHeight;
				handle.setSize(BAR_THICKNESS - 1, handleHeight);
				handle.x = 1;
				if (dragging == false) {
					handle.y = (value - minValue) / (maxValue - minValue) * draggableSize;
				}
			} else {
				var handleWidth:Number = MIN_HANDLE_LENGTH + (width - MIN_HANDLE_LENGTH) * viewSize / (maxValue - minValue + viewSize);
				draggableSize = width - handleWidth;
				handle.setSize(handleWidth, BAR_THICKNESS - 1);
				handle.y = 1;
				if (dragging == false) {
					handle.x = (value - minValue) / (maxValue - minValue) * draggableSize;
				}
			}
		} else {
			handle.visible = false;
		}
	}
	
	protected function trackMouseDownHandler(event:MouseEvent):void {
		stageMouseMoveHandler(event);
	}
	
	protected function handleMouseDownHandler(event:MouseEvent):void {
		stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
		stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
		handlePressX = mouseX - handle.x;
		handlePressY = mouseY - handle.y;
		dragging = true;
	}
	
	protected function stageMouseMoveHandler(event:MouseEvent):void {
		event.updateAfterEvent();
		var position:Number;
		if (direction == VERTICAL) {
			position = handle.y = Math.max(0, Math.min(draggableSize, mouseY - handlePressY));
		} else {
			position = handle.x = Math.max(0, Math.min(draggableSize, mouseX - handlePressX));
		}
		var newValue:Number = (position / draggableSize) * (maxValue - minValue) + minValue;
		if (_value != newValue) {
			_value = newValue;
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
	
	protected function stageMouseUpHandler(event:MouseEvent):void {
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
		stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
		dragging = false;
	}
	
	protected override function updateSize():void {
		invalidateAll();
	}
}
}