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

/*
 * @Author Dramba Victor
 * 2009
 * 
 * You may use this code any way you like, but please keep this notice in
 * The code is provided "as is" without warranty of any kind.
 *
 * Based on J2AS3 http://code.google.com/p/j2as3/
 */

package ro.minibuilder.asparser
{
	
	import com.victordramba.console.debug;
	
	import ro.victordramba.util.HashMap;


	internal class Tokenizer
	{
		public var tree:Token;

		private var string:String;
		private var pos:uint;
		
		private static const keywordsA:Array = [
			'as', 'is', 'in', 'break', 'case', 'continue', 'default', 'do', 'while', 'else', 'for', 'in', 'each',
			'if', 'label', 'return', 'super', 'switch', 'throw', 'try', 'catch', 'finally', 'while',
			'with', 'dynamic', 'final', 'internal', 'native', 'override', 'private', 'protected',
			'public', 'static', 'extends', 'implements', 'new',
			'interface', 'namespace', 'default xml namespace', 'import',
			'include', 'use', 'delete', 'use namespace', 'false', 'null', 'this', 'true', 'undefined'];

		private static const keywords2A:Array = [
			'const', 'package', 'var', 'function', 'get', 'set', 'class'];
			
		private static const symbolsA:Array = [
			'+', '--', '/', '\\', '++', '%', '*', '-', '+=', '/=', '%=', '*=', '-=', '=', '&', '<<',
			'~', '|', '>>', '>>>', '^', '&=', '<<=', '|=', '>>=', '>>>=', '^=', '==', '>',
			'>=', '!=', /*'<', special, can start an E4X*/ '<=', '===', '!==', '&&', '&&=', '!', '||', '||=', '[', ']',
			'as', ',', '?', '.', 'instanceof', '::', 'new', '{', '}',
			'(', ')', 'typeof', ';', ':', '...', '..', '#', '`'/*just to unlock*/];

		private static const keywords:HashMap = new HashMap;
		private static const keywords2:HashMap = new HashMap;
		private static const symbols:HashMap = new HashMap;
		private static const symbolsLengths:Array = [];

		//static class init
		private static var init:Boolean = (function():Boolean
		{
			var s:String;
			for each (s in keywordsA)
				keywords.setValue(s, true);
			for each (s in keywords2A)
				keywords2.setValue(s, true);
			for each (s in symbolsA)
			{
				symbols.setValue(s, true);
				var len:uint = s.length;
				if (symbolsLengths.indexOf(len) == -1)
					symbolsLengths.push(len);
			}
			symbolsLengths.sort(Array.DESCENDING + Array.NUMERIC);
			//trace(symbolsLengths);

			return true;
		})();


		public function Tokenizer(str:String)
		{
			_typeDB = new TypeDB;
			
			this.string = str;
			pos = 0;
		}

		public function get precentReady():Number
		{
			return pos / string.length;
		}

		public function nextToken():Token
		{
			if (pos>=string.length)
			    return null;


			var c:String = string.charAt(pos);
			var start:uint = pos;
			var str:String;
			var lt:String;//previous token

			if (isWhitespace(c)) {
				skipWhitespace();
				c = currentChar();
				start = pos;
			}

			if (isNumber(c))
			{
				skipToStringEnd();
				str = string.substring(start, pos);
				return new Token(str, Token.NUMBER, pos);
			}

			if (c=="/")
			{
				if (nextChar()=="*")
				{
					skipUntil("*/");
					return new Token(string.substring(start,pos), Token.COMMENT, pos);
				}
				else if (nextChar()=="/")
				{
					skipUntil("\r");
					pos--;
					return new Token(string.substring(start,pos), Token.COMMENT, pos);
				}
				else
				{
					//look for regexp syntax
					lt = tokens[tokens.length-1].string;
					if (lt=='=' || lt==',' || lt=='[' || lt=='(' || lt=='}' || lt=='{' || lt==';' || lt=='&' || lt=='|')
					{
						skipUntilWithEscNL('/');
						while (isLetter(string.charAt(pos))) pos++;
						return new Token(string.substring(start,pos), Token.REGEXP, pos);
					}
				}
			}

			if (isLetter(c))
			{
				skipToStringEnd();
				str = string.substring(start, pos);
				var type:String;
				if (isKeyword(str))
				    type = Token.KEYWORD;
				else if (isKeyword2(str))
				    type = Token.KEYWORD2;
				else if (tokens.length && tokens[tokens.length-1].string == '[' && (str == 'Embed' || str=='Event' || str=='SWF' || str=='Bindable'))
					type = Token.KEYWORD;
				else
					type = Token.STRING_LITERAL;
				return new Token(str, type, pos);
			}
			else if ((str = isSymbol(pos)) != null)
			{
				pos += str.length;
				return new Token(str, Token.SYMBOL, pos);
			}
			//look for E4X
			else if (c == '<')
			{
				lt = tokens[tokens.length-1].string;
				if (lt=='=' || lt==',' || lt=='[' || lt=='(' || lt=='==' || lt=='!=')
				{
					do
					{
						skipUntil('>');
						str = string.substring(start,pos);
						try	{
							XML(str.replace(/[{}]/g,'"'));
							return new Token(str, Token.E4X, pos);
						} catch (e:Error) { };
					} while (pos < string.length);
					pos = start;
				}
				return new Token(c, Token.SYMBOL, ++pos);
			}
			else if (c=='"' || c=="'")
			{	// a string
				skipUntilWithEscNL(c);
				return new Token(string.substring(start, pos), Token.STRING, pos);
			}
			//unknown
			return new Token(c, Token.SYMBOL, ++pos);
		}

		private function currentChar():String
		{
			return string.charAt(pos);
		}

		private function nextChar():String
		{
			if (pos>=string.length-1)
			   return null;
			return string.charAt(pos+1);
		}

		private function skipUntil(exit:String):void
		{
			pos++;
			var p:int = string.indexOf(exit, pos);
			if (p == -1)
				pos = string.length;
			else
				pos = p + exit.length;
		}

        /** Patch from http://www.physicsdev.com/blog/?p=14#comments - thanks */
		/*private function skipUntilWithEsc(exit:String):void
		{
            pos++;
            var c:String;
            while ((c=string.charAt(pos)) != exit && c) {
                if (c == "\\") pos++;
                pos++;
            }
            if (c) pos++;
		}*/

		private function skipUntilWithEscNL(exit:String):void
		{
			//this is faster than regexp
            pos++;
            var c:String;
            while ((c=string.charAt(pos)) != exit && c!='\r' && c) {
                if (c == "\\") pos++;
                pos++;
            }
            if (c) pos++;
		}

		private function skipWhitespace():void {
			var c:String;
			c = currentChar();
			while (isWhitespace(c)) {
				pos++;
				c = currentChar();
			}
		}

		private function isWhitespace(str:String):Boolean {
			return str==" " || str=="\n" || str=="\t" || str=="\r";
		}

		private function skipToStringEnd():void
		{
			var c:String;
			while (true)
			{
				var dot:Boolean = c == '.';
				c = currentChar();
				if (!(isLetter(c) || isNumber(c) || c=="." || (dot && c=='*')))
					break;
				pos++;
			}
		}

		private function isNumber(str:String):Boolean
		{
			var code:uint = str.charCodeAt(0);
			return (code>=48 && code<=57);
		}

		static public function isLetter(str:String):Boolean
		{
			var code:uint = str.charCodeAt(0);
			if (code == 36 || code == 95) return true;
			if (code>=64 && code<=90) //@,A-Z
			    return true;
			if (code>=97 && code<=122)//a-z
			    return true;
			return false;
		}

		private function isKeyword(str:String):Boolean
		{
			return keywords.getValue(str);
		}

		private function isKeyword2(str:String):Boolean
		{
			return keywords2.getValue(str);
		}

		private function isSymbol(pos:uint):String
		{
			var len:uint = symbolsLengths.length;
			for (var i:int=0; i<len; i++)
			{
				var s:String = string.substr(pos, symbolsLengths[i]);
				if (symbols.getValue(s)) return s;
			}
			return null;
		}


		private function lengthSort(strA:String,strB:String):int {
			if (strA.length<strB.length)
			    return 1;
			if (strA.length>strB.length)
			    return -1;
			return 0;
		}

		internal var tokens:Array;
		private var crtBlock:Token;
		private var _scope:Field;
		private var field:Field;
		private var param:Field;
		private var defParamValue:String;
		private var paramsBlock:Boolean;
		private var imports:HashMap;
		private var scope:Field;
		private var isStatic:Boolean = false;
		private var access:String;
		
		internal var topScope:Field;
		private var _typeDB:TypeDB;

		internal function get typeDB():TypeDB
		{
			return _typeDB;
		}

		internal function runSlice():Boolean
		{
			//init (first run)
			if (!tokens)
			{
				tokens = [];
				tree = new Token('top', null, 0);
				tree.children = [];
				crtBlock = tree;

				//top scope
				topScope = scope = new Field('top', 0, 'top');
				//toplevel package
				scope.members.setValue('', new Field('package', 0, ''));

				pos = 0;
				defParamValue = null;
				paramsBlock = false;
				
				imports = new HashMap;
			}

			var t:Token = nextToken();
			if (!t)
				return false;

			tokens.push(t);
			t.parent = crtBlock;
			crtBlock.children.push(t);
			if (t.string=='{'/* || t.string=='[' || t.string=='('*/)
			{
				crtBlock = t;
				t.children = [];
			}
			if (t.string=='}' && crtBlock.parent/* || t.string==']' || t.string==')'*/)
			{
				crtBlock = crtBlock.parent;
			}

			t.scope = scope;

			var tl:uint = tokens.length-1;
			var tp:Token = tokens[tl-1];
			var tp2:Token = tokens[tl-2];
			var tp3:Token = tokens[tl-3];

			if (t.string == 'package')
				imports = new HashMap;

			//toplevel package
			if (t.string=='{' && tp.string == 'package')
			{
				_scope = scope.members.getValue('');
				//imports.setItem('.*');
			}
			else if (tp && tp.string == 'import')
			{
				imports.setValue(t.string, t.string);
			}
			else if (tp && tp.string == 'extends')
			{
				field.extendz = new Multiname(t.string, imports);
			}
			else if (t.string=='private' || t.string=='protected' || t.string=='public' || t.string=='internal')
			{
				access = t.string;
			}
			else if (t.string == 'static')
			{
				isStatic = true;
			}
			else if (t.string == 'get' || t.string=='set')
			{
				//do nothing
			}
			else if (tp && (tp.string=='package' || tp.string=='class' || tp.string=='interface' ||
				tp.string=='function' || tp.string=='catch' || tp.string == 'get' || tp.string == 'set' || 
				tp.string=='var' || tp.string=='const'))
			{
				//for package, merge classes in the existing omonimus package
				if (tp.string=='package' && scope.members.hasKey(t.string))
					_scope = scope.members.getValue(t.string);
				else
				{
					//debug('field-'+tp.string);
					//TODO if is "set" make it "*set"
					field = new Field(tp.string, t.pos, t.string);
					if (t.string != '(')//anonimus functions are not members
						scope.members.setValue(t.string, field);
					if (tp.string!='var' && tp.string!='const')
						_scope = field;
						
					if (isStatic)//consume "static" declaration
					{
						field.isStatic = true;
						isStatic = false;
					}
					if (access)//consume access specifier
					{
						field.access = access;
						access = null;
						
					}
					//all interface methods are public
					if (scope.fieldType == 'interface')
						field.access = 'public';
					//this is so members will have the parent set to the scope
					field.parent = scope;
				}
				if (_scope && (tp.string=='class' || tp.string=='interface' || scope.fieldType=='package'))
				{
					_scope.type = new Multiname('Class');
					try {
						_typeDB.addDefinition(scope.name, field);
					}
					// failproof for syntax errors
					catch(e:Error)
					{
						debug(e.message + ' ' + tl+','+t+','+tp+','+tp2+','+tp3);
					}
				}
				//add current package to imports
				if (tp.string == 'package')
					imports.setValue(t.string+'.*', t.string+'.*');
			}

			if (t.string == ';')
			{
				field = null;
				_scope = null;
				isStatic = false;
			}

			//parse function params
			else if (_scope && (_scope.fieldType=='function' || _scope.fieldType=='catch' || _scope.fieldType == 'set'))
			{
				if (tp && tp.string=='(' && t.string != ')')
					paramsBlock = true;

				if (paramsBlock)
				{
					if (!param && t.string != '...')
					{
						param = new Field('var', pos, t.string);
						t.scope = _scope;
						_scope.params.setValue(param.name, param);
						if (tp.string == '...')
						{
							_scope.hasRestParams = true;
							param.type = new Multiname('Array');
						}
					}
					else if (tp.string == ':')
					{
						if (_scope.fieldType == 'set')
						{
							_scope.type = new Multiname(t.string, imports);
						}
						else
							param.type = new Multiname(t.string, imports);
					}

					else if (t.string == '=')
						defParamValue = '';

					else if (t.string == ',' || t.string == ')')
					{
						if (t.string == ')')
						{
							paramsBlock = false;
						}
						if (defParamValue)
						{
							param.defaultValue = defParamValue;
							defParamValue = null;
						}
						param = null;
					}
					else if (defParamValue != null)
						defParamValue += t.string;
				}
			}


			if (field && tp3 && tp.string == ':')
			{
				if (tp3.string=='var' || tp3.string=='const' || tp2.string == ')')
				{
					if (field.fieldType != 'set')
					{
						field.type = new Multiname(t.string, imports);
					}
					field = null;
				}
			}


			if (t.string == '{' && _scope)
			{
				crtBlock.imports = imports;
				_scope.pos = t.pos;
				_scope.parent = scope;
				scope = _scope;
				t.scope = scope;
				//info += pos + ')' + scope.parent.name + '->' + scope.name+'\n';
				_scope = null;
			}

			else if (t.string == '}' && t.parent.pos == scope.pos)
			{
				//info += scope.parent.name + '<-' + scope.name+'\n';
				scope = scope.parent;
				
				//force a ; to close the scope here. needs further testing
				var sepT:Token = new Token(';', Token.SYMBOL, t.pos+1);
				sepT.scope = scope;
				sepT.parent = t.parent;
				tokens.push(sepT);
			}

			return true;
		}

		internal function kill():void
		{
			tokens = null;
		}

		public function tokenByPos(pos:uint):Token
		{
			if (!tokens || tokens.length<3) return null;
			//TODO: binary search
			for (var i:int=tokens.length-1; i>=0; i--)
				if (tokens[i] && pos > tokens[i].pos)
					return Token.map[tokens[i].id];
			return null;
		}
	}
}