package jp.psyark.utils 
{
public function escapeText(str:String):String {
	return EscapeTextInternal.escapeText(str);
}

public class EscapeTextInternal {
	private static var table:Object;
	{
		table = {};
		table["\t"] = "\\t";
		table["\r"] = "\\r";
		table["\n"] = "\\n";
		table["\\"] = "\\\\";
	}
	
	public static function escapeText(str:String):String {
		return str.replace(/[\t\r\n\\]/g, replace);
	}
	
	private static function replace(match:String, index:int, source:String):String {
		return table[match];
	}
}

}