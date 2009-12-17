package jp.psyark.psycode.controls 
{

import flash.display.Sprite;

public class UIControl extends Sprite {
	private var _width:Number = 100;
	private var _height:Number = 100;
	
	
	/**
	 * コントロールの幅と高さ設定します。
	 */
	public function setSize(width:Number, height:Number):void {
		if (_width != width || _height != height) {
			_width = width;
			_height = height;
			updateSize();
		}
	}
	
	
	/**
	 * コントロールの幅を取得または設定します。
	 */
	public override function get width():Number {
		return _width;
	}
	
	/**
	 * @private
	 */
	public override function set width(value:Number):void {
		if (_width != value) {
			_width = value;
			updateSize();
		}
	}
	
	/**
	 * コントロールの高さを取得または設定します。
	 */
	public override function get height():Number {
		return _height;
	}
	
	/**
	 * @private
	 */
	public override function set height(value:Number):void {
		if (_height != value) {
			_height = value;
			updateSize();
		}
	}
	
	
	/**
	 * コントロールのサイズを更新します。
	 */
	protected function updateSize():void {
	}
}

}