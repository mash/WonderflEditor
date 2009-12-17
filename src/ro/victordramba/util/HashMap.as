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

package ro.victordramba.util
{
	
	

	public class HashMap
	{
		private static const o:Object = {};
		private var data:Object = {};
		private var data2:Object = {};
		
		public function setValue(key:String, value:*):void
		{
			if (key in o) data2['_'+key] = value;
			else data[key] = value;
		}

		public function getValue(key:String):*
		{
			return (key in o) ? data2['_'+key] : data[key];
		}

		public function hasKey(key:String):Boolean
		{
			return (key in o) ? (('_'+key) in data2) : (key in data);
		}

		public function toArray():Array
		{
			var a:Array = [];
			var item:*;
			for each (item in data)
				a.push(item);
			for each (item in data2)
				a.push(item);
			return a;
		}
		
		public function getKeys():Array/*of String*/
		{
			var a:Array = [];
			var item:String;
			for (item in data)
				a.push(item);
			for (item in data2)
				a.push(item);
			return a;
		}
		
		public function merge(hm:HashMap):void
		{
			var ret:HashMap = new HashMap;
			for each(var key:String in hm.getKeys())
				setValue(key, hm.getValue(key));
		}
	}
}