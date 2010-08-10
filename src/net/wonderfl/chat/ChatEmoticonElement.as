package net.wonderfl.chat 
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.GraphicElement;
	import flash.text.engine.TextBaseline;
	import net.wonderfl.editor.font.FontSetting;
	import net.wonderfl.utils.bind;
	import net.wonderfl.widget.Wanco;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ChatEmoticonElement extends Sprite
	{
		private static const ACTION_LIST:Array = ["turn", "turnFace", "jump1", "jump2", "walk", "squat", "run", "question", "exclamation", "heart", "sing", "pout", "star", "sleep", "wakeUp"];
		private static var _task:Array = [];
		private var _graphic:GraphicElement;
		private static var _libLoaded:Boolean = false;
		
		public function ChatEmoticonElement($iconName:String, $elementFormat:ElementFormat) 
		{
			mouseChildren = mouseEnabled = false;
			var container:Sprite = new Sprite;
			var elf:ElementFormat = $elementFormat.clone();
			elf.dominantBaseline = TextBaseline.IDEOGRAPHIC_CENTER;
			
			_graphic = new GraphicElement(container, 16, 16, elf);
			
			if (!_libLoaded) {
				loadLib();
				
				_task.push(drawGraphic);
				return;
			}
			
			drawGraphic();
			
			function drawGraphic():void {
				var wanco:Wanco = new Wanco;
				container.addChild(wanco);
				container.x = 8;
				container.y = 16;
				container.scaleX = container.scaleY = 0.3;
				var rect:Rectangle = wanco.getBounds(container);
				container.graphics.beginFill(0xffffff);
				container.graphics.drawRect(rect.left, rect.top, rect.width, rect.height);
				container.graphics.endFill();
				wanco[$iconName]();
			}
		}
		
		private static function loadLib():void {
			var libLoader:Loader = new Loader;
			libLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function complete():void {
				libLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, complete);
				_libLoaded = true;
				
				while (_task.length) _task.pop()();
			});
			libLoader.load(new URLRequest('/static/assets/wanco_library.swf'), new LoaderContext(true, ApplicationDomain.currentDomain));
		}
		
		public function get graphic():GraphicElement { return _graphic; }
		public static function isValidEmoticon($iconName:String):Boolean {
			return false;
			return (ACTION_LIST.indexOf($iconName) > -1);
		}
	}
}