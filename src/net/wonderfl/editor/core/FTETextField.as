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
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import mx.events.ScrollEvent;
	import mx.events.ScrollEventDirection;
	import net.wonderfl.editor.error.ErrorMessage;
	import net.wonderfl.editor.error.ErrorMessageLayer;
	import net.wonderfl.editor.ITextArea;
	import net.wonderfl.editor.operations.SetSelection;
	import net.wonderfl.editor.utils.removeAllChildren;
	import net.wonderfl.editor.we_internal;
	import net.wonderfl.editor.utils.calcFontBox;
	import net.wonderfl.thread.ThreadTask;
	import net.wonderfl.thread.ThreadExecuter;
	import ro.victordramba.scriptarea.ScriptCursor;
	import ro.victordramba.scriptarea.Base;
	
	[Event(name = 'resize', type = 'flash.events.Event')]
	[Event(name = 'scroll', type = 'mx.events.ScrollEvent')]
	public class FTETextField extends UIComponent implements ITextArea
	{
		we_internal var _caret:int;
		we_internal var _selStart:int = 0;
		we_internal var _selEnd:int = 0;
		protected var cursor:ScriptCursor;
		
		we_internal var _text:String = '';
		
		public var boxHeight:int = 16;
		public var boxWidth:int = 12;
		
		protected var _scrollY:int = 0;
		protected var _scrollH:int = 0;
		private var firstPos:int = 0;
		private var lastPos:int = 0;
		protected var _maxScrollV:int = 0;
		protected var _maxScrollH:int = 0;
		
		private var _selectionShape:Shape;
		
		public var visibleRows:int;
		public var visibleColumns:int;
		private var _maxWidth:int = -1;
		
		static public var NL:String = '\n';
		
		//format. very simplified
		private var runs:Array = [];
		
		private var _defaultTextFormat:TextFormat;
		private var _block:TextBlock;
		private var _textLineCache:Vector.<uint> = new Vector.<uint>;
		protected var _textLineContainer:Sprite = new Sprite;
		private var _numLines:int;
		private var _textDecorationContainer:Sprite = new Sprite;
		private var _errorLayer:ErrorMessageLayer;
		we_internal var _container:Sprite;
		private var _scrollYEngine:Sprite = new Sprite;
		private var _charHighlight:CharHighlighter = new CharHighlighter;
		protected var _igonoreCursor:Boolean = false;
		we_internal var _preventHScroll:Boolean = false;
		private var _setSelectionPromise:SetSelection = null;
		
		
		use namespace we_internal;
		
		public function FTETextField()
		{
			mouseEnabled = true;
			buttonMode = true;
			
			_errorLayer = new ErrorMessageLayer(this);
			_selectionShape = new Shape;
			_defaultTextFormat = new TextFormat('_typewriter', 12, 0xffffff);
			//_defaultTextFormat = new TextFormat('Courier NewCourier New', 12, 0xffffff);
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
			_container.addChild(_errorLayer);
			_container.addChild(_selectionShape);
			_container.addChild(_textLineContainer);
			//_textDecorationContainer.mouseChildren = _textDecorationContainer.mouseEnabled = false;
			_textLineContainer.mouseChildren = _textLineContainer.mouseEnabled = false;
			
			_block = new TextBlock;
			
			cursor = new ScriptCursor;
			//cursor.visible = false;
			cursor.mouseChildren = cursor.mouseEnabled = false;
			ScriptCursor.height = boxHeight;
			_container.addChild(cursor);
		}
		
		public function clearErrorMessages():void {
			_errorLayer.clearErrorMessages();
		}
		
		public function addErrorMessage($message:ErrorMessage):void {
			_errorLayer.addErrorMessage($message);
		}
		
		public function get defaultTextFormat():TextFormat
		{
			return _defaultTextFormat;
		}
		
		public function get length():int
		{
			return _text.length;
		}
		
		public function get cursorPosition():Point {
			return new Point(cursor.getX(), cursor.y);
		}
		
		public function set scrollY(value:int):void
		{
			value = Math.min(Math.max(0, value), _maxScrollV);
			if (_scrollY == value && !_igonoreCursor) return;
			
			var delta:int = value - _scrollY;
			_scrollY = value;
			updateScrollProps();
			trace("FTETextField :: scrollY : " + scrollY);
			
			dispatchEvent(
				new ScrollEvent(
					ScrollEvent.SCROLL, false, false, null,
					value, ScrollEventDirection.VERTICAL, delta
				)
			);
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
			//for (i = 0, pos = 0; pos != -1; pos = _text.indexOf(NL, pos + 1)) i++;
			_maxScrollV = Math.max(0, _numLines - visibleRows);
			
			if (_scrollY > _maxScrollV)
			{
				_scrollY = _maxScrollV;
				return;
			}
			
			//for (i = _scrollY, pos=0; i > 0; i--)
				//pos = _text.indexOf(NL, pos)+1;
			
			firstPos = (_scrollY > 0) ? _textLineCache[_scrollY] + 1 : 0;
			
			i = Math.min(visibleRows, _numLines) + _scrollY;
			
			pos = (i < _textLineCache.length) ? _textLineCache[i] : _text.length;
			lastPos = pos;
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
		
		public function set setSelectionPromise(value:SetSelection):void {
			if (ThreadExecuter.running)
				_setSelectionPromise = value;
			else 
				_setSelection(value.beginIndex, value.endIndex, true);
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
			
			var p0:Point = getPointForIndex(i0);
			var p1:Point;
			p1 = (i0 == i1) ? p0.clone() : getPointForIndex(i1);
			
			trace('start draw selection ' + p0 + p1);
			var g:Graphics = _selectionShape.graphics;
			g.clear();
			if (_selStart != _selEnd && _selStart <= lastPos && _selEnd >= firstPos)
			{
				g.beginFill(0x663333);
				if (p0.y == p1.y)
					g.drawRect(p0.x, p0.y, p1.x - p0.x, boxHeight);
				else
				{
					g.drawRect(p0.x, p0.y, _maxWidth - p0.x, boxHeight);
					var rows:int = (p1.y - p0.y) / boxHeight;// rows >= 1
					if (rows > 1) {
						g.drawRect(1, p0.y + boxHeight, _maxWidth, boxHeight * (rows - 1));
					}
					//if selection is past last visible pos, we draw a full line
					g.drawRect(1, p0.y + boxHeight * Math.max(1, rows), lastPos >= _selEnd ? p1.x : _maxWidth, boxHeight);
				}
			}
			
			cursor.setX(p1.x);
			cursor.y = p1.y;
			
			if (caret && !_igonoreCursor)
			{
				_caret = endIndex;
				checkScrollToCursor();
			}
		}
		
		public function updateCaret():void
		{
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

			$text ||= "";
			_replaceText($startIndex, $endIndex, $text);
		}
		
		we_internal function __replaceText(startIndex:int, endIndex:int, text:String):void {
			var t:int = getTimer();
			_text = escapeNewLine(_text.substr(0, startIndex) + text + _text.substr(endIndex)).replace(/\t/gm, "    ");
			
			_numLines = _text.split(NL).length;
			_maxScrollV = Math.max(0, _numLines - visibleRows);
			
			_textLineCache.length = 0;
			_textLineCache[0] = 0;
			var pos:int = 0;
			var i:int = 0;
			while (true) {
				pos = _text.indexOf(NL, pos);
				if (pos == -1) break;
				_textLineCache[++i] = pos++;
			}
			
			if (text.indexOf(NL) != -1 || startIndex != endIndex) {
				updateScrollProps();
			}
			else
				lastPos += text.length;
			
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
			
			if (startIndex == 0 && endIndex == length && text == '') {
				removeAllChildren(_textDecorationContainer);
				removeAllChildren(_textLineContainer);
			} else {
				updateVisibleText();
			}
			CONFIG::benchmark { trace('_replaceText costs : ' + (getTimer() - t) + ' ms'); }
		}
		
		protected function _replaceText(startIndex:int, endIndex:int, text:String):void
		{
			we_internal::__replaceText(startIndex, endIndex, text);
		}
		
		private function updateVisibleText():void {
			CONFIG::benchmark { trace('updateVisibleText'); }
			var t:int = getTimer();
			var line:TextLine;
			
			killTasks();
			
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
			//var linkElement:URLLinkElement;
			var killFlag:Boolean = false;
			
			var i:int;
			var l:int;
			var w:int;
			
			ThreadExecuter.onComplete = function ():void {
				_igonoreCursor = false;
			};
			
			ThreadExecuter.addTask(
				function ():void {
					killFlag = true;
				},
				function ():Boolean {
					elements = new Vector.<ContentElement>;
					
					killFlag = false;
					i = 0;
					len = runs.length;
					
					// skip formats
					var searchBegin:int;
					var searchEnd:int;
					
					return false;
				},
				function ():Boolean {
					if (killFlag) return false;
					
					var tick:int = getTimer();
					while ((getTimer() - tick) < 5) {
						o = runs[i++];
						if (o == null) break;
						if (o.end < firstPos) continue;
						if (o.begin > lastPos) {
							return false;
						}
						
						if (o.begin >= firstPos) {
							str = _text.substring((oo ? oo.end : firstPos), o.begin);
							elf = new ElementFormat(font, _defaultTextFormat.size + 0, 0xffffff);
							if (killFlag) return false;
							replaceURLString();
						}
						
						str = _text.substring(Math.max(o.begin, firstPos), Math.min(o.end, lastPos));
						elf = new ElementFormat(
								new FontDescription(_defaultTextFormat.font, (o.bold ? FontWeight.BOLD : FontWeight.NORMAL), (o.italic ? FontPosture.ITALIC : FontPosture.NORMAL)),
								_defaultTextFormat.size + 0, parseInt("0x" + o.color));
								
						replaceURLString();
						
						pos = o.end;
						oo = o;
					}
					
					return (o != null && (i < len) && !killFlag);
				},
				function ():Boolean {
					if (killFlag) return false;
					
					if (pos < lastPos) {
						str = _text.substring(oo ? oo.end : firstPos, lastPos);
						elf = new ElementFormat(font, _defaultTextFormat.size + 0, 0xffffff);
						
						replaceURLString();
						pos = lastPos;
					}
					
					var group:GroupElement = new GroupElement;
					group.setElements(elements);
					
					_block.content = group;
					
						
					line = null;
					l = 0; w = -1;
					//while (_textLineContainer.numChildren) {
						//_textLineContainer.removeChildAt(0);
					//}
					_textDecorationContainer.visible = false;
					while (_textDecorationContainer.numChildren)
						_textDecorationContainer.removeChildAt(0);
					
					return false;
				},
				function ():Boolean {
					if (killFlag) return false;
					var tick:int = getTimer();
					
					while ((getTimer() - tick) < 6 && !killFlag) {
						line = _block.createTextLine(line);
						
						if (line == null) break;
						
						line.x = 4;
						line.y = boxHeight * ++l - 2;
						line.mouseChildren = line.mouseEnabled = false;
						w = (w < line.textWidth) ? line.textWidth : w;
						//_textLineContainer.addChild(line);
						if (line.mirrorRegions) {
							drawRegions(line.mirrorRegions);
						}
					}
					
					
					if (line == null) {
						w += 8;
						
						w = (w < _width) ? _width : w;
						if (_maxWidth < w) {
							_maxWidth = w;
							dispatchEvent(new Event(Event.RESIZE));
						}
					}
					
					return (line != null);
				},
				function ():Boolean {
					if (killFlag) return false;
					
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
					
					while (i < num)	_textLineContainer.removeChild(children[i++]);
					
					_textDecorationContainer.visible = true;
					children.length = 0;
					_setSelection(_selStart, _selEnd, true);
					
					return false;
				},
				function ():Boolean {
					if (killFlag) return false;
					
					if (_setSelectionPromise) {
						_setSelection(_setSelectionPromise.beginIndex, _setSelectionPromise.endIndex, true);
						_setSelectionPromise = null;
					}
					_errorLayer.render();
					
					return false;
				},
				drawComplete
			).run();
			
			function replaceURLString():void {
				index = 0;
				str.replace(
					new RegExp("https?://[-_.!~*a-zA-Z0-9;/?:@&=+$,%#]+", "g"),
					function ($url:String, $begin:int, $str:String):String {
						te = new TextElement($str.substring(index, $begin), elf.clone());
						elements.push(te);
						
						te = new TextElement($url, elf.clone());
						te.eventMirror = new LinkElementEventMirror(_textLineContainer, _textDecorationContainer, te, boxHeight);
						elements.push(te);
						
						index = $begin + $url.length;
						
						return $url;
					}
				);
				if (index < str.length) {
					elements.push(new TextElement(str.substr(index), elf.clone()));
				}
			}
		}
		
		protected function drawComplete():Boolean { return false; }
		
		private function killTasks():void
		{
			var jobs:Array = ThreadExecuter.getPendingTaks();
			var len:int = jobs.length;
			var prev:ThreadTask, job:ThreadTask;
			prev = jobs[0];
			var now:int = getTimer();
			for (var i:int = 1; i < len; ++i) {
				job = jobs[i];
				if ((job.id & 3) > 0) {
					ThreadExecuter.killTask(job.id);
				}
			}
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
		
		private function escapeNewLine(str:String):String {
			var result:String = str.replace(/\r/gm, NL);
			
			return result;
		}
		
		
		public function replaceSelection($text:String):void
		{
			replaceText(_selStart, _selEnd, $text);
			
			//FIXME filter text
			_setSelection(_selStart + $text.length, _selStart + $text.length, true);
		}
		
		
		override protected function updateSize():void
		{
			visibleRows = (height / boxHeight) >> 0;
			updateScrollProps();
			cursor.setSize(_width, boxHeight);
			graphics.beginFill(0);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}
		
		we_internal function checkScrollToCursor():void
		{
			if (_igonoreCursor) return;
			
			var result:Object;
			var pos:int;
			var delta:int;
			// check vertical scroll
			if (_caret > lastPos)
			{
				result = countNewLines(lastPos, _caret);
				_igonoreCursor = true;
				scrollY += result.numNewLines;
			}
			if (_caret < firstPos)
			{
				result = countNewLines(_caret, firstPos);
				_igonoreCursor = true;
				scrollY -= result.numNewLines;
			}
			
			if (_preventHScroll) {
				_preventHScroll = false;
				return;
			}
			
			var maxCols:int = Math.ceil(_maxWidth / boxWidth);
			var currentCols:int = (cursor.getX() / boxWidth) >> 0;
			var numCols:int = (_width / boxWidth) >> 0;
			var tolerance:int = 1 << 3;
			var scroll:int;
			// check horizontal scroll
			if (currentCols > numCols - tolerance) {
				scroll += (currentCols - numCols + tolerance);
				scrollH = (scroll > maxCols) ? maxCols : scroll;
			} else if (currentCols < _scrollH + tolerance) {
				scroll += (currentCols - _scrollH - tolerance);
				scrollH = (scroll < 0) ? 0 : scroll;
			}
		}
		
		we_internal function countNewLines($begin:int, $end:int):Object {
			for (var ct:int = 0, pos:int = $begin; pos != -1 && pos < $end; ct++)
				pos = _text.indexOf(NL, pos + 1);
				
			return {
				numNewLines : ct,
				lastNewLinePos : pos
			};
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
			
			l = 0; i = pos;
			while (i < _text.length && (c = _text.charAt(i)) != NL) {
				l = i - pos;
				if (line == null || l >= line.atomCount) break;
				cx = line.getAtomBounds(l).x;
				if (cx > p.x - line.x) break;
				
				++i;
			}
			
			return i;
		}
		
		public function getPointForIndex($index:int):Point
		{
			var t:int = getTimer();
			var pos:int;
			var lastNL:int = 0;
			var index:int = $index;
			
			// give up providing proper value for these indeces
			if (index < firstPos) return new Point(cursor.x, -boxHeight);
			if (index > lastPos) return new Point(cursor.x, boxHeight * (1 + visibleRows) + 2);
			
			var lines:int = 0;
			pos = firstPos;
			
			while (true)
			{
				pos = _text.indexOf(NL, pos) + 1;
				if (pos == 0 || pos > index) break;
				lines++;
				lastNL = pos;
			}
			var ypos:int = lines * boxHeight + 2;
			var xpos:int = cursor.x;
			var i:int = 0;
			var textLine:TextLine;
			var rect:Rectangle;
			i = 0;
			textLine = _block.firstLine;
			while (textLine && i++ < lines) textLine = textLine.nextLine;
			index = _text.lastIndexOf(NL, $index - 1) + 1;
			index = $index - index;
			if (lines >= 0 && textLine && index < textLine.atomCount) {
				xpos = textLine.getAtomBounds(index).x + textLine.x;
			} else if ($index == _text.length) {
				if ( textLine) {
					var atomCount:int = index - 1;
					atomCount = (atomCount >= textLine.atomCount) ? (textLine.atomCount) - 1 : atomCount;
					atomCount = (atomCount < 0) ? 0 : atomCount;
					rect = textLine.getAtomBounds(atomCount);
					xpos = rect.x + rect.width + textLine.x;
				}
			} else {
				if (lines > 0) {
					ypos = boxHeight * (visibleRows + 1);
				}
			}
			
			return new Point(xpos, ypos);
		}
		
		public function highlightChar($index:int):void {
			if ($index >= _text.length - 2 || $index < 0) return;
			
			var p0:Point = getPointForIndex($index);
			var p1:Point = getPointForIndex($index + 1);
			
			_charHighlight.highlight(p0.x, p0.y, p1.x - p0.x, boxHeight);
			
			addChild(_charHighlight);
		}
		
		public function set scrollH(value:int):void {
			if (_scrollH == value) return;
			
			var delta:int = value - _scrollH;
			_scrollH = value;
			_container.x = - boxWidth * value;
			
			dispatchEvent(
				new ScrollEvent(
					ScrollEvent.SCROLL, false, false, null,
					value, ScrollEventDirection.HORIZONTAL, delta
				)
			);
		}
		
		public function get scrollH():int { return _scrollH; }
		
		public function get numLines():int { return _numLines; }
		
		public function get maxScrollH():int { return _maxScrollH; }
		
		public function get maxWidth():int { return _maxWidth; }
		
		we_internal function set igonoreCursor(value:Boolean):void 
		{
			_igonoreCursor = value;
		}

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
			we_internal::__replaceText(0, 0, '');
		}
		
		
		public function findPreviousMatch($left:String, $right:String, $index:int):int {
			var i:int = 1, j:int = $index;
			var lastRightOne:int;
			var lastLeftOne:int;
			
			while (i > 0) {
				lastLeftOne = _text.lastIndexOf($left, j - 1);
				lastRightOne = _text.lastIndexOf($right, j - 1);
				i += (lastRightOne > lastLeftOne) ? 1 : -1;
				j = (lastLeftOne > lastRightOne) ? lastLeftOne : lastRightOne;
			}
			
			highlightChar(lastLeftOne);
			
			return lastLeftOne;
		}
	}
}