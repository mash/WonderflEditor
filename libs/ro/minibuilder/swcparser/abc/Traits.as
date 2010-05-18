package ro.minibuilder.swcparser.abc
{
	import __AS3__.vec.Vector;
	import ro.minibuilder.asparser.TypeDB;

	internal class Traits
	{
		public var name:Multiname_
		public var init:MethodInfo
		public var itraits:Traits
		public var base:Multiname_
		public var flags:int
		public var protectedNs:String
		public const interfaces:Array = []
		//public const names:Object = {}
		//public const slots:Array = []
		//public const methods:Array = []
		public const members:Vector.<MemberInfo> = new Vector.<MemberInfo>;
		
		public function toString():String
		{
			return String(name)
		}
		
		public function dump(abc:Abc, attr:String, typeDB:TypeDB):void
		{
			var i:int=0;
			for each (var m:MemberInfo in members)
			{
				//m.dump(abc, attr, typeDB)
				m.dbDump(typeDB);
			}
		}
	}
}