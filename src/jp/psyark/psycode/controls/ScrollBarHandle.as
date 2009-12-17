package jp.psyark.psycode.controls 
{
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.geom.ColorTransform;
import flash.geom.Matrix;


public class ScrollBarHandle extends SimpleButton {
	protected static var handleColors:Array = [0xF7F7F7, 0xECECEC, 0xD8D8D8, 0xCCCCCC, 0xEDEDED];
	protected static var handleAlphas:Array = [1, 1, 1, 1, 1];
	protected static var handleRatios:Array = [0x00, 0x66, 0x80, 0xDD, 0xFF];
	protected static var iconColors:Array = [0x000000, 0xFFFFFF];
	protected static var iconAlphas:Array = [1, 1];
	protected static var iconRatios:Array = [0x00, 0xFF];
	
	private var direction:String;
	private var upFace:Shape;
	private var overFace:Shape;
	
	public function ScrollBarHandle(direction:String="vertical") {
		this.direction = direction;
		cacheAsBitmap = true;
		useHandCursor = false;
		
		upFace = new Shape();
		overFace = new Shape();
		overFace.transform.colorTransform = new ColorTransform(0, 0, 0, 1, 0x69, 0x45, 0x43);
		
		upState = upFace;
		overState = overFace;
		downState = overFace;
		hitTestState = upFace;
	}
	
	public function setSize(w:Number, h:Number):void {
		drawFace(upFace.graphics, w, h);
		drawFace(overFace.graphics, w, h);
	}
	
	protected function drawFace(graphics:Graphics, w:Number, h:Number):void {
		var mtx:Matrix = new Matrix();
		mtx.createGradientBox(w, h, direction == ScrollBar.VERTICAL ? 0 : Math.PI / 2);
		
		graphics.clear();
		graphics.beginFill(0x5d5d5d);
		graphics.drawRoundRect(0, 0, w, h, 2);
		//graphics.beginGradientFill(GradientType.LINEAR, handleColors, handleAlphas, handleRatios, mtx);
		graphics.beginFill(0x403f3d);
		graphics.drawRect(1, 1, w - 2, h - 2);
		
		graphics.lineStyle(-1, 0xEEEEEE);
		graphics.beginGradientFill(GradientType.LINEAR, iconColors, iconAlphas, iconRatios, mtx);
		//for (var i:int=-1; i<2; i++) {
			//if (direction == ScrollBar.VERTICAL) {
				//graphics.drawRoundRect((w - 8) / 2, (h - 3) / 2 + i * 3, 8, 3, 2);
			//} else {
				//graphics.drawRoundRect((w - 3) / 2 + i * 3, (h - 8) / 2, 3, 8, 2);
			//}
		//}
	}
}
}