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

	public class BackwardsParser
	{
		public static const EXPR:String = 'expr';
		public static const FUNCTION:String = 'function';
		public static const NAME:String = 'name';
		
		
		public var startPos:int;
		public var names:Vector.<String> = new Vector.<String>;
		public var types:Vector.<String> = new Vector.<String>;
		
		private var text:String;
		
		
		public function parse(string:String, pos:int):Boolean
		{
			text = string;
			
			startPos = pos;
			return _parse(false);
		}
		
		private function _parse(isFunction:Boolean):Boolean
		{
			var pos:int = startPos;
			
			var c:String = text.charAt(pos-1);
			
			// reverse a fragment
			var tmp:String = text.substring(Math.max(0, pos-1000), pos).split('').reverse().join('');
			var m:Array
			
			//check for regexp literal
			if (tmp.match(/^[gimsx]{0,5}\/[^\/\r]+\/\s*[=,(\;\[\}\{]/))
			{
				addItem('RegExp', EXPR);
				return true;
			}			
			//check for simple name or functionName
			if ((m = tmp.match(/^\w*[A-Za-z_$]\b/)))
			{
				addItem(m[0].split('').reverse().join(''), isFunction ? FUNCTION : NAME);
				startPos -= m[0].length;
			}
			// check for "... as ClassName)."
			else if ((m = tmp.match(/^\)(\w+)\s+sa\s.*?\(/)))
			{
				addItem(m[1].split('').reverse().join(''), EXPR);
				startPos -= m[0].length;
				//for expressions, end recursion here
				return true;
			}
			//string literal
			else if (c == '"' || c == "'")
			{
				addItem('String', EXPR);
				return true;
			}
			//last choice, function return. we just skip param list here
			else if (c == ')')
			{
				//lookup "functionName(param list)"
				var i:int = pos-2;
				var level:int = 1;
				var ch:String;
				while (i > pos-50 && level!=0)
				{
					ch = text.charAt(i);
					//skip string literals
					if (ch == '"' || ch == "'")
					{
						while (text.charAt(--i) != ch || text.charAt(i-1) == '\\');
					}
					if (ch == '/' && text.charAt(i-1) == '*')
					{
						while (!(text.charAt(--i) == '*' && text.charAt(i-1) == '/')); 
					}
					else if (ch == ')') level ++;
					else if (ch == '(') level --;
					i--;
				}
				if (level != 0) return false;
				startPos = i+1;
				return _parse(true);
			}
			else
				return false;
			
			startPos--;
			if (text.charAt(startPos) == '.') return _parse(false);
			return true;
		}
		
		private function addItem(name:String, type:String):void
		{
			names.unshift(name);
			types.unshift(type);
		}
	}
}