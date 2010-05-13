package net.wonderfl.editor.core 
{
	import com.adobe.serialization.json.JSON;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontMetrics;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	import flash.text.engine.GraphicElement;
	import flash.text.engine.GroupElement;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineMirrorRegion;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.getTimer;
	import net.wonderfl.editor.IEditor;
	import net.wonderfl.editor.utils.calcFontBox;
	import ro.victordramba.scriptarea.ScriptCursor;
	import ro.victordramba.scriptarea.Base;
	
	[Event(name = 'resize', type = 'flash.events.Event')]
	[Event(name = 'scroll', type = 'flash.events.Event')]
	public class FTETextField extends Base implements IEditor
	{
		protected var _caret:int;
		protected var _selStart:int = 0;
		protected var _selEnd:int = 0;
		protected var cursor:ScriptCursor;
		
		protected var _text:String = '';
		
		private var boxHeight:int = 16;
		private var boxWidth:int = 12;
		
		protected var _scrollY:int = 0;
		protected var _scrollH:int = 0;
		private var firstPos:int = 0;
		private var lastPos:int = 0;
		protected var _maxScrollV:int = 0;
		protected var _maxScrollH:int = 0;
		
		private var _selectionShape:Shape;
		
		public var visibleRows:int;
		public var visibleColumns:int;
		private var _maxWidth:int;
		
		static protected var NL:String = '\r';
		
		//format. very simplified
		private var runs:Array = [];
		
		private var _defaultTextFormat:TextFormat;
		private var _block:TextBlock;
		private var _textLineCache:Array = [];
		private var _textLineContainer:Sprite = new Sprite;
		private var _numLines:int;
		private var _textDecorationContainer:Sprite = new Sprite;
		private var _container:Sprite;
		private var _scrollYEngine:Sprite = new Sprite;
		
		public function FTETextField()
		{
			//mouseChildren = false;
			mouseEnabled = true;
			buttonMode = true;

			
			_selectionShape = new Shape;
			_defaultTextFormat = new TextFormat('_ゴシック', 12, 0xffffff);
			//for each (var fnt:Font in Font.enumerateFonts(true))
				//if (fnt.fontName == 'ＭＳ Ｐゴシック')
				//{
					//_defaultTextFormat.font = fnt.fontName;
					//_defaultTextFormat.size = 12;
					//break;
				//}
			//
			var rect:Rectangle = calcFontBox(_defaultTextFormat);
			boxHeight = rect.height;
			boxWidth = rect.width;
			addChild(_container = new Sprite);
			
			_container.addChild(_textDecorationContainer);
			_container.addChild(_selectionShape);
			_container.addChild(_textLineContainer);
			_textDecorationContainer.mouseChildren = _textDecorationContainer.mouseEnabled = false;
			
			_block = new TextBlock;
			
			cursor = new ScriptCursor;
			cursor.visible = false;
			cursor.mouseChildren = cursor.mouseEnabled = false;
			ScriptCursor.height = boxHeight;
			_container.addChild(cursor);
		}
		
		
		public function get defaultTextFormat():TextFormat
		{
			return _defaultTextFormat;
		}
		
		public function get length():int
		{
			return _text.length;
		}
		
		public function set scrollY(value:int):void
		{
			if (_scrollY == value) return;
			
			_scrollY = Math.min(Math.max(0, value), _maxScrollV);
			
			if (!_scrollYEngine.hasEventListener(Event.ENTER_FRAME)) {
				_scrollYEngine.addEventListener(Event.ENTER_FRAME, function (e:Event):void {
					_scrollYEngine.removeEventListener(Event.ENTER_FRAME, arguments.callee);
					
					updateScrollProps();
					//updateCaret();
					_setSelection(_selStart, _selEnd);
					
					
					
					dispatchEvent(new Event(Event.SCROLL, true));
				});
			}
		}
		
		public function get scrollY():int
		{
			return _scrollY;
		}
		
		protected function updateScrollProps():void
		{
			var t:int = getTimer();
			var i:int, pos:int;
			//compute maxscroll
			for (i = 0, pos = 0; pos != -1; pos = _text.indexOf(NL, pos + 1)) i++;
			_maxScrollV = Math.max(0, i - visibleRows);
			
			if (_scrollY > _maxScrollV)
			{
				_scrollY = _maxScrollV;
				return;
			}
			
			for (i = _scrollY, pos=0; i > 0; i--)
				pos = _text.indexOf(NL, pos)+1;
			firstPos = pos;
			
			for (i = visibleRows, pos = firstPos - 1; i > 0; i--)
			{
				pos = _text.indexOf(NL, pos+1);
				if (pos == -1)
				{
					pos = _text.length;
					break;
				}
			}
			lastPos = pos;
			
			trace('updateScrollProps : ' + (getTimer() - t) + ' ms');
			updateVisibleText();
		}
		
		public function get maxScrollV():int
		{
			return _maxScrollV;
		}
		
		public function get caretIndex():int
		{
			return _caret;
		}
		
		public function get selectionBeginIndex():int
		{
			return _selStart;
		}
		
		public function get selectionEndIndex():int
		{
			return _selEnd;
		}
		
		
		public function appendText(text:String):void
		{
			replaceText(_text.length, _text.length, text);
		}
		
		public function setSelection(beginIndex:int, endIndex:int):void
		{
			_setSelection(beginIndex, endIndex, true);
		}
		
		public function _setSelection(beginIndex:int, endIndex:int, caret:Boolean=false):void
		{
			var t:int = getTimer();
			_selStart = beginIndex;
			_selEnd = endIndex;
			
			if (_selStart > _selEnd)
			{
				var tmp:int = _selEnd;
				_selEnd = _selStart;
				_selStart = tmp;
			}
			
			var i0:int = Math.max(_selStart, firstPos);
			var i1:int = Math.min(_selEnd, lastPos);
			
			trace('getting selStart');
			var p0:Point = getPointForIndex(i0);
			var p1:Point;
			if (i0 != i1) {
				trace('getting selEnd');
			}
			p1 = (i0 == i1) ? p0.clone() : getPointForIndex(i1);
			var g:Graphics = _selectionShape.graphics;
			g.clear();
			if (_selStart != _selEnd && _selStart <= lastPos && _selEnd >= firstPos)
			{
				g.beginFill(0x663333);
				if (p0.y == p1.y)
					g.drawRect(p0.x, p0.y, p1.x - p0.x, boxHeight);
				else
				{
					g.drawRect(p0.x, p0.y, width - p0.x, boxHeight);
					var rows:int = (p1.y - p0.y) / boxHeight;
					for (var i:int=1; i<rows; i++)
						g.drawRect(1, p0.y + boxHeight * i, width, boxHeight);
					//if selection is past last visible pos, we draw a full line
					g.drawRect(1, p0.y + boxHeight * i, lastPos >= _selEnd ? p1.x : width, boxHeight);
				}
			}
			
			//if (caret)
			//{
				cursor.visible = _caret <= lastPos && _caret >= firstPos;
				_caret = endIndex;
				cursor.pauseBlink();
				cursor.setX(p1.x);
				cursor.y = p1.y;
				checkScrollToCursor();
			//}
			
			trace('_setSelection : ' + (getTimer() - t) + ' ms');
		}
		
		public function updateCaret():void
		{
			cursor.visible = _caret <= lastPos && _caret >= firstPos;
			cursor.pauseBlink();
			trace('updateCaret');
			var p:Point = getPointForIndex(_caret);
			cursor.setX(p.x);
			cursor.y = p.y;
		}
		
		public function get text():String
		{
			return _text;
		}
		
		public function set text(str:String):void
		{
			replaceText(0, length, str);
		}
		
		public function set defaultTextFormat(value:TextFormat):void 
		{
			_defaultTextFormat = value;
		}
		
		
		public function replaceText($startIndex:int, $endIndex:int, $text:String):void
		{
			$text = $text.replace(/\r\n/g, NL);
			$text = $text.replace(/\n/g, NL);
			
			_numLines = $text.split(NL).length;
			_maxScrollV = Math.max(0, _numLines - visibleRows);
			
			_replaceText($startIndex, $endIndex, $text);
		}
		
		private function _replaceText(startIndex:int, endIndex:int, text:String):void
		{
			var t:int = getTimer();
			_text = _text.substr(0, startIndex) + text + _text.substr(endIndex);
			
			
			if (text.indexOf(NL) != -1 || startIndex!=endIndex)
				updateScrollProps();
			else
				lastPos += text.length;
			
			var i:int;
			var o:Object;//the run
			
				
			//1 remove formats for deleted text
			var delta:int = endIndex - startIndex;
			for (i=0; i<runs.length; i++)
			{
				o = runs[i];
				if (o.begin < startIndex && o.end < startIndex) continue;
				if (o.begin > startIndex && o.end < endIndex)
				{
					runs.splice(i, 1);
					i--;
					continue;
				}
				if (o.begin > startIndex) o.begin -= Math.min(o.begin-startIndex, delta);
				o.end -= Math.min(o.end - startIndex, delta);
			}
			
			//2 stretch format for inserted text
			delta = text.length;
			for (i=0; i<runs.length; i++)
			{
				o = runs[i];
				if (o.begin < startIndex && o.end < startIndex) continue;
				if (o.begin >= startIndex) o.begin += delta;
				if (o.end >= startIndex) o.end += delta;
			}
			
			trace('_replaceText costs : ' + (getTimer() - t) + ' ms');
			
			updateVisibleText();
		}
		
		protected var _invalidated:Boolean = false;
		
		private function updateVisibleText():void {
			var t:int = getTimer();
			var line:TextLine;
			
			if (JobThread.running) {
				_invalidated = true;
				JobThread.abort();
			}
			
			
			var elements:Vector.<ContentElement>;
			var len:int = runs.length;
			var pos:int, index:int;
			var o:Object, oo:Object;
			var str:String;
			var te:TextElement;
			var elf:ElementFormat;
			var link:GraphicElement;
			var linkID:int = 0;
			var font:FontDescription = new FontDescription(_defaultTextFormat.font);
			var linkElement:URLLinkElement;
			
			var i:int;
			var l:int;
			var w:int;
			
			JobThread.addJobs(
				function ():Boolean {
					elements = new Vector.<ContentElement>;
					_invalidated = false;
					i = 0;
					len = runs.length;
					
					return false;
				},
				function ():Boolean {
					var tick:int = getTimer();
					while ((getTimer() - tick) < 100 && !_invalidated) {
						o = runs[i++];
						if (o == null) break;
						if (o.end < firstPos) continue;
						if (o.begin > lastPos) {
							return false;
						}
						
						if (o.begin >= firstPos) {
							str = _text.substring((oo ? oo.end : firstPos), o.begin);
							elf = new ElementFormat(font, _defaultTextFormat.size + 0, 0xffffff);
							te = new TextElement(str, elf);
							elements.push(te);
						}
						
						str = _text.substring(Math.max(o.begin, firstPos), Math.min(o.end, lastPos));
						elf = new ElementFormat(
								new FontDescription(_defaultTextFormat.font, (o.bold ? FontWeight.BOLD : FontWeight.NORMAL), (o.italic ? FontPosture.ITALIC : FontPosture.NORMAL)),
								_defaultTextFormat.size + 0, parseInt("0x" + o.color));
								
						index = 0;
						str.replace(
							new RegExp("https?://[-_.!~*()a-zA-Z0-9;/?:@&=+$,%#]+", "g"),
							function ($url:String, $begin:int, $str:String):String {
								elf = new ElementFormat(
										new FontDescription(_defaultTextFormat.font, (o.bold ? FontWeight.BOLD : FontWeight.NORMAL), (o.italic ? FontPosture.ITALIC : FontPosture.NORMAL)),
										_defaultTextFormat.size + 0, parseInt("0x" + o.color));
								te = new TextElement(str.substring(index, $begin), elf);
								elements.push(te);
								
								elf = new ElementFormat(
										new FontDescription(_defaultTextFormat.font, (o.bold ? FontWeight.BOLD : FontWeight.NORMAL), (o.italic ? FontPosture.ITALIC : FontPosture.NORMAL)),
										_defaultTextFormat.size + 0, parseInt("0x" + o.color));
								te = new TextElement($url, elf);
								te.eventMirror = new LinkElementEventMirror(_textLineContainer, _textDecorationContainer, te, boxHeight);
								elements.push(te);
								
								index = $begin + $url.length;
								
								return $url;
							}
						);
						
						if (index < str.length) {
							elf = new ElementFormat(
									new FontDescription(_defaultTextFormat.font, (o.bold ? FontWeight.BOLD : FontWeight.NORMAL), (o.italic ? FontPosture.ITALIC : FontPosture.NORMAL)),
									_defaultTextFormat.size + 0, parseInt("0x" + o.color));
							elements.push(new TextElement(str.substr(index), elf));
						}
						
						pos = o.end;
						oo = o;
					}
					
					return (o != null && (i < len) && !_invalidated);
				},
				function ():Boolean {
					if (_invalidated) return false;
					
					if (pos < lastPos) {
						str = _text.substring(oo ? oo.end : firstPos, lastPos);
						elf = new ElementFormat(font, _defaultTextFormat.size + 0, 0xffffff);
						te = new TextElement(str, elf);
						pos = lastPos;
						
						elements.push(te);
					}
					
					var group:GroupElement = new GroupElement;
					group.setElements(elements);
					
					_block.content = group;
					
						
					line = null;
					l = 0; w = -1;
					//while (_textLineContainer.numChildren) {
						//_textLineContainer.removeChildAt(0);
					//}
					while (_textDecorationContainer.numChildren)
						_textDecorationContainer.removeChildAt(0);
					
					return false;
				},
				function ():Boolean {
					if (_invalidated) return false;
					
					var tick:int = getTimer();
					
					while ((getTimer() - tick) < 60 && !_invalidated) {
						line = _block.createTextLine(line, TextLine.MAX_LINE_WIDTH);
						
						if (line == null) break;
						
						line.x = 4;
						line.y = boxHeight * ++l - 2;
						w = (w < line.textWidth) ? line.textWidth : w;
						//_textLineContainer.addChild(line);
						if (line.mirrorRegions) {
							drawRegions(line.mirrorRegions);
						} else {
							line.mouseEnabled = line.mouseChildren = false;
						}
					}
					
					if (_invalidated) {
						_invalidated = false;
						line = null;
						return false;
					}
					
					if (line == null) {
						w += 4;
						
						w = (w < width) ? width : w;
						_maxWidth = w;
						//visibleColumns = (width / boxWidth) >> 0;
						//_maxScrollH = ((w / boxWidth) >> 0) - visibleColumns;
						trace('width : ' + w);
					}
					
					return (line != null);
				},
				function ():Boolean {
					addEventListener(Event.RENDER, function render(e:Event):void {
						removeEventListener(Event.RENDER, render);
						var num:int = _textLineContainer.numChildren;
						var children:Array = [];
						for (i = 0; i < num; ++i) {
							children[i] = _textLineContainer.getChildAt(i);
						}
						line = _block.firstLine;
						i = 0;
						while (line) {
							if (i < num) {
								_textLineContainer.removeChild(children[i++]);
							}
							_textLineContainer.addChild(line);
							line = line.nextLine;
						}
						
						while (i < num)
							_textLineContainer.removeChild(children[i++]);
						
						children.length = 0;
					});
					dispatchEvent(new Event(Event.RENDER));
					return false;
				}
			).run();
		}
		
		private function drawRegions($regions:Vector.<TextLineMirrorRegion>):void
		{
			var len:int = $regions.length;
			var region:TextLineMirrorRegion;
			var linkMirror:LinkElementEventMirror;
			for (var i:int = 0; i < len; ++i) 
			{
				
				region = $regions[i];
				linkMirror = region.mirror as LinkElementEventMirror;
				linkMirror.draw(region);
			}
		}
		
		
		public function replaceSelection(text:String):void
		{
			replaceText(_selStart, _selEnd, text);
			
			//FIXME filter text
			_setSelection(_selStart+text.length, _selStart+text.length, true);
		}
		
		
		override protected function updateSize():void
		{
			super.updateSize();
			visibleRows = (height / boxHeight) >> 0;
			updateScrollProps();
			cursor.setSize(width, boxHeight);
		}
		
		protected function checkScrollToCursor():void
		{
			var ct:int, pos:int;
			if (_caret > lastPos)
			{
				//let's count NL between lastPos and caret
				for (ct=0, pos=lastPos; pos!=-1 && pos < _caret; ct++)
					pos = _text.indexOf(NL, pos+1);
				
				scrollY += ct;
			}
			
			//TODO similar
			if (_caret < firstPos)
			{
				//now count NL between firstPos and caret
				for (ct=0, pos=_caret; pos!=-1 && pos<firstPos; ct++)
					pos = _text.indexOf(NL, pos+1);
				scrollY -= ct;
			}
		}
		
		public function gotoLine(line:int):void
		{
			var pos:int = -1;
			while (line > 1)
			{
				pos = _text.indexOf(NL, pos+1);
				line--;
			}
			setSelection(pos+1, pos+1);
		}
		
		protected function getIndexForPoint(p:Point):int
		{
			if (p.y < 0) return firstPos;
			p.x -= _container.x;
			var t:int = getTimer();
			var pos:int = 0;
			var y:int = boxHeight;
			var l:int = 0;
			while (p.y + _scrollY*boxHeight > y)
			{
				pos = _text.indexOf(NL, pos)+1;
				if (pos > lastPos) return lastPos;
				
				if (pos==0)
				{
					pos = _text.length;
					break;
				}
				y += boxHeight; 
				++l;
			}
			var cx:int = 0;
			var c:String;
			var i:int;
			l -= _scrollY;
			
			if (l < 0) return firstPos;
			if (l >= _textLineContainer.numChildren) return lastPos;
			//
			i = 0;
			var line:TextLine = _block.firstLine;
			while (line && i++ < l) {
				line = line.nextLine;
			}
			//var line:TextLine = _textLineContainer.getChildAt(l) as TextLine;
			
			//for (i=pos; i<_text.length && (c=_text.charAt(i))!=NL; i++)
			//{
				//cx += (c=='\t' ? 4 : 1)*boxWidth;
				//if (cx > p.x) break;
			//}
			l = 0; i = pos;
			while (i < _text.length && (c = _text.charAt(i)) != NL) {
				l = i - pos;
				if (line == null || l >= line.atomCount) break;
				cx = line.getAtomBounds(l).x;
				if (cx > p.x - line.x) break;
				
				++i;
			}
			//trace('getIndexForPoint : ' + (getTimer() - t) + ' ms');
			
			return i;
		}
		
		public function getPointForIndex(index:int):Point
		{
			var t:int = getTimer();
			var pos:int = 0;
			var lines:int = 0;
			var lastNL:int = 0;
			while (true)
			{
				pos = _text.indexOf(NL, pos)+1;
				if (pos == 0 || pos > index) break;
				lines++;
				lastNL = pos;
			}
			var ypos:int = (lines - _scrollY) * boxHeight + 2;
			var xpos:int;
			var i:int = 0;
			var line:TextLine;
			var l:int = lines - _scrollY;
			if (l >= 0) {
				//line = _textLineContainer.getChildAt(l) as TextLine;
				i = 0;
				line = _block.firstLine;
				while (line && i++ < l) line = line.nextLine;
				l = index - lastNL;
				if (l >= 0 && line && l < line.atomCount)
					xpos = line.getAtomBounds(index - lastNL).x + line.x;
				else
					calcXposByOriginalMethod("faild @ atomCount");
			} else 
				calcXposByOriginalMethod("faild @ numLines");
			
			function calcXposByOriginalMethod(msg:String):void {
				trace('calcXposByOriginalMethod : ' + msg);
				//count tabs
				for (var i:int=lastNL, tabs:int=0; i<index; i++) if (_text.charAt(i)=='\t') tabs++;
				//simple tabs, just 4 spaces, no align
				xpos = (index - lastNL + tabs * 3) * boxWidth + 4;
			}
			//trace('getPointForIndex : ' + (getTimer() - t) + ' ms');
			//xpos = x;
			return new Point(xpos, ypos);
		}
		
		public function set scrollH(value:int):void {
			_scrollH = value;
			_container.x = - 2 * boxWidth * value;
		}
		
		public function get scrollH():int { return _scrollH; }
		
		public function get numLines():int { return _numLines; }
		
		public function get maxScrollH():int { return _maxScrollH; }
		
		public function get maxWidth():int { return _maxWidth; }

		public function addFormatRun(beginIndex:int, endIndex:int, bold:Boolean, italic:Boolean, color:String):void
		{
			runs.push({begin:beginIndex, end:endIndex, color:color, bold:bold, italic:italic});
		}
		
		public function clearFormatRuns():void
		{
			runs.length = 0;
		}
		
		public function applyFormatRuns():void
		{
			_replaceText(0, 0, '');
		}
		
		public function undo():void { }
		public function redo():void { }
		
	}
}