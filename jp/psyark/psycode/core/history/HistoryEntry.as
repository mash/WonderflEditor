package jp.psyark.psycode.core.history 
{
public class HistoryEntry {
	public var index:int;
	public var oldText:String;
	public var newText:String;
	
	public function HistoryEntry(index:int=0, oldText:String="", newText:String="") {
		this.index   = index;
		this.oldText = oldText;
		this.newText = newText;
	}
}
}