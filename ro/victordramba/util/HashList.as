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
	public class HashList extends HashMap
	{
		private var list:Array = [];

		override public function setValue(key:String, value:*):void
		{
			if (list.indexOf(key) == -1)
				list.push(key);
			super.setValue(key, value);
		}
		
		public function get length():int
		{
			return list.length;
		}

		override public function toArray():Array
		{
			var a:Array = [];
			var l:uint = list.length;
			for (var i:uint=0; i<l; i++)
				a.push(getValue(list[i]));
			return a;
		}
		
		override public function merge(hm:HashMap) : void
		{
			throw new Error('Not implemented');
		}
	}
}