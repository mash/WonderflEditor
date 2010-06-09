package net.wonderfl.editor.minibuilder 
{
	import ro.victordramba.util.HashMap;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ImportManager
	{
		private static var _this:ImportManager;
		private var _packageBeginIndex:int;
		private var _packageEndIndex:int;
		public var packageImport:HashMap;
		public var topImport:HashMap;
		
		public function ImportManager() 
		{
			_this = this;
		}
		
		public function clearData():void {
			_packageBeginIndex = -1;
			_packageEndIndex = -1;
			packageImport = new HashMap;
			topImport = new HashMap;
		}
		
		public static function getInstance():ImportManager {
			return (_this ||= new ImportManager);
		}
		
		public function get imports():HashMap {
			return (_packageEndIndex > -1) ? topImport : packageImport;
		}
		
		public function get packageEndIndex():int { return _packageEndIndex; }
		public function get packageBeginIndex():int { return _packageBeginIndex; }
		
		public function set packageEndIndex(value:int):void 
		{
			_packageEndIndex = value;
		}
		

		public function set packageBeginIndex(value:int):void 
		{
			_packageBeginIndex = value;
		}
	}

}