package net.wonderfl.chat 
{
	import com.adobe.serialization.json.JSON;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontWeight;
	import flash.text.engine.GraphicElement;
	import flash.text.engine.GroupElement;
	import flash.text.engine.TextBaseline;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineMirrorRegion;
	import flash.utils.getTimer;
	import net.wonderfl.component.core.UIComponent;
	import net.wonderfl.editor.core.LinkElementEventMirror;
	import net.wonderfl.editor.font.FontSetting;
	import net.wonderfl.utils.bind;
	import net.wonderfl.utils.listenOnce;
	import net.wonderfl.utils.removeFromParent;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ChatMessage extends UIComponent
	{
		public static const LEFT_OF_TEXT:uint = 21;
		private static var _factory:TextBlock;
		private static var _elf:ElementFormat;
		private static var _headerFormat:ElementFormat;
		private static var _timeFormat:ElementFormat;
		private static var _init:Boolean = (function ():Boolean {
			_factory = new TextBlock;
			
			_elf = new ElementFormat;
			_elf.color = ChatStyle.CHAT_MESSAGE;
			_elf.fontDescription = new FontDescription(FontSetting.GOTHIC_FONT);
			
			_headerFormat = new ElementFormat;
			_headerFormat.color = ChatStyle.CHAT_MESSAGE;
			_headerFormat.fontDescription = new FontDescription(FontSetting.GOTHIC_FONT, FontWeight.BOLD);
			
			_timeFormat = new ElementFormat;
			_timeFormat.color = ChatStyle.TIME_COLOR;
			_timeFormat.fontDescription = new FontDescription(FontSetting.GOTHIC_FONT);
			
			return true;
		})();
		
		
		private var _maxTextWidth:int = 0;
		private var _iconURL:String;
		private var _text:String;
		private var _textWidth:int;
		private var _icon:ChatMessageIcon;
		private var _textLines:Array;
		private var _viewHeight:int;
		private var _startY:int;
		private var _maxTextY:int;
		private var _decorationContainer:Sprite;
		private var _startAtomIndex:int = -1;
		private var _endAtomIndex:int = -1;
		private var _emoticonPositions:Array = [];
		private var _selectionGraphics:Graphics;
		private var _textLineContainer:Sprite;
		private var _linkLineContainer:Sprite;
		private var _tlTime:TextLine;
		private var _seconds:int;
		private var _localJoinedAt:Number;
		private var _timeStr:String = "";
		private var _linkSprite:Sprite;
		
		public function ChatMessage($initData:Object, $joinedAt:Number, $localJoinedAt:Number) 
		{
			_textLines = [];
			
			var shp:Shape = new Shape;
			shp.y = FontSetting.LINE_HEIGHT + 2;
			addChild(shp);
			_selectionGraphics = shp.graphics;
			addChild(_decorationContainer = new Sprite);
			addChild(_linkLineContainer = new Sprite);
			addChild(_textLineContainer = new Sprite);
			
			if ($initData.icon && $initData.name) {
				var userName:String = $initData.name;
				
				addChild(_linkSprite = new Sprite);
				_linkSprite.addEventListener(MouseEvent.CLICK, bind(navigateToURL, [new URLRequest('/user/' + userName), '_blank']));
				
				_linkSprite.addChild(_icon = new ChatMessageIcon($initData.icon));
				_icon.x = 1;
				_factory.content = new TextElement(userName, _headerFormat.clone());
				var line:DisplayObject = _linkSprite.addChild(_factory.createTextLine());
				line.x = LEFT_OF_TEXT;
				line.y = line.height + 1;
			}
			_linkLineContainer.mouseChildren = _linkLineContainer.mouseEnabled = false;
			_textLineContainer.mouseEnabled = _textLineContainer.mouseChildren = false;
			
			_text = $initData.text;
			_seconds = $joinedAt - Number($initData.at);
			_localJoinedAt = $localJoinedAt;
			updateText();
			updateTime();
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
		}
		
		public function updateTime():void {
			var timeStr:String = ChatTimeRule.getTimeStr(((new Date).getTime() - _localJoinedAt) / 1000 + _seconds);
			if (_timeStr == timeStr) return;
			
			_timeStr = timeStr;
			removeFromParent(_tlTime);
			_factory.content = new TextElement(_timeStr, _timeFormat.clone());
			addChild(_tlTime = _factory.createTextLine());
			_tlTime.x = _width - 5 - _tlTime.width;
			_tlTime.y = _tlTime.height + 1;
		}
		
		private function onRemoved(e:Event):void 
		{
			while (_textLineContainer.numChildren) _textLineContainer.removeChildAt(0);
		}
		
		public function onDoubleClick():void {
			//startLine = Math.floor(($start.y - _startY) / FontSetting.LINE_HEIGHT + 0.5);
			//startLine = (startLine < 0) ? 0 : startLine;
			
		}
		
		private function updateText():void
		{
			while (_textLines.length) removeFromParent(_textLines.pop());
			
			var content:Vector.<ContentElement> = new Vector.<ContentElement>;
			var regURL:RegExp = new RegExp("https?://[-_.!~*a-zA-Z0-9;/?:@&=+$,%#]+", "g");
            var regEmoticons:RegExp = /\(:(\w+)\)/g;
			var i:int = 0;
			var url:Object;
			var str:String;
			var textElement:TextElement;
			
			_emoticonPositions.length = 0;
			
			while (url = regURL.exec(_text)) {
				parseEmoticons(_text.substring(i, url.index), i);
				
				textElement = new TextElement(str = url.toString(), _elf.clone());
				textElement.eventMirror = new ChatLinkElementEventMirror(this, _textLineContainer, _decorationContainer, textElement, FontSetting.LINE_HEIGHT);
				content.push(textElement);
				i = url.index + str.length;
			}
			if (i < _text.length) {
				parseEmoticons(_text.substr(i), i);
			}
			
			function parseEmoticons($str:String, $baseIndex:int):void {
				regEmoticons.lastIndex = 0;
				var emoticon:Object;
				var length:int;
				var i:int = 0;
				while (emoticon = regEmoticons.exec($str))
					if (ChatEmoticonElement.isValidEmoticon(str = emoticon[1])) {
						length = emoticon[0].length;
						content.push(new TextElement($str.substring(i, emoticon.index), _elf.clone()));
						content.push(new ChatEmoticonElement(str, _elf.clone()).graphic);
						_emoticonPositions.push( { index:$baseIndex + emoticon.index, length:length } );
						i = emoticon.index + length;
					}
					
				if (i < $str.length)
					content.push(new TextElement($str.substr(i), _elf.clone()));
			}
			
			_factory.content = new GroupElement(content);
			var line:TextLine;
			var yPos:int = (FontSetting.LINE_HEIGHT >> 1) + FontSetting.LINE_HEIGHT + 2;
			_startY = yPos;
			
			while (line = _factory.createTextLine(line, _textWidth)) {
				line.x = LEFT_OF_TEXT;
				line.y = yPos;
				line.mouseChildren = line.mouseEnabled = false;
				if (line.mirrorRegions) drawRegions(line.mirrorRegions);
				_textLines.push(line);
				yPos += FontSetting.LINE_HEIGHT;
			}
			
			_maxTextY = yPos;
			_height = Math.max(_icon ? _icon.height : 0, yPos - FontSetting.LINE_HEIGHT);
			updateView();
		}
		
		public function selectArea($start:Point, $end:Point):void {
			var time:int = getTimer();
			var startLine:int, endLine:int;
			var selectedFromBegining:Boolean;
			var selectedTillEnd:Boolean;
			if ($start.y < 0) {
				$start.y = 0;
				selectedFromBegining = true;
			}
			startLine = Math.floor(($start.y - _startY) / FontSetting.LINE_HEIGHT + 0.5);
			startLine = (startLine < 0) ? 0 : startLine;
			$start.y = startLine * FontSetting.LINE_HEIGHT + _startY;
			
			endLine = Math.ceil(($end.y - _startY) / FontSetting.LINE_HEIGHT + 0.5);
			endLine = (endLine < 1) ? 1 : endLine;
			if (endLine > _textLines.length ) {
				selectedTillEnd = true;
				endLine = _textLines.length;
			}
			$end.y = endLine * FontSetting.LINE_HEIGHT + _startY;
			
			var line:TextLine;
			var startX:int, endX:int = 0, yPos:int;
			var boundary:Rectangle;
			_selectionGraphics.clear();
			_selectionGraphics.beginFill(ChatStyle.SELECTION_COLOR);
			for (var i:int = startLine; i < endLine; ++i) 
			{
				startX = LEFT_OF_TEXT;
				line = _textLines[i];
				if (i > startLine && i < endLine - 1) {
					startX = line.x;
					endX = line.x + line.width;
				}
				if (i == startLine) {
					if (selectedFromBegining) {
						startX = LEFT_OF_TEXT;
						_startAtomIndex = 0;
					} else if ($start.x <= line.x) {
						startX = line.x;
						_startAtomIndex = 0;
					} else if ($start.x > line.x + line.width) {
						_startAtomIndex = line.atomCount;
						continue;
					} else {	
						_startAtomIndex = 0;
						while (_startAtomIndex < line.atomCount && (startX = LEFT_OF_TEXT + line.getAtomBounds(_startAtomIndex).left) < $start.x) ++_startAtomIndex;
					}
					_startAtomIndex += line.textBlockBeginIndex;
					
					if (startLine != endLine + 1)
						endX = line.x + line.width;
				}
				if (i == endLine - 1) {
					if (selectedTillEnd) {
						endX = LEFT_OF_TEXT + line.width;
						_endAtomIndex = _text.length;
					} else if ($end.x <= line.x) {
						_endAtomIndex = line.textBlockBeginIndex - 1;
						continue;
					} else if ($end.x > line.x + line.width) {
						endX = LEFT_OF_TEXT + line.width;
						_endAtomIndex = line.textBlockBeginIndex + line.atomCount - 1;
					} else {
						_endAtomIndex = 0;
						while (_endAtomIndex < line.atomCount && (endX = LEFT_OF_TEXT + line.getAtomBounds(_endAtomIndex).right) < $end.x) ++_endAtomIndex;
						_endAtomIndex += line.textBlockBeginIndex;
					}
					_endAtomIndex
				}
				yPos = (i - 0.25) * FontSetting.LINE_HEIGHT;
				if (yPos < _viewHeight)
					_selectionGraphics.drawRect(startX, yPos, endX - startX, FontSetting.LINE_HEIGHT);
			}
			_selectionGraphics.endFill();
		}
		
		public function selectAll():void {
			var len:int = _textLines.length;
			var line:TextLine, yPos:int;
			_selectionGraphics.clear();
			_selectionGraphics.beginFill(ChatStyle.SELECTION_COLOR);
			for (var i:int = 0; i < len; ++i) 
			{
				line = _textLines[i];
				yPos = (i - 0.25) * FontSetting.LINE_HEIGHT;
				if (yPos < _viewHeight) _selectionGraphics.drawRect(LEFT_OF_TEXT, yPos, line.width, FontSetting.LINE_HEIGHT);
			}
			_selectionGraphics.endFill();
			_startAtomIndex = 0;
			_endAtomIndex = len;
		}
		
		public function getSelectedText():String {
			if (_startAtomIndex == -1) return "";
			
			var begin:int, end:int;
			begin = _startAtomIndex;
			end = _endAtomIndex + 1;
			end = (end >= _text.length) ? _text.length : end;
			
			var len:int = _emoticonPositions.length;
			var pos:Object;
			for (var i:int = 0; i < len; ++i) 
			{
				pos = _emoticonPositions[i];
				if (pos.index <= begin) begin += pos.length;
				if (pos.index < end) end += pos.length;
			}
			if (end > _text.length) end = _text.length;
			
			return _text.substring(begin, end);
		}
		
		public function clearSelection():void {
			_selectionGraphics.clear();
			_endAtomIndex = _startAtomIndex = -1;
		}
		
		private function drawRegions($regions:Vector.<TextLineMirrorRegion>):void {
			var len:int = $regions.length;
			var region:TextLineMirrorRegion;
			var linkMirror:ChatLinkElementEventMirror;
			for (var i:int = 0; i < len; ++i) 
			{
				region = $regions[i];
				linkMirror = region.mirror as ChatLinkElementEventMirror;
				linkMirror.draw(region);
			}
		}
		
		public function updateView():void {
			if (_icon) {
				if (_icon.parent) {
					if (y < -_icon.height || y > _viewHeight) removeChild(_icon);
				} else if (y > -_icon.height && y < _viewHeight)
					addChild(_icon);
			}
			
			var len:int = _textLines.length;
			var line:TextLine;
			for (var i:int = 0; i < len; ++i) 
			{
				line = _textLines[i];
				if (line.parent) {
					if (y + line.y < -FontSetting.LINE_HEIGHT || y + line.y > _viewHeight) _textLineContainer.removeChild(line);
				} else if (y + line.y >  - FontSetting.LINE_HEIGHT && y + line.y < _viewHeight) {
					_textLineContainer.addChild(line);
				}
			}
		}
		
		override protected function updateSize():void 
		{
			_textWidth = _width - 50;
			graphics.clear();
			graphics.beginFill(ChatStyle.MESSAGE_ITEM_HEADER);
			graphics.drawRect(0, -1, _width, ChatMessageIcon.ICON_SIZE + 2);
			updateText();
			
			if (_tlTime) _tlTime.x = _width - 5 - _tlTime.width;
		}
		
		public function set viewHeight(value:int):void 
		{
			_viewHeight = value;
		}
		
		public function get textWidth():int { return _textWidth; }
		
	}

}