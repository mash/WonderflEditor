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

package ro.minibuilder.swcparser
{
	import com.victordramba.console.debug;
	
	import flash.utils.ByteArray;
	
	import nochump.util.zip.ZipEntry;
	import nochump.util.zip.ZipFile;
	
	import ro.minibuilder.asparser.TypeDB;

	public class SWCParser
	{
		public static function parse(swcData:ByteArray):TypeDB
		{
			var zip:ZipFile = new ZipFile(swcData);
			for each (var file:ZipEntry in zip.entries)
			{
				//trace("filename:", file.name);
				if (/library\.swf$/.test(file.name))
					return SWFParser.parse(zip.getInput(file));
			}
			throw new Error('library.swf not found in swc');
			return null;
		}
	}
}