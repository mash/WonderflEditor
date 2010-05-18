package ro.victordramba.scriptarea
{
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class ScriptArea extends Base
	{
		
		private var tf:TextField;
		//private var _text:String;
		internal var _caret:int;
		internal var _selStart:int = 0;
		internal var _selEnd:int = 0;
		protected var cursor:ScriptCursor;
		
		protected var _text:String = '';
		
		private var boxHeight:int;
		private var boxWidth:int;
		
		private var _scrollY:int = 0;
		private var firstPos:int = 0;
		private var lastPos:int = 0;
		private var _maxscroll:int = 0;
		
		private var selectionShape:Shape;
		
		protected var visibleRows:int;
		
		static protected var NL:String = '\r';
		
		private var undoBuff:Array = [];
		private var redoBuff:Array = [];
		
		//format. very simplified
		private var runs:Array = [];
		
		private var fmt:TextFormat;
		
		public function ScriptArea()
		{
			mouseChildren = false;
			mouseEnabled = true;
			buttonMode = true;
			useHandCursor = false;

			selectionShape = new Shape;
			addChild(selectionShape);
			
			tf = new TextField;
			tf.multiline = true;
			tf.wordWrap = false;
			
			
			fmt = new TextFormat('Courier New', 14, 0);
			for each (var fnt:Font in Font.enumerateFonts(true))
				if (fnt.fontName == 'Liberation Mono')
				{
					fmt.font = fnt.fontName;
					fmt.size = 13;
					break;
				}
			tf.defaultTextFormat = fmt;
			
			
			tf.text = ' ';
			boxHeight = tf.getLineMetrics(0).height;
			boxWidth = tf.getLineMetrics(0).width;
			tf.text = '';
			
			addChild(tf);
			
			cursor = new ScriptCursor;
			cursor.visible = false;
			cursor.x = tf.x;
			cursor.y = tf.y;
			ScriptCursor.height = boxHeight;
			addChild(cursor);
		}
		
		public function get textFormat():TextFormat
		{
			return fmt;
		}
		
		public function get length():int
		{
			return _text.length;
		}
		
		public function set scrollY(value:int):void
		{
			if (_scrollY == value) return;
			_scrollY = Math.min(Math.max(0, value), _maxscroll);
			updateScrollProps();
			updateCaret();
			_setSelection(_selStart, _selEnd);
			dispatchEvent(new Event(Event.SCROLL, true));
		}
		
		public function get scrollY():int
		{
			return _scrollY;
		}
		
		private function updateScrollProps():void
		{
			var i:int, pos:int;
			//compute maxscroll
			for (i=0, pos=0; pos!=-1; pos=_text.indexOf(NL, pos+1)) i++;
			_maxscroll = Math.max(0, i-visibleRows);
			
			if (_scrollY > _maxscroll)
			{
				scrollY = _maxscroll;
				return;
			}
			
			for (i = _scrollY, pos=0; i > 0; i--)
				pos = _text.indexOf(NL, pos)+1;
			firstPos = pos;
			
			for (i = visibleRows, pos=firstPos-1; i > 0; i--)
			{
				pos = _text.indexOf(NL, pos+1);
				if (pos == -1)
				{
					pos = _text.length;
					break;
				}
			}
			lastPos = pos;
			
			_replaceText(0, 0, '');
			
			//debug('maxscroll='+_maxscroll+', lastPos='+lastPos+' i='+i);
		}
		
		public function get boxSize():Point
		{
			return new Point(boxWidth, boxHeight);
		}
		
		public function get maxscroll():int
		{
			return _maxscroll;
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
			_selStart = beginIndex;
			_selEnd = endIndex;
			
			if (_selStart > _selEnd)
			{
				var tmp:int = _selEnd;
				_selEnd = _selStart;
				_selStart = tmp;
			}
			
			var p0:Point = getPointForIndex(Math.max(_selStart, firstPos));
			var p1:Point = getPointForIndex(Math.min(_selEnd, lastPos));
			var g:Graphics = selectionShape.graphics;
			g.clear();
			if (_selStart != _selEnd && _selStart <= lastPos && _selEnd >= firstPos)
			{
				g.beginFill(0x8DC846, .3);
				if (p0.y == p1.y)
					g.drawRect(p0.x, p0.y, p1.x-p0.x, boxHeight);
				else
				{
					g.drawRect(p0.x, p0.y, width-p0.x, boxHeight);
					var rows:int = (p1.y-p0.y)/boxHeight;
					for (var i:int=1; i<rows; i++)
						g.drawRect(1, p0.y+boxHeight*i, width, boxHeight);
					//if selection is past last visible pos, we draw a full line
					g.drawRect(1, p0.y+boxHeight*i, lastPos>=_selEnd ? p1.x : width, boxHeight);
				}
			}
			
			if (caret)
			{
				cursor.visible = _caret <= lastPos && _caret >= firstPos;
				_caret = endIndex;
				cursor.pauseBlink();
				cursor.setX(p1.x + tf.x);
				cursor.y = p1.y + tf.y;
				checkScrollToCursor();
			}
		}
		
		public function updateCaret():void
		{
			cursor.visible = _caret <= lastPos && _caret >= firstPos;
			cursor.pauseBlink();
			var p:Point = getPointForIndex(_caret);
			cursor.setX(p.x + tf.x);
			cursor.y = p.y + tf.y;
		}
		
		
		protected function undo():void
		{
			if (undoBuff.length == 0) return;
			var o:Object = undoBuff.pop();
			redoBuff.push({s:o.s, e:o.s+o.t.length, t:_text.substring(o.s, o.e)});
			
			_replaceText(o.s, o.e, o.t);
			_caret = o.s + o.t.length;
			_setSelection(_caret, _caret, true);
		}
		
		protected function redo():void
		{
			if (redoBuff.length == 0) return;
			var o:Object = redoBuff.pop();
			undoBuff.push({s:o.s, e:o.s+o.t.length, t:_text.substring(o.s, o.e)});
			
			_replaceText(o.s, o.e, o.t);
			_caret = o.s + o.t.length;
			_setSelection(_caret, _caret, true);
		}
		
		
		private var savedUndoIndex:int = 0;
		
		public function get changed():Boolean
		{
			return undoBuff.length != savedUndoIndex;
		}
		
		//call this when the file is saved so we know if the file is changed
		public function saved():void
		{
			savedUndoIndex = undoBuff.length;
		}
		
		public function resetUndo():void
		{
			undoBuff.length = 0;
			redoBuff.length = 0;
		}
		
		public function get text():String
		{
			return _text;
		}
		
		public function set text(str:String):void
		{
			replaceText(0, length, str);
		}
		
		
		public function replaceText(startIndex:int, endIndex:int, text:String):void
		{
			text = text.replace(/\r\n/g, NL);
			text = text.replace(/\n/g, NL);
			undoBuff.push({s:startIndex, e:startIndex+text.length, t:_text.substring(startIndex, endIndex)});
			redoBuff.length = 0;
			_replaceText(startIndex, endIndex, text);
		}
		
		private function _replaceText(startIndex:int, endIndex:int, text:String):void
		{
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
			
			function htmlEnc(str:String):String
			{
				return str.replace(/</g, '&lt;').replace(/>/g, '&gt;');
			}
			
			//apply formats
			var slices:Array = [];
			var pos:int = firstPos;
			for (i=0; i<runs.length; i++)
			{
				o = runs[i];
				if (o.begin<firstPos && o.end<firstPos) continue;
				if (o.begin>lastPos && o.end>lastPos) break;
					
				if (o.begin > pos) slices.push(htmlEnc(_text.substring(pos, o.begin)));
				var str:String = '<font color="#'+o.color+'">' + htmlEnc(_text.substring(Math.max(o.begin,firstPos), o.end)) + '</font>';
				if (o.bold) str = '<b>'+str+'</b>';
				if (o.italic) str = '<i>'+str+'</i>';
				slices.push(str);
				if (o.end > lastPos)
				{
					pos = lastPos;
					break;
				}
				pos = o.end;
			}
			if (pos < lastPos)
				slices.push(htmlEnc(_text.substring(pos, lastPos)));
				
			var visibleText:String = slices.join('');
			/*var visibleText:String = _text.substring(firstPos, lastPos);
			visibleText = visibleText.replace(/var/g, '<font color="#0000ff">var</font>');*/
			
			//simple tabs, 4 spaces, no align
			visibleText = visibleText.replace(/\t/g, '    ');
			
			tf.htmlText = visibleText;
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
			tf.width = width;
			tf.height = height;
			visibleRows = Math.floor((height-4) / boxHeight);
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
			var pos:int = 0;
			var y:int = boxHeight;
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
			}
			var cx:int = 0;
			var c:String;
			for (var i:int=pos; i<_text.length && (c=_text.charAt(i))!=NL; i++)
			{
				cx += (c=='\t' ? 4 : 1)*boxWidth;
				if (cx > p.x) break;
			}
			
			return i;
		}
		
		public function getPointForIndex(index:int):Point
		{
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
			//count tabs
			for (var i:int=lastNL, tabs:int=0; i<index; i++) if (_text.charAt(i)=='\t') tabs++;
			//simple tabs, just 4 spaces, no align
			return new Point((index-lastNL+tabs*3)*boxWidth+1, (lines-_scrollY)*boxHeight+2);
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
			_replaceText(0, 0, '');
		}
	}
}