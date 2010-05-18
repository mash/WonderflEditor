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
	//import com.victordramba.console.debug;
	
	import ro.victordramba.util.HashMap;
	

	internal class Resolver
	{
		private var typeDB:TypeDB;
		private var tokenizer:Tokenizer;
		
		
		public function Resolver(tokenizer:Tokenizer)
		{
			this.tokenizer = tokenizer;
			this.typeDB = TypeDB.inst;
		}
		
		/**
		 * this only checks if the name is in the scope at pos, it will not look in the imports
		 */		
		public function isInScope(name:String, pos:int):Boolean
		{
			//find the scope
			var t:Token = tokenizer.tokenByPos(pos);
			if (!t) return false;
			
			// is it in our scope?
			return resolveName(name, t.scope) != null;
		}
		
		public function getMissingImports(name:String, pos:int):Vector.<String>
		{
			//find the scope
			var t:Token = tokenizer.tokenByPos(pos);
			if (!t) return null;
			var imports:HashMap = findImports(t);
			
			//trace("getMissingImports", name);
			
			var found:Boolean = false;
			var missing:Vector.<String> = typeDB.listImportsFor(name)
			if (!imports) return missing;
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
			
			if (!found) return missing;
			return null;
		}
		
		public function getAllOptions(pos:int):Vector.<String>
		{
			//debug('get all options');
			var lst:Vector.<Field> = typeDB.listAll();
			var a:Vector.<String> = new Vector.<String>;
			for each (var f:Field in lst)
				a.push(f.name);

			//find the scope
			var t:Token = tokenizer.tokenByPos(pos);
			if (!t) return a;			
			
			var hash:HashMap = new HashMap;
			
			findScopeClass(t.scope);
			
			for (var scope:Field = t.scope; scope.parent; scope = scope.parent)
				hash.merge(listMembers(scope, true));
			
			for each(var name:String in hash.getKeys())
				a.push(name);
				
			a.sort(Array.CASEINSENSITIVE);
				
			return a;
		}

		public function getAllTypes():Vector.<String>
		{
			var lst:Vector.<Field> = typeDB.listAllTypes();
			var a:Vector.<String> = new Vector.<String>;
			for each (var f:Field in lst)
				a.push(f.name);
				
			a.sort(Array.CASEINSENSITIVE);
			return a;
		}
		
		public function getFunctionDetails(text:String, pos:int):String
		{
			var field:Field = resolve(text, pos, true);
			
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
			//trace("getMemberList:", text.substr(pos, 3));
			
			var field:Field = resolve(text, pos, false);
			if (!field) return null;
			
			
			//convert member list in string list
			var a:Vector.<String> = new Vector.<String>;
			//trace(field, listMembers(field).toArray().length);
			for each (var m:Field in listMembers(field).toArray()) {
				a.push(m.name);
			}
			a.sort(Array.CASEINSENSITIVE);
			return a;
		}
		
		//find the imports for this token
		private function findImports(token:Token):HashMap
		{
			do {
				token = token.parent;
			} while (token.parent && !token.imports);
			return token.imports;			
		}
		
		private var tokenScopeClass:Field;
		
		private function resolve(text:String, pos:int, isFnDetails:Boolean):Field
		{
			var t0:Token = tokenizer.tokenByPos(pos);
			if (t0.type == Token.COMMENT)
				return null;			
			
			var bp:BackwardsParser = new BackwardsParser;
			if (!bp.parse(text, pos)) return null;
			
			//trace('bp names: '+bp.names);
			
			//find the scope
			var t:Token = tokenizer.tokenByPos(bp.startPos);
			if (!t) return null;
			
			var i:int = 0;
			var name:String = bp.names[i];
			var itemType:String = bp.types[i];
			
			//trace(name, itemType);
			
			var imports:HashMap = findImports(t);
			
			// is it in our scope?
			var field:Field = resolveName(name, t.scope, !isFnDetails);
			//trace("resolveName: ", field);
			
			//or is it an imported thing?
			if (!field && imports)
			{
				field = typeDB.resolveName(new Multiname(name, imports));
				//trace("not imported", field);
				// a class called as function means call constructor
				// but only if it's last item
				if (isFnDetails && field && field.fieldType=='class' && bp.names.length==1) 
					field = field.members.getValue(field.name);
			}
				
			//we didn't find it
			if (!field) {
				//trace("return null");
				return null;
			}
			
			if (itemType == BackwardsParser.EXPR)
				field = newInstance(field, field);
			else checkIsReturn();
			
			//trace("before hash map");
			
			var aM:HashMap;
			do {
				i++;
				if (i > bp.names.length-1) break;
				aM = listMembers(field, false, !isFnDetails);
				field = aM.getValue(bp.names[i]);
				
				//trace("230:", field);
				
				checkIsReturn();
			}
			while (field);
			return field;
			
			function checkIsReturn():void
			{
				// not is last and we need function details
				if (field && !(i==bp.names.length-1 && isFnDetails))
				{
					// we don't have function exec syntax
					if (field.fieldType=='function' && bp.types[i]!=BackwardsParser.FUNCTION)
						field = newInstance(t.scope, typeDB.resolveName(new Multiname('Function')));
					else if (field.fieldType=='class' && bp.types[i]==BackwardsParser.FUNCTION)
						field = newInstance(field, field);
				}
			}
		}
		
		private function newInstance(scope:Field, type:Field):Field
		{
			//construct an "instance"
			var fld:Field = new Field('var');
			fld.type = new Multiname();
			fld.parent = scope;
			fld.type.resolved = type;
			return fld;
		}
		
		private function findScopeClass(scope:Field):void
		{
			//can we find a better way to set the scope?
			//we set the scope to be able to deal with private/protected, etc access
			for (tokenScopeClass = scope; tokenScopeClass.fieldType!='class' && tokenScopeClass.parent; tokenScopeClass=tokenScopeClass.parent);
			if (tokenScopeClass.fieldType != 'class') tokenScopeClass = null;
		}
		
		/**
		 * Recursevly resolve a name in a given scope
		 */
		private function resolveName(name:String, scope:Field, skipConstructor:Boolean=true):Field
		{
			var f:Field;
			var ret:Field;
			
			findScopeClass(scope);

			//decide if it's a static scope			
			var isStatic:Boolean = scope.fieldType == 'class';
			for (f=scope; !isStatic && f.parent; f = f.parent)
				if (f.isStatic)
				{
					isStatic = true;
					break;
				}
				
			if (name == 'this')
			{
				if (isStatic) return null;
				for (; scope.parent; scope = scope.parent)
				{
					if (scope.fieldType == 'class')
						return newInstance(scope, scope);
				}
				return null;
			}
			
			
			for (; scope.parent; scope = scope.parent)
			{
				ret = scope.params.getValue(name);
				if (ret) return ret;
				
				var noPrivate:Boolean = false;
				
				for (f=scope; f; f=typeDB.resolveName(f.extendz))
				{
					ret = f.members.getValue(name);
					if (
						ret &&
						//skip non-static members in static scope, accept local vars
						(!isStatic || ret.isStatic || (f.fieldType=='function' && !noPrivate)) &&
						//skip private members
						(!noPrivate || ret.access != 'private')
						)
					{
						//skip constructor
						//in a class scope, ClassName should be the class, not the constructor member
						if (skipConstructor && ret && f.fieldType=='class' && ret.name==f.name) return f;
						if (ret) return ret;
					}
					noPrivate = true;
				}
			}
			return null;
		}

		/**
		 * resolve the list of members considering inheritance
		 */
		private function listMembers(f:Field, isScope:Boolean=false, skipConstructor:Boolean=true):HashMap/*of Field*/
		{
			//trace('!listMembers '+f);
			var a:HashMap = new HashMap;
			if (!f) return a;
			var m:Field;
			
			if (!isScope && f.fieldType == 'class')
			{
				//trace('static members');
				for each (m in f.members.toArray())
					if (m.isStatic && m.access!='private')
						a.setValue(m.name, m);
				return a;
			}
			
			if (!isScope) f = typeDB.resolveName(f.type);
			//if (!isScope) trace('get instance type');
			//trace('we are in: '+tokenScopeClass);
			var protectedOk:Boolean = false;
			for (; f; f = typeDB.resolveName(f.extendz))
			{
				if (tokenScopeClass && tokenScopeClass.name == f.name)
					protectedOk = true;
				for each (m in f.members.toArray())
				{
					if ((!isScope && m.isStatic)) continue;
					if (skipConstructor && m.name==f.name && f.fieldType=='class') continue;
					if ((m.access=='private') && (tokenScopeClass==null || tokenScopeClass.name!=f.name)) continue;
					if (m.access=='protected' && !protectedOk) continue;
					a.setValue(m.name, m);
				}
			}
			return a;
		}
	}
}