package net.wonderfl.editor.livecoding 
{
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class LiveCodingSettings
	{
		public static var ticket:String;
		public static var server:String;
		public static var port:int;
		public static var room:String;
		public static function setUpParameters($params:Object):void {
			for each (var paramName:String in ["ticket", "server", "port", "room"])
				LiveCodingSettings[paramName] = $params[paramName];
		}
	}
}