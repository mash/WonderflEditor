package ro.minibuilder.swcparser.abc
{
	internal class TypeName extends Multiname_
	{
		public var types:Array;
		function TypeName(name:Multiname_, types:Array)
		{
			super(name.nsset, name.name);
			this.types = types;
		}
		
		override public function toString():String
		{
			var s : String = super.toString();
			s += ".<"
			for( var i:int = 0; i < types.length; ++i )
				s += types[i] != null ? types[i].toString() : "*" + " ";
			s += ">"
			return s;
		}
	}
}