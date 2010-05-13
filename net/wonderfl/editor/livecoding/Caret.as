package net.wonderfl.editor.livecoding 
{
import flash.display.Sprite;
import flash.events.Event;
public class Caret extends Sprite{
	private var _height:Number = 0;
	private var _width:Number = 0;
	private var _color:int;
	private var _count:int;
	private var _hide:Boolean = false;
	private const INTERVAL:int = 30;
	
	public function Caret($h:int, $color:uint) {
		_color = $color;
		setSize(1, $h);
		
		addEventListener(Event.ENTER_FRAME, updateCaret);
	}
	
	private function updateCaret(e:Event):void 
	{

		if (_hide) return;
		_count = ++_count % INTERVAL;
		visible = _count < (INTERVAL >> 1);
	}
	
	public function setSize(w:Number, h:Number):void {
		if (_width != w || _height != h) {
			_width = w;
			_height = h;
			draw();
		}
	}
	
	public function show():void {
		_count = 0;
		_hide = false;
	}
	
	public function hide():void {
		_hide = true;
		visible = false;
	}
	
	private function draw():void {
		graphics.clear();
		graphics.beginFill(_color);
		graphics.drawRect(0, 0, _width, _height);
		
		graphics.endFill();
		show();
	}
}
}