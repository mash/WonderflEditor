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
		
		public function ImportStructure($imports:HashMap, $pos:int) 
		{
			imports = $imports;
			pos = $pos;
		}
		
	}

}