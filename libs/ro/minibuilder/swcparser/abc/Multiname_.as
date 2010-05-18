package ro.minibuilder.swcparser.abc
{
	import ro.minibuilder.asparser.Multiname;
	import ro.victordramba.util.HashMap;

	internal class Multiname_
	{
		public var nsset:Array/* of Namespace_*/
		public var name:String
		function Multiname_(nsset:Array, name:String)
		{
			this.nsset = nsset
			this.name = name
		}
		
		public function toString():String
		{
			/*if (nsset && nsset.length == 1)
			{
			var ns:Namespace_ = nsset[0];
			if (ns.type == 'private') return 'private ' + name;
			if (ns.type == 'protected') return 'protected ' + name;
			if (ns.name == '') return 'public ' + name;
			//else return '';
			}*/
			return '{' + nsset + '}::' + name
		}
		
		public function toMultiname():Multiname
		{
			var h:HashMap = new HashMap;
			if (nsset && nsset.length)
			{
				var ns:Namespace_;
				for each (ns in nsset)
				h.setValue(ns.name+'.*', ns.name+'.*');
			}
			return new Multiname(name, h);
		}
	}
}