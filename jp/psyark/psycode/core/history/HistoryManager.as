package jp.psyark.psycode.core.history 
{
import __AS3__.vec.Vector;

public class HistoryManager {
	private var currentIndex:int = 0;
	private var entries:Vector.<HistoryEntry>;
	
	public function HistoryManager() {
		entries = new Vector.<HistoryEntry>();
	}
	
	public function appendEntry(entry:HistoryEntry):void {
		entries.length = currentIndex;
		entries.push(entry);
		currentIndex = entries.length;
	}
	
	public function clear():void {
		currentIndex = 0;
		entries.length = 0;
	}
	
	public function get canForward():Boolean {
		return currentIndex < entries.length;
	}
	
	public function get canBack():Boolean {
		return currentIndex > 0;
	}
	
	public function forward():HistoryEntry {
		return entries[currentIndex++];
	}
	
	public function back():HistoryEntry {
		return entries[--currentIndex];
	}
}

}