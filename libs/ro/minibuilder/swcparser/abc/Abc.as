/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Flash MiniBuilder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.


* The Original Code is [Open Source Virtual Machine.].
*
* The Initial Developer of the Original Code is
* Adobe System Incorporated.
* Portions created by the Initial Developer are Copyright (C) 2004-2006
* the Initial Developer. All Rights Reserved.
*
* Contributor(s):
*   Adobe AS3 Team


Author: Victor Dramba
2009
*/

package ro.minibuilder.swcparser.abc
{
	import __AS3__.vec.Vector;
	
	//import com.victordramba.debug.debug;
	import flash.utils.ByteArray;
	
	import ro.minibuilder.asparser.TypeDB;
	
	public class Abc extends AbcConstants
	{
		private var data:ByteArray
		
		private var major:int
		private var minor:int
		
		private var ints:Vector.<int>;//Array
		private var uints:Vector.<uint>;//Array
		private var doubles:Vector.<Number>;//Array
		private var strings:Vector.<String>;
		private var namespaces:Vector.<Namespace_>; //Array/*of Namespace_*/
		private var nssets:Array
		private var names:Vector.<Multiname_>;//  :Array/*of Multiname*/
		
		private var defaults:Array = new Array(AbcConstants.constantKinds.length)
		
		private var methods:Array
		private var instances:Array
		private var classes:Array
		private var scripts:Array
		
		private var publicNs:Namespace_ = new Namespace_('', 'public')
		private var anyNs:Namespace_ = new Namespace_('*', 'any')
		
		private var magic:int
		
		private var metadata:Array
		
		private var opSizes:Array = new Array(256)
		
		private var typeDB:TypeDB;
		
		private static var logStr:String = '';
		public static function dumpLog():String
		{
			var tmp:String = logStr;
			logStr = '';
			return tmp;
		}
		
		public static function log(str:*):void
		{
			//logStr += str + '\n';
		}
		
		
		function Abc(data:ByteArray, typeDB:TypeDB)
		{
			this.typeDB = typeDB;
			
			data.position = 0
			this.data = data
			magic = data.readInt()
			
			//infoPrint("magic " + magic.toString(16))
			
			if (magic != (46<<16|14) && magic != (46<<16|15) && magic != (46<<16|16))
				throw new Error("not an abc file.  magic=" + magic.toString(16))
			
			parseCpool()
			
			defaults[CONSTANT_Utf8] = strings
			defaults[CONSTANT_Int] = ints
			defaults[CONSTANT_UInt] = uints
			defaults[CONSTANT_Double] = doubles
			defaults[CONSTANT_Int] = ints
			defaults[CONSTANT_False] = { 10:false }
			defaults[CONSTANT_True] = { 11:true }
			defaults[CONSTANT_Namespace] = namespaces
			defaults[CONSTANT_PrivateNs] = namespaces
			defaults[CONSTANT_PackageNs] = namespaces
			defaults[CONSTANT_PackageInternalNs] = namespaces
			defaults[CONSTANT_ProtectedNs] = namespaces
			defaults[CONSTANT_StaticProtectedNs] = namespaces
			defaults[CONSTANT_StaticProtectedNs2] = namespaces
			defaults[CONSTANT_Null] = { 12: null }
			
			parseMethodInfos()
			parseMetadataInfos()
			parseInstanceInfos()
			parseClassInfos()
			parseScriptInfos()
			parseMethodBodies()
			
			/*if (doExtractAbc==true)
			data.writeFile(nextAbcFname());*/
		}
		
		private function readU32():int
		{
			var result:int = data.readUnsignedByte();
			if (!(result & 0x00000080))
				return result;
			result = result & 0x0000007f | data.readUnsignedByte()<<7;
			if (!(result & 0x00004000))
				return result;
			result = result & 0x00003fff | data.readUnsignedByte()<<14;
			if (!(result & 0x00200000))
				return result;
			result = result & 0x001fffff | data.readUnsignedByte()<<21;
			if (!(result & 0x10000000))
				return result;
			return   result & 0x0fffffff | data.readUnsignedByte()<<28;
		}
		
		private function parseCpool():void
		{
			var i:int, j:int
			var n:int
			var kind:int
			
			var start:int = data.position
			
			// ints
			n = readU32()
			ints = new Vector.<int>;//[0]
			ints[0] = 0;
			for (i=1; i < n; i++)
				ints[i] = readU32()
			
			// uints
			n = readU32()
			uints = new Vector.<uint>;//[0]
			uints[0] = 0;
			for (i=1; i < n; i++)
				uints[i] = uint(readU32())
			
			// doubles
			n = readU32()
			doubles = new Vector.<Number>;//[NaN]
			doubles[0] = NaN;
			for (i=1; i < n; i++)
				doubles[i] = data.readDouble()
			
			//infoPrint("Cpool numbers size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+" %")
			start = data.position
			
			// strings
			n = readU32()
			strings = new Vector.<String>;//[""]
			strings[0] = '';
			for (i=1; i < n; i++)
				strings[i] = data.readUTFBytes(readU32())
			
			//infoPrint("Cpool strings count "+ n +" size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+" %")
			start = data.position
			
			// namespaces
			n = readU32()
			namespaces = new Vector.<Namespace_>;
			namespaces[0] = publicNs;
			//[publicNs]
			for (i=1; i < n; i++)
				switch (data.readByte())
				{
					case CONSTANT_Namespace:
					case CONSTANT_PackageNs:
						namespaces[i] = new Namespace_(strings[readU32()], 'public')
						break;
					case CONSTANT_PackageInternalNs:
						namespaces[i] = new Namespace_(strings[readU32()], 'internal')
						break;
					case CONSTANT_ProtectedNs:
						namespaces[i] = new Namespace_(strings[readU32()], 'protected')
						break;
					case CONSTANT_StaticProtectedNs:
					case CONSTANT_StaticProtectedNs2:
						namespaces[i] = new Namespace_(strings[readU32()], 'protected')
						break;
					case CONSTANT_PrivateNs:
						namespaces[i] = new Namespace_(strings[readU32()], 'private')
						break;
				}
			
			//infoPrint("Cpool namespaces count "+ n +" size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+" %")
			start = data.position
			
			// namespace sets
			n = readU32()
			nssets = [null]
			for (i=1; i < n; i++)
			{
				var count:int = readU32()
				var nsset:Array = nssets[i] = []
				for (j=0; j < count; j++)
					nsset[j] = namespaces[readU32()]
			}
			
			//infoPrint("Cpool nssets count "+ n +" size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+" %")
			start = data.position
			
			// multinames
			n = readU32()
			names = new Vector.<Multiname_>;
			names[0] = null;
			//[null]
			namespaces[0] = anyNs
			strings[0] = "*" // any name
			
			for (i=1; i < n; i++)
				switch (data.readByte())
				{
					case CONSTANT_Qname:
					case CONSTANT_QnameA:
						names[i] = new QName_(namespaces[readU32()], strings[readU32()])
						break;
					
					case CONSTANT_RTQname:
					case CONSTANT_RTQnameA:
						names[i] = new QName_(null, strings[readU32()])
						break;
					
					case CONSTANT_RTQnameL:
					case CONSTANT_RTQnameLA:
						names[i] = null
						break;
					
					case CONSTANT_NameL:
					case CONSTANT_NameLA:
						names[i] = new QName_(null, null)
						break;
					
					case CONSTANT_Multiname:
					case CONSTANT_MultinameA:
						var name:String = strings[readU32()]
						names[i] = new Multiname_(nssets[readU32()], name)
						break;
					
					case CONSTANT_MultinameL:
					case CONSTANT_MultinameLA:
						names[i] = new Multiname_(nssets[readU32()], null)
						break;
					
					case CONSTANT_TypeName:
						var mname:Multiname_ = names[readU32()];
						count = readU32();
						var types:Array = [];
						for( var t:int=0; t < count; ++t )
							types.push(names[readU32()]);
						names[i] = new TypeName(mname, types);
						break;
					
					default:
						throw new Error("invalid kind " + data[data.position-1])
				}
			
			//infoPrint("Cpool names count "+ n +" size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+" %")
			start = data.position
			
			namespaces[0] = publicNs
			strings[0] = "*"
		}
		
		private function parseMethodInfos():void
		{
			var start:int = data.position
			names[0] = new QName_(publicNs,"*")
			var method_count:int = readU32()
			methods = []
			for (var i:int=0; i < method_count; i++)
			{
				var m:MethodInfo = methods[i] = new MethodInfo()
				m.method_id = i
				var param_count:int = readU32()
				m.type = names[readU32()]
				m.paramTypes = []
				for (var j:int=0; j < param_count; j++)
					m.paramTypes[j] = names[readU32()]
				m.debugName = strings[readU32()]
				m.flags = data.readByte()
				if (m.flags & HAS_OPTIONAL)
				{
					// has_optional
					var optional_count:int = readU32();
					m.optionalValues = []
					for( var k:int = param_count-optional_count; k < param_count; ++k)
					{
						var index:int = readU32()    // optional value index
						var kind:int = data.readByte() // kind byte for each default value
						if (index == 0)
						{
							// kind is ignored, default value is based on type
							m.optionalValues[k] = undefined
						}
						else
						{
							if (!defaults[kind])
								log("ERROR kind="+kind+" method_id " + i)
							else
								m.optionalValues[k] = defaults[kind][index]
						}
					}
				}
				m.paramNames = [];
				if (m.flags & HAS_ParamNames)
				{
					// has_paramnames
					for( k = 0; k < param_count; ++k)
					{
						var strId:uint = readU32();
						m.paramNames[k] = strings[strId];
					}
				}
				else
				{
					for( k = 0; k < param_count; ++k)
						m.paramNames[k] = 'arg'+k;
				}
			}
			//infoPrint("MethodInfo count " +method_count+ " size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+" %")
		}
		
		private function parseMetadataInfos():void
		{
			var count:int = readU32()
			metadata = []
			for (var i:int=0; i < count; i++)
			{
				// MetadataInfo
				var m:MetaData = metadata[i] = new MetaData()
				m.name = strings[readU32()];
				var values_count:int = readU32();
				var names:Array = []
				for(var q:int = 0; q < values_count; ++q)
					names[q] = strings[readU32()] // name
				for(q = 0; q < values_count; ++q)
					m[names[q]] = strings[readU32()] // value
			}
		}
		
		private function parseInstanceInfos():void
		{
			var start:int = data.position
			var count:int = readU32()
			instances = []
			for (var i:int=0; i < count; i++)
			{
				var t:Traits = instances[i] = new Traits()
				t.name = names[readU32()]
				t.base = names[readU32()]
				t.flags = data.readByte()
				if (t.flags & 8)
					t.protectedNs = String(namespaces[readU32()]);
				var interface_count:int = readU32()
				for (var j:int=0; j < interface_count; j++)
					t.interfaces[j] = names[readU32()]
				var m:* = t.init = methods[readU32()]
				m.name = t.name
				m.kind = TRAIT_Method
				m.id = -1
				parseTraits(t)
			}
			//infoPrint("InstanceInfo count " + count + " size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+" %")
		}
		
		private function parseTraits(t:Traits):void
		{
			var namecount:int = readU32()
			for (var i:int=0; i < namecount; i++)
			{
				var name:* = names[readU32()]
				var tag:int = data.readByte()
				var kind:int = tag & 0xf
				var member:*
				switch(kind) {
					case TRAIT_Slot:
					case TRAIT_Const:
					case TRAIT_Class:
						var slot:SlotInfo = member = new SlotInfo()
						slot.id = readU32()
						//t.slots[slot.id] = slot
						if (kind==TRAIT_Slot || kind==TRAIT_Const)
						{
							slot.type = names[readU32()]
							var index:int=readU32()
							if (index)
								slot.value = defaults[data.readByte()][index]
						}
						else // (kind == TRAIT_Class)
						{
							slot.value = classes[readU32()]
						}
						break;
					case TRAIT_Method:
					case TRAIT_Getter:
					case TRAIT_Setter:
						var disp_id:int = readU32()
						var method:MethodInfo = member = methods[readU32()]
						//t.methods[disp_id] = method
						method.id = disp_id
						//log(traitKinds[kind]+' '+name+' '+ method)//+"// disp_id" + disp_id)
						break;
				}
				if (!member)
					log("error trait kind "+kind)
				member.kind = kind
				member.name = name
				//t.names[String(name)] = member
				t.members[i] = member
				
				if ( (tag >> 4) & ATTR_metadata ) {
					member.metadata = []
					for(var j:int=0, mdCount:int=readU32(); j < mdCount; ++j)
						member.metadata[j] = metadata[readU32()]
				}
			}
		}
		
		private function parseClassInfos():void
		{
			var start:int = data.position
			var count:int = instances.length
			classes = []
			for (var i:int=0; i < count; i++)
			{
				var t:Traits = classes[i] = new Traits()
				t.init = methods[readU32()]
				t.base = new Multiname_(null, 'Class');
				t.itraits = instances[i]
				//not used, should delete?
				t.name = new Multiname_(null, t.itraits.name + "$");
				//t.init.name = t.itraits.name + "$cinit"
				//t.init.kind = TRAIT_Method
				parseTraits(t)
			}
			//infoPrint("ClassInfo count " + count + " size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+"%")
		}
		
		private function parseScriptInfos():void
		{
			var start:int = data.position
			var count:int = readU32()
			scripts = []
			for (var i:int=0; i < count; i++)
			{
				var t:Traits = new Traits()
				scripts[i] = t
				//not used, should delete?
				t.name = new Multiname_(null, "script" + i)
				readU32()//skip script init
				/*t.base = names[0] // Object
				t.init = methods[readU32()]
				t.init.name = t.name + "$init"
				t.init.kind = TRAIT_Method*/
				parseTraits(t)
			}
			//infoPrint("ScriptInfo size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+" %")
		}
		
		private function parseMethodBodies():void
		{
			var start:int = data.position
			var count:int = readU32()
			for (var i:int=0; i < count; i++)
			{
				var m:MethodInfo = methods[readU32()]
				m.max_stack = readU32()
				m.local_count = readU32()
				var initScopeDepth:int = readU32()
				var maxScopeDepth:int = readU32()
				m.max_scope = maxScopeDepth - initScopeDepth
				var code_length:int = readU32()
				/*m.code = new ByteArray()
				m.code.endian = "littleEndian"
				if (code_length > 0)
				data.readBytes(m.code, 0, code_length)*/
				if (code_length > 0)
					data.position += code_length;
				//data.readBytes(new ByteArray, 0, code_length)
				
				var ex_count:int = readU32()
				for (var j:int = 0; j < ex_count; j++)
				{
					var from:int = readU32()
					var to:int = readU32()
					var target:int = readU32()
					var type:Multiname_ = names[readU32()]
					//print("magic " + magic.toString(16))
					//if (magic >= (46<<16|16))
					var name:Multiname_ = names[readU32()];
				}
				parseTraits(m.activation = new Traits)
			}
			//infoPrint("MethodBodies count " + count + " size "+(data.position-start)+" "+int(100*(data.position-start)/data.length)+" %")
		}
		
		public function dump():void
		{
			for each (var t:Traits in scripts)
			{
				log("// scriptname: " + t.name)
				t.dump(this, '', typeDB)
				//log('//init');
				//t.init.dump(this)
			}
			/*log('//methods');
			for each (var m:* in methods)
			{
			if (!m.dumped)
			m.dump(this)
			}*/
			
			//infoPrint("OPCODE\tSIZE\t% OF "+totalSize)
			/*var done:Array = []
			for (;;)
			{
			var max:int = -1;
			var maxsize:int = 0;
			for (var i:int=0; i < 256; i++)
			{
			if (opSizes[i] > maxsize && !done[i])
			{
			max = i;
			maxsize = opSizes[i];
			}
			}
			if (max == -1)
			break;
			done[max] = 1;
			//infoPrint(opNames[max]+"\t"+int(opSizes[max])+"\t"+int(100*opSizes[max]/totalSize)+"%")
			}*/
		}
	}
}
