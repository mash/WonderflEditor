package net.wonderfl.editor.manager 
{
	import flash.net.SharedObject;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class LocalSettingManager
	{
		private static var _this:LocalSettingManager;
		public static function initialize():void {
			_this = new LocalSettingManager;
		}
		public static function getInstance():LocalSettingManager { return (_this ||= new LocalSettingManager); }
		private var _shaedObject:SharedObject;
		
		public function LocalSettingManager() {
			try {
				_shaedObject = SharedObject.getLocal('WonderflEditor');
			} catch (e:Error) {	} // cannot use shared object
			
			if (_shaedObject) init();
		}
		
		private function init():void {
			if ('autoBraceInsertion' in _shaedObject.data)
				EditManager.autoBraceInsertion = _shaedObject.data.autoBraceInsertion;
		}
		
		public function set autoBraceInsertion(value:Boolean):void {
			EditManager.autoBraceInsertion = value;
			if (_shaedObject) {
				_shaedObject.data.autoBraceInsertion = value;
				save();
			}
		}
		
		private function save():void {
			try {
				_shaedObject.flush(1024 * 10); // 10 KB
			} catch (e:Error) { } // cannot write shared object
		}
		
	}

}