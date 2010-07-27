package net.wonderfl.font 
{
	import net.wonderfl.utils.findFont;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class FontSetting
	{
		public static const LINE_HEIGHT:int = 20;
		private static var _gothic_font:String = "";
		
		static public function get GOTHIC_FONT():String { 
			if (_gothic_font != '') return _gothic_font;
			
			_gothic_font = findFont([
				'メイリオ', 'ＭＳ Ｐゴシック', 'ヒラギノ角ゴ Pro W3', 'Arial'
			], '_sans');
			
			return _gothic_font;
		}
		
	}

}