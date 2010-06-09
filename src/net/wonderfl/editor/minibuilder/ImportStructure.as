package net.wonderfl.editor.minibuilder 
{
	import ro.victordramba.util.HashMap;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ImportStructure
	{
		public var imports:HashMap;
		public var pos:int;
		
		public function ImportStructure($imports:HashMap = null, $pos:int = 0) 
		{
			imports = $imports;
			pos = $pos;
		}
		
	}

}