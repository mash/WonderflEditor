package net.wonderfl.chat 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import net.wonderfl.component.core.UIComponent;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ChatMessageIcon extends UIComponent
	{
		private static var _cache:Object = { };
		public static const ICON_SIZE:uint = 16;
		private var _iconURL:String;
		private var _icon:Bitmap;
		private var _loader:Loader;
		
		public function ChatMessageIcon($iconURL:String) 
		{
			_width = _height = ICON_SIZE;
			_iconURL = $iconURL;
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
		}
		
		private function onRemoved(e:Event):void 
		{
			if (_loader) {
				try {
					_loader.close();
				} catch (e:Error) { }
			}
		}
		
		private function onAdded(e:Event):void 
		{
			if (_icon == null) {
				var key:String = _iconURL.split('/').pop();
				if (_cache[key]) {
					addChild(_icon = new Bitmap(_cache[key]));
				} else {
					_loader = new Loader;
					_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, complete);
					_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);
					_loader.load(new URLRequest(_iconURL));
				}
			}
		}
		
		private function removeListeners():void {
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, complete);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
		}
		
		private function ioError(e:IOErrorEvent):void 
		{
			removeListeners();
		}
		
		private function complete(e:Event):void 
		{
			removeListeners();
			_icon = Bitmap(_loader.contentLoaderInfo.content);
			
			var bd:BitmapData = new BitmapData(ICON_SIZE, ICON_SIZE);
			var scale:Number = ICON_SIZE / _icon.width;
			bd.draw(_icon.bitmapData, new Matrix(scale, 0, 0, scale), null, null, null, true);
			
			_icon = new Bitmap(bd);
			_cache[_iconURL.split('/').pop()] = bd.clone();
			addChild(_icon);
			_loader = null;
		}
	}
}