package jp.psyark.utils 
{
public function convertNewlines(str:String, newline:String="\n"):String {
	return str.replace(/\r\n|\r|\n/g, newline);
}

}