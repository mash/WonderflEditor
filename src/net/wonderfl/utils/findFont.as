package net.wonderfl.utils 
{
	import flash.text.Font;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public function findFont($fontList:Array, $defaultFontName:String):String
	{
		$fontList ||= [];
		
		var fonts:Array = Font.enumerateFonts(true).map(function ($item:Font, $index:int, $array:Array):String {
			return $item.fontName;
		});
		
		var fontName:String;
		var len:int = $fontList.length;
		for (var i:int = 0; i < len; ++i) 
		{
			fontName = $fontList[i];
			if (fonts.indexOf(fontName) > -1) return fontName;
		}
		
		return $defaultFontName;
	}
}