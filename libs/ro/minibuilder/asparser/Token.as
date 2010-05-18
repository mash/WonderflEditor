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
 */

package ro.minibuilder.asparser
{
	import flash.utils.Dictionary;
	
	import ro.victordramba.util.HashMap;

	internal class Token {
		public static const STRING_LITERAL:String = "stringLiteral";
		public static const SYMBOL:String = "symbol";
		public static const STRING:String = "string";
		public static const NUMBER:String = "number";
		public static const KEYWORD:String = "keyword";
		public static const KEYWORD2:String = "keyword2";
		public static const COMMENT:String = "comment";
		
		public static const REGEXP:String = "regexp";
		
		public static const E4X:String = "e4x";
		/*public static const E4X_TAG:String = "e4xTag";
		public static const E4X_TEXT:String = "e4xText";
		public static const E4X_CDATA:String = "e4xCdata";
		public static const E4X_COMMENT:String = "e4xComment";
		public static const E4X_COMMAND:String = "e4xCommand";*/

		public var string:String, type:String, pos:uint;
		public var id:uint;

		public var children:Array/*of Token*/;
		public var parent:Token;

		public var scope:Field;//lexical scope
		public var imports:HashMap;//used to solve names and types

		public static var map:Dictionary = new Dictionary(true);

		static private var count:Number = 0;


		public function Token(string:String, type:String, endPos:uint) {
			this.string = string;
			this.type = type;
			this.pos = endPos - string.length;
			id = count++;
			map[id] = this;
		}

		public function toString():String {
			return string;
		}
	}
}