package net.wonderfl.utils 
{
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public function calcFontBox($textFormat:TextFormat) : Rectangle
	{
		var tf:TextField = new TextField;
		tf.text = ' ';
		tf.setTextFormat($textFormat);
		
		return new Rectangle(0, 0, tf.textWidth + 4, tf.textHeight + 4);
	}
}