package ro.victordramba.scriptarea
{
	import com.victordramba.debug.debug;
	
	import flash.utils.ByteArray;
	
	public class Util
	{
		public static function decodeUTF(b0:int, b1:uint):String
		{
			var ba:ByteArray = new ByteArray;
			ba.writeByte(b1);
			ba.writeByte(b0);
			ba.position = 0;
			return ba.readUTFBytes(2);
		}
	}
}