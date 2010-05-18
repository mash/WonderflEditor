package ro.minibuilder.swcparser.abc
{
	import ro.minibuilder.asparser.Field;
	import ro.minibuilder.asparser.TypeDB;

	internal class MemberInfo extends AbcConstants
	{
		public var id:int
		public var kind:int
		public var type:Multiname_ //var type or method return type
		public var name:Multiname_
		public var metadata:Array
		//abstract
		public function dump(abc:Abc, attr:String, typeDB:TypeDB):void { }    
		//abstract
		public function dbDump(typeDB:TypeDB):void { }
		
		//"var", "function", "function get", "function set", "class", "function", "const"
		public static var fieldKinds:Array = ["var", "function", "get", "set", "class", "function", "var"];
		//abstract
		public function createField():Field
		{
			var f:Field = new Field(null);
			f.fieldType = fieldKinds[kind];
			f.name = name.name;
			f.access = (name.nsset[0] as Namespace_).type;
			f.type = type.toMultiname();
			return f;
		}
	}
}