package ro.minibuilder.swcparser.abc
{
	internal class Namespace_
	{
		public var name:String;
		public var type:String;
		function Namespace_(name:String, type:String)
		{
			this.name = name;
			this.type = type;
		}
		
		public function toString():String
		{
			return (type ? '[' + type + ']' : '') + name;
		}
	}
}