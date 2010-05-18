package jp.psyark.utils 
{
	public class CodeUtil {
	public static function getDefinitionLocalName(code:String):String {
		var match:Array = code.match(/\Wpublic\s+(?:class|interface|function|namespace)\s+([_a-zA-Z]\w*)/);
		return match && match[1] ? match[1] : "";
	}
	
	public static function getDefinitionName(code:String):String {
		var result:String = getDefinitionLocalName(code);
		if (result == "") {
			return "";
		}
		
		var match:Array = code.match(/package\s+([_a-zA-Z]\w*(?:\.[_a-zA-Z]\w*)*)/);
		if (match && match[1]) {
			result = match[1] + "." + result;
		}
		return result;
	}
}

}