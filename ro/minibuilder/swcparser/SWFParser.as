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

/* ***** BEGIN LICENSE BLOCK *****
 *
 * Based on abcdump.as from Tamarin VM
 * Author: Dramba Victor
 *
 *
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is [Open Source Virtual Machine.].
 *
 * The Initial Developer of the Original Code is
 * Adobe System Incorporated.
 * Portions created by the Initial Developer are Copyright (C) 2004-2006
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Adobe AS3 Team
 *
 * ***** END LICENSE BLOCK ***** */
 
 /*
STATUS
bugs:
1. toplevel var not hinted
2. toplevel get/set (?)
3. package level function not hinted (!)


//these problems are in Resolver
4. internal class members are visible outside
5. protected class members are visible outside
6. private class members are visible outside


 
 */

package ro.minibuilder.swcparser
{
	//import com.victordramba.console.debug;
	
	import flash.utils.ByteArray;
	
	import ro.minibuilder.asparser.Field;
	import ro.minibuilder.asparser.TypeDB;
	import ro.minibuilder.swcparser.abc.Abc;

    public class SWFParser
    {
	    private var totalSize:int
	
	    public static function parse(swf:ByteArray, exportAbc:Boolean=false):TypeDB
	    {
	    	
	    	trace('swf:'+swf.length);
			
			//if export, we don't parse
			if (!exportAbc)
	    		var typeDB:TypeDB = new TypeDB;
	    	//return typeDB;
	
		    // main
		    var t0:Number = new Date().getTime();
		    var currentFname:String = ''
		    var currentFcount:int = 0

	        swf.endian = "littleEndian"
	        var version:uint = swf.readUnsignedInt()
	        switch (version) 
	        {
		        case 46<<16|14:
		        case 46<<16|15:
		        case 46<<16|16:
		            new Abc(swf, typeDB).dump();
		            break
		        case 67|87<<8|83<<16|10<<24: // SWC10
		        case 67|87<<8|83<<16|9<<24: // SWC9
		        case 67|87<<8|83<<16|8<<24: // SWC8
		        case 67|87<<8|83<<16|7<<24: // SWC7
		        case 67|87<<8|83<<16|6<<24: // SWC6
		            var udata:ByteArray = new ByteArray
		            udata.endian = "littleEndian"
		            swf.position = 8
		            swf.readBytes(udata,0,swf.length-swf.position)
		            var csize:int = udata.length
		            udata.uncompress()
		            //infoPrint("decompressed swf "+csize+" -> "+udata.length)
		            udata.position = 0
		            parseSWF(udata, typeDB);
		            break
		        case 70|87<<8|83<<16|10<<24: // SWC10
		        case 70|87<<8|83<<16|9<<24: // SWC9
		        /*case 70|87<<8|83<<16|8<<24: // SWC8
		        case 70|87<<8|83<<16|7<<24: // SWC7
		        case 70|87<<8|83<<16|6<<24: // SWC6
		        case 70|87<<8|83<<16|5<<24: // SWC5
		        case 70|87<<8|83<<16|4<<24: // SWC4*/
		            swf.position = 8 // skip header and length
					parseSWF(swf, typeDB);
						
		            break
		        default:
		            return null;//unknown format
		            break
	        }
		    //trace('Time: ' + (new Date().getTime() - t0) + 'ms');
		    
		    
		    return typeDB;
		}
		
		/*public static function getDependency(data:ByteArray):XML
		{
			data.endian = "littleEndian";

			if (data[0] == 67)//it's compressed
			{
				var udata:ByteArray = new ByteArray;
				udata.endian = "littleEndian";
				data.position = 8;
				data.readBytes(udata,0,data.length-data.position);
				udata.uncompress();
				udata.position = 0;
				data = udata;
			}
			else
				data.position = 8;
			
			var lib:XML = <library path="library.swf"/>;
			
			var swf:Swf = new Swf(data);
			
			for (var i:int = 0; i<swf.abcs.length; i++)
			{
				var script:XML = <script name={swf.scripts[i]}/>;
				
				var db:TypeDB = new TypeDB;
				new Abc(swf.abcs[i], db).dump();
				
				for each (var item:String in db.listDeps())
					script.appendChild(<def id={item}/>);
					
				lib.appendChild(script);
			}
			
			return lib;
		}*/
		
		private static function parseSWF(data:ByteArray, typeDB:TypeDB):void
		{
			var swf:Swf = new Swf(data);
			abcs = swf.abcs;
			
			if (!typeDB) return;
			for each (var abcd:ByteArray in abcs)
				new Abc(abcd, typeDB).dump();
		}
		
		public static var abcs:Vector.<ByteArray>;
		
	}//end class SWFParser
}//end package

//import com.victordramba.console.debug;

import flash.utils.ByteArray;

import ro.minibuilder.asparser.TypeDB;
import ro.minibuilder.swcparser.abc.Abc;


class Swf
{
    private var bitPos:int
    private var bitBuf:int
    
    private var data:ByteArray;
	
	public var abcs:Vector.<ByteArray>;
	public var scripts:Vector.<String>;

    function Swf(data:ByteArray)
    {
        this.data = data
        trace("size "+decodeRect())
        trace("frame rate "+(data.readUnsignedByte()<<8|data.readUnsignedByte()))
        trace("frame count "+data.readUnsignedShort())
		
		abcs = new Vector.<ByteArray>;
		scripts = new Vector.<String>;
        decodeTags()
    }

    //const stagDoABC                 :int = 72;   // embedded .abc (AVM+) bytecode
    //const stagSymbolClass               :int = 76;
    //const stagDoABC2                  :int = 82;   // revised ABC version with a name
    
    private function decodeTags():void
    {
        var type:int, h:int, length:int
        var offset:int

        while (data.position < data.length)
        {
            type = (h = data.readUnsignedShort()) >> 6;

            if (((length = h & 0x3F) == 0x3F))
                length = data.readInt();

            //infoPrint('tagNames['+type+']'+" "+length+"b "+int(100*length/data.length)+"%")
            switch (type)
            {
            case 0: return
            case 82://stagDoABC2:
                var pos1:int = data.position
                data.readInt()
				var scriptName:String = readString();
				//trace("scriptName:", scriptName);
                //Abc.log("\n//abc name "+scriptName)
                length -= (data.position-pos1)
                // fall through
            case 72://stagDoABC:
                var data2:ByteArray = new ByteArray
                data2.endian = "littleEndian"
                data.readBytes(data2,0,length)
				
				//for now, i assume all libs are compiled with doABC2
				scripts.push(scriptName);
				abcs.push(data2);
                //new Abc(data2, typeDB).dump()
                //debug("")
                break
            default:
                data.position += length
            }
        }
    }

    private function readString():String
    {
        var s:String = ""
        var c:int

        while (c=data.readUnsignedByte())
            s += String.fromCharCode(c)

        return s
    }

    private function syncBits():void
    {
        bitPos = 0
    }

    private function decodeRect():Rect
    {
        syncBits();
        var rect:Rect = new Rect();
        var nBits:int = readUBits(5)
        rect.xMin = readSBits(nBits);
        rect.xMax = readSBits(nBits);
        rect.yMin = readSBits(nBits);
        rect.yMax = readSBits(nBits);

        return rect;
    }

    public function readSBits(numBits:int):int
    {
        if (numBits > 32)
            throw new Error("Number of bits > 32");

        var num:int = readUBits(numBits);
        var shift:int = 32-numBits;
        // sign extension
        num = (num << shift) >> shift;
        return num;
    }

    public function readUBits(numBits:int):uint
    {
        if (numBits == 0)
            return 0

        var bitsLeft:int = numBits;
        var result:int = 0;

        if (bitPos == 0) //no value in the buffer - read a byte
        {
            bitBuf = data.readUnsignedByte()
            bitPos = 8;
        }

        while (true)
        {
            var shift:int = bitsLeft - bitPos;
            if (shift > 0)
            {
                // Consume the entire buffer
                result |= bitBuf << shift;
                bitsLeft -= bitPos;

                // Get the next byte from the input stream
                bitBuf = data.readUnsignedByte();
                bitPos = 8;
            }
            else
            {
                // Consume a portion of the buffer
                result |= bitBuf >> -shift;
                bitPos -= bitsLeft;
                bitBuf &= 0xff >> (8 - bitPos); // mask off the consumed bits

//                if (print) System.out.println("  read"+numBits+" " + result);
                return result;
            }
        }
        return 0;
    }
}


class Rect
{
    public var nBits:int
    public var xMin:int, xMax:int
    public var yMin:int, yMax:int
}
