package ro.minibuilder.main.editor
{
	import ro.victordramba.util.StringEx;
	public class Location
	{
		public var path:String;
		public var pos:int;
		
		public function Location(path:String, pos:int)
		{
			this.pos = pos;
			this.path = path;
		}
	}
}
