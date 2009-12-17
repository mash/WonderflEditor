package ro.minibuilder.swcparser.abc
{
	import ro.minibuilder.asparser.Field;
	import ro.minibuilder.asparser.Multiname;
	import ro.minibuilder.asparser.TypeDB;
	import ro.victordramba.util.HashMap;

	internal class SlotInfo extends MemberInfo
	{
		public var value:*
		public function format():String
		{
			return traitKinds[kind] +' '+ name + ":" + type +
				(value !== undefined ? (" = " + (value is String ? ('"'+value+'"') : value)) : "")// +
			//"\t/* slot_id " + id + " */"
		}
		
		override public function dbDump(typeDB:TypeDB):void
		{
			//slots are classes, vars and consts
			if (kind == TRAIT_Const || kind == TRAIT_Slot)
			{
				var f:Field = createField();
				typeDB.addDefinition(name.nsset[0].name, f);
				//Abc.log('1 ' + name.nsset[0].name + ' ' + f);
				return;
			}
			// else, class
			
			var ct:Traits = value; //class traits (statics)
			var it:Traits = ct.itraits; //instance traits
			
			//typedb
			var field:Field = new Field(it.flags & CLASS_FLAG_interface ? 'interface' : 'class');
			field.name = name.name;
			var ns:Namespace_ = name.nsset[0];
			field.access = ns.type == 'public' ? 'public' : 'internal';
			typeDB.addDefinition(name.nsset[0].name, field);
			//debug('add field '+field.name+' in '+name.nsset[0].name);
			//Abc.log('2 ' + name.nsset[0].name + ' ' + field);
			
			//extends
			var h:HashMap = new HashMap;
			//simulate the import
			var imprt:String = it.base.nsset[0].name+'.'+it.base.name;
			h.setValue(imprt, imprt);
			field.extendz = new Multiname(it.base.name, h);
			
			//members
			var m:MemberInfo;
			var fld:Field;
			//constructor
			if (it.init)
			{
				field.addMember(fld = it.init.createField(), false);
				//Abc.log('3 '+fld);
			}
			//static
			for each (m in ct.members)
			{
				field.addMember(fld = m.createField(), true);
				//Abc.log('4 '+fld);
			}
			//instance
			for each (m in it.members)
			{
				field.addMember(fld = m.createField(), false);
				//Abc.log('5 '+fld);
			}
		}
		
		override public function dump(abc:Abc, attr:String, typeDB:TypeDB):void
		{
			if (kind == TRAIT_Const || kind == TRAIT_Slot)
			{
				if (metadata) {
					for each (var md:MetaData in metadata)
					Abc.log(md)
				}
				Abc.log('slot '+attr+format())
				return
			}
			
			// else, class
			var ct:Traits = value
			var it:Traits = ct.itraits
			//dumpPrint('')
			if (metadata) {
				for each (md in metadata)
				Abc.log(md)
			}
			
			
			var def:String;
			if (it.flags & CLASS_FLAG_interface)
				def = "interface"
			else 
			{
				def = "class";
				if (!(it.flags & CLASS_FLAG_sealed))
					def = "dynamic " + def;
				if (it.flags & CLASS_FLAG_final)
					def = "final " + def;
			}
			
			Abc.log(attr+def+" "+name+" extends "+it.base)
			if (it.interfaces.length > 0)
				Abc.log("implements "+it.interfaces)
			Abc.log("{")
			it.init.dump(abc, '1	', typeDB)
			it.dump(abc, '2	', typeDB)
			ct.dump(abc,"3	static ", typeDB)
			//ct.init.dump(abc,"static ")
			Abc.log("}\n")
		}
	}
}