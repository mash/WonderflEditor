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


Author: Victor Dramba
2009
*/

package ro.minibuilder.asparser
{
	import __AS3__.vec.Vector;
	import com.victordramba.console.debug;
	
	import ro.victordramba.util.HashMap;
	

	internal class Resolver
	{
		private var typeDB:TypeDB;
		private var tokenizer:Tokenizer;

		private var tokenScopeClass:Field;
		
		public function Resolver(tokenizer:Tokenizer)
		{
			this.tokenizer = tokenizer;
			this.typeDB = TypeDB.inst;
		}
		
		/**
		 * this only checks if the name is in the scope at pos, it will not look in the imports
		 * we use it to add an import only if it's not shadowed by a local name
		 */		
		public function isInScope(name:String, pos:int):Boolean
		{
			//find the scope
			var t:Token = tokenizer.tokenByPos(pos);
			if (!t) return false;
			
			//check in function scope chain
			//also, find if we are in static scope
			var isStatic:Boolean = false;
			var scope:Field;
			var f:Field;
			for (scope = t.scope; scope && 
				scope.fieldType=='function' || scope.fieldType=='get' || scope.fieldType=='set';
				scope = scope.parent) 
			{
				if (scope.members.hasKey(name) || scope.params.hasKey(name)) return true;
				if (scope.isStatic) isStatic = true;
			}
			
			//compute tokenScopeClass
			findScopeClass(t.scope);
			
			//class scope
			if (tokenScopeClass)
			{
				//for static scope, add only static members
				//current class
				for each(f in tokenScopeClass.members.toArray())
					if ((!isStatic || f.isStatic) && f.name==name) return true;
			
				//inheritance
				scope=tokenScopeClass;
				while ((scope = typeDB.resolveName(scope.extendz)))
					for each(f in scope.members.toArray())
						if (f.access!='private' && (!isStatic || f.isStatic) && f.name==name) return true;
			}
			
			
			return false;
		}
		
		public function getMissingImports(name:String, pos:int):Vector.<String>
		{
			debug('get missing imports');
			
			//find the scope
			var t:Token = tokenizer.tokenByPos(pos);
			if (!t) return null;
			var imports:HashMap = findImports(t);
			
			var found:Boolean = false;
			var missing:Vector.<String> = typeDB.listImportsFor(name)
			loop1: for each (var pack:String in missing)
			{
				for each (var line:String in imports.toArray())
				{
					var i:int = line.lastIndexOf('.');
					var n:String = line.substr(i+1);
					if (line.substr(0, i) == pack && (n=='*' || n==name))
					{
						found = true;
						break loop1;
					}
				}
			}
			
			debug(missing.join('\n'));
			
			if (!found) return missing;
			return null;
		}
		
		public function getAllOptions(pos:int):Vector.<String>
		{
			debug('get all options');
			var f:Field;
			
			var a:Vector.<String> = new Vector.<String>;
			a.push('function ');
			//all package level items
			for each (f in typeDB.listAll())
				a.push(f.name);

			//find the scope
			var t:Token = tokenizer.tokenByPos(pos);
			if (!t) return a;
			
			if (t.scope.fieldType == 'class')
			{
				a.push('private function ');
				a.push('protected function ');
				a.push('public function ');
				a.push('private var ');
				a.push('protected var ');
				a.push('public var ');
				a.push('static ');
			}
			
			var hash:HashMap = new HashMap;
			var scope:Field;
			
			function addKeys(map:HashMap):void
			{
				for each (var name:String in map.getKeys())
					a.push(name);
			}
						
			//find items in function scope chain
			//also, find if we are in static scope
			var isStatic:Boolean = false;
			for (scope = t.scope; scope && 
				scope.fieldType=='function' || scope.fieldType=='get' || scope.fieldType=='set';
				scope = scope.parent) 
			{
				addKeys(scope.members);
				addKeys(scope.params);
				if (scope.isStatic) isStatic = true;
			}
			
			//compute tokenScopeClass
			findScopeClass(t.scope);
			
			//class scope
			if (tokenScopeClass)
			{
				//for static scope, add only static members
				//current class
				for each(f in tokenScopeClass.members.toArray())
					if (!isStatic || f.isStatic) a.push(f.name);
			
				//inheritance
				scope=tokenScopeClass;
				while ((scope = typeDB.resolveName(scope.extendz)))
					for each(f in scope.members.toArray())
						if (f.access!='private' && (!isStatic || f.isStatic)) a.push(f.name);
			}
			return a;
		}
		

		public function getAllTypes(isFunction:Boolean=true):Vector.<String>
		{
			var lst:Vector.<Field> = typeDB.listAllTypes();
			var a:Vector.<String> = new Vector.<String>;
			for each (var f:Field in lst)
				a.push(f.name);
				
			if (isFunction) a.push('void');
				
			a.sort(Array.CASEINSENSITIVE);
			return a;
		}
		
		public function getFunctionDetails(text:String, pos:int):String
		{
			resolve(text, pos);
			var field:Field = resolvedRef;
			
			//debug(field);
			
			//we didn't find it
			if (!field || field.fieldType!='function') return null;
			
			
			var a:Vector.<String> = new Vector.<String>;
			var par:Field;
			for each (par in field.params.toArray())
			{
				var str:String = par.name;
				if (par.type) str += ':'+par.type.type;
				if (par.defaultValue) str += '='+par.defaultValue;
				a.push(str);
			}
			//rest
			if (field.hasRestParams)
				a[a.length-1] = '...'+par.name;
			
			return 'function ' + field.name + '(' + a.join(', ') + ')'+(field.type ? ':'+field.type.type : ''); 
		}
		
		/**
		 * called when you enter a dot
		 */
		public function getMemberList(text:String, pos:int):Vector.<String>
		{
			resolve(text, pos);
			if (!resolved) return null;
			
			//convert member list in string list
			var a:Vector.<String> = new Vector.<String>;
			
			for each (var m:Field in listMembers(resolved, resolvedIsClass).toArray())
				a.push(m.name);
			a.sort(Array.CASEINSENSITIVE);
			return a;
		}
		
		private function listMembers(type:Field, statics:Boolean):HashMap
		{
			return statics ? listStaticMembers(type) : listTypeMembers(type);
		}
		
		private function listStaticMembers(type:Field):HashMap
		{
			var map:HashMap = new HashMap;
			for each (var m:Field in type.members.toArray())
				if (m.isStatic && (m.access=='public' || tokenScopeClass==type))
					map.setValue(m.name, m);
			return map;
		}
		
		
		private function listTypeMembers(type:Field, skipConstructor:Boolean=true):HashMap
		{
			if (type.fieldType != 'class' && type.fieldType != 'interface') 
				throw new Error('type has to be class');
			
			var map:HashMap = new HashMap;
			
			
			var protectedOK:Boolean = false;
			
			for (; type; type = typeDB.resolveName(type.extendz))
			{
				if (tokenScopeClass == type)
				{
					protectedOK = true;
					map.merge(type.members);
					continue;
				}
			
				for each (var m:Field in type.members.toArray())
				{
					if (m.isStatic) continue;
					var constrCond:Boolean = (m.name == type.name) && skipConstructor;
					if ((m.access=='public' || (protectedOK && m.access=='protected')) && !constrCond) 
						map.setValue(m.name, m);
				}
			}
				
			return map;
		}
		
		
		public function findDefinition(text:String, pos:int):Field
		{
			//adjust position to next word boundary
			var re:RegExp = /\b/g;
			re.lastIndex = pos;
			pos = re.exec(text).index;
			resolve(text, pos);
			return resolvedRef;
		}
		
		//find the imports for this token
		private function findImports(token:Token):HashMap
		{
			do {
				token = token.parent;
			} while (token.parent && !token.imports);
			return token.imports;			
		}
		
		
		private var resolved:Field;
		private var resolvedIsClass:Boolean;
		private var resolvedRef:Field;
		
		private function resolve(text:String, pos:int):void
		{
			resolved = null;
			resolvedRef = null;
			resolvedIsClass = false;
			
			var t0:Token = tokenizer.tokenByPos(pos);
			if (t0.type == Token.COMMENT)
				return;			
			
			var bp:BackwardsParser = new BackwardsParser;
			if (!bp.parse(text, pos)) return;
			
			//debug('bp names: '+bp.names);
			
			//find the scope
			var t:Token = tokenizer.tokenByPos(bp.startPos);
			if (!t) return;
			
			var i:int = 0;
			var name:String = bp.names[0];
			var itemType:String = bp.types[0];
			
			var imports:HashMap = findImports(t);
			
			findScopeClass(t.scope);
			
			//1. is it in function scope chain?
			var isStatic:Boolean = false;
			for (scope = t.scope; scope && 
				scope.fieldType=='function' || scope.fieldType=='get' || scope.fieldType=='set';
				scope = scope.parent) 
			{
				if (scope.isStatic) isStatic = true;
				if (scope.members.hasKey(name))
				{
					resolved = scope.members.getValue(name);
					break;
				}
				if (scope.params.hasKey(name))
				{
					resolved = scope.params.getValue(name);
					break;
				}
			}
			
			var scope:Field;
			
			//2. is it this or super?
			if (!resolved)
			{
				//non-static instance context
				var cond:Boolean = t.scope.parent && t.scope.parent.fieldType=='class' && !isStatic;
				if (name == 'this' && cond)
					resolved = t.scope.parent;
				if (name == 'super' && cond)
					resolved = typeDB.resolveName(t.scope.parent.extendz);
			}
			
			
			//3. or is it in the class/inheritance scope?
			for (scope=tokenScopeClass; !resolved && scope; scope=typeDB.resolveName(scope.extendz))
			{
				var m:Field = scope.members.getValue(name);
				if (!m) continue;
				
				if (scope != tokenScopeClass && m.access=='private')
					continue;
					
				//skip constructors in inheritance chain
				if (m.name == scope.name) continue;
				
				if (!isStatic || m.isStatic)
					resolved = m;
			}

			//4. last, is it an imported thing?
			if (!resolved && imports)
			{
				resolved = typeDB.resolveName(new Multiname(name, imports));
				if (resolved && resolved.fieldType == 'class' && itemType == BackwardsParser.NAME)
					resolvedIsClass = true;
			}
			
			//we didn't find the first name, we quit
			if (!resolved) return;
			checkReturnType();
			
			
			var aM:HashMap;
			do {
				i++;
				if (i > bp.names.length-1) break;
				aM = listMembers(resolved, resolvedIsClass);
				resolved = aM.getValue(bp.names[i]);
				resolvedIsClass = false;
				itemType = bp.types[i];
				if (!resolved) return;
				checkReturnType();
			}
			while (resolved);
			
			//check return type or var type
			function checkReturnType():void
			{
				//for function signature
				resolvedRef = resolved;
				if (resolved.fieldType == 'class' && resolvedIsClass)//return the constructor
				{
					var m:Field = resolved.members.getValue(resolved.name);
					if (m) resolvedRef = m;
				}
				
				
				if (resolved.fieldType=='var' || resolved.fieldType=='get' || resolved.fieldType=='set' ||
					(itemType == BackwardsParser.FUNCTION && resolved.fieldType == 'function'))
				{
					resolved = typeDB.resolveName(resolved.type);
				}
				else if (resolved.fieldType == 'function' && itemType != BackwardsParser.FUNCTION)
				{
					resolved = typeDB.resolveName(new Multiname('Function'));
				}
			}
		}
		
		private function findScopeClass(scope:Field):void
		{
			//can we find a better way to set the scope?
			//we set the scope to be able to deal with private/protected, etc access
			for (tokenScopeClass = scope; tokenScopeClass.fieldType!='class' && tokenScopeClass.parent; tokenScopeClass=tokenScopeClass.parent);
			if (tokenScopeClass.fieldType != 'class') tokenScopeClass = null;
		}
	}
}