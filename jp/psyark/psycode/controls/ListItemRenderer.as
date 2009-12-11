package jp.psyark.psycode.controls 
{
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;

public class ListItemRenderer extends UIControl {
	private var _data:Object;
	private var _labelField:String;
	private var label:TextField;
	
	public function ListItemRenderer() {
		label = new TextField();
		label.selectable = false;
		label.defaultTextFormat = new TextFormat("_typewriter", 13, 0xffffff);
		label.backgroundColor = 0xE8F8FF;
		addChild(label);
		updateView();
		
		addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
		addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
	}
	
	public function get data():Object {
		return _data;
	}
	
	public function set data(value:Object):void {
		if (_data != value) {
			_data = value;
			updateView();
		}
	}
	
	/**
	 * ラベルとして使うプロパティ名を取得または設定します。
	 */
	public function get labelField():String {
		return _labelField;
	}
	
	/**
	 * @private
	 */
	public function set labelField(value:String):void {
		if (_labelField != value) {
			_labelField = value;
			updateView();
		}
	}
	
	protected function updateView():void {
		if (data) {
			try {
				label.text = data[labelField];
			} catch (e:*) {
				label.text = "";
			}
			label.visible = true;
		} else {
			label.visible = false;
		}
	}
	
	protected override function updateSize():void {
		label.width = width;
		label.height = height;
	}
	
	protected function rollOverHandler(event:MouseEvent):void {
		label.background = true;
	}
	
	protected function rollOutHandler(event:MouseEvent):void {
		label.background = false;
	}
}


}