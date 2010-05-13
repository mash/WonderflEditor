    package net.wonderfl.editor 
    {
    import adobe.utils.CustomActions;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextLineMetrics;
    import flash.utils.setTimeout;
    import jp.psyark.psycode.controls.UIControl;
    import jp.psyark.psycode.controls.TextScrollBar;
    import jp.psyark.psycode.controls.ScrollBar;
    import jp.psyark.utils.callLater;
    import jp.psyark.utils.convertNewlines;
    import jp.psyark.utils.CodeUtil;
    import net.wonderfl.controls.EditorScrollBar;
    import net.wonderfl.editor.LineNumberView;

    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.net.FileReference;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.ui.Keyboard;
    import flash.utils.getTimer;

    /**
     * the original version of this code is
     * 
     * jp.psyark.psycode.core.TextEditUI
     */
    [Event(name = "change", type = "flash.events.Event")]
    [Event(name = "complete", type = "flash.events.Event")]
    public class TextArea extends UIControl implements IEditor,IScriptArea {
        protected var linumField:LineNumberView;
        protected var _textField:TextField;
        protected var _text:String;
        protected var scrollBarV:EditorScrollBar;
        protected var scrollBarH:TextScrollBar;
        
        private var TAB_STOP_RATIO:Number = 2.42;

        public var fileRef:FileReference;
        private var _currentSelectionBeginIndex:int = -2;
        private var _currentSelectionEndIndex:int = -2;
        protected var _frameSprite:Sprite;
        private var _runs:Array = [];
        
        private var _selectionBeginIndex:int;
        private var _selectionEndIndex:int;
        private var _caretIndex:int;
        protected var _selectionGraphics:Graphics;
        protected var _selectionArea:Shape;
        private var _prevLength:int = 0;
        
        
        public function TextArea() {
            var tabStops:Array = [];
            for (var i:int=1; i<20; i++) {
                tabStops.push(13 * TAB_STOP_RATIO * i);
            }
            var fmt:TextFormat = new TextFormat("_typewriter", 13, 0xffffff);
            fmt.tabStops = tabStops;
            fmt.leading = 1;
            
            
            _textField = new TextField;
            _textField.multiline = true;
            _textField.background = false;
            _textField.alwaysShowSelection = false;
            _textField.defaultTextFormat = fmt;
            
            fmt.align = TextFormatAlign.RIGHT;
            fmt.color = 0x666666;
            
            linumField = new LineNumberView(this);
            linumField.setTextFormat(fmt);
            linumField.addEventListener(Event.RESIZE, linumResizeHandler);
            
            scrollBarV = new EditorScrollBar(_textField);
            scrollBarH = new TextScrollBar(_textField, ScrollBar.HORIZONTAL);
            
            _frameSprite = new Sprite;
            
            _selectionArea = new Shape;
            _selectionGraphics = _selectionArea.graphics;
            
            addChild(_selectionArea);
            addChild(_textField);
            addChild(linumField);
            addChild(_frameSprite);
            addChild(scrollBarV);
            addChild(scrollBarH);
            
            updateSize();
            
            _textField.addEventListener(Event.SCROLL, textFieldScrollHandler);
        }
        
        public function replaceText($beginIndex:int, $endIndex:int, $newText:String):void  {
            // not used
        }
        
        public function addFormatRun(beginIndex:int, endIndex:int, bold:Boolean, italic:Boolean, color:int):void
        {
            _runs.push({begin:beginIndex, end:endIndex, bold:bold, italic:italic, color:color});
        }
        
        private function htmlEscape($str:String):String {
            var c:String;
            var len:int = $str.length;
            var str:String = '';
            
			
            for (var i:int = 0; i < len; ++i) {
                c = $str.charAt(i);
                switch(c) {
                case '&':
                    c = '&amp;';
                    break;
                case '<':
                    c = '&lt;';
                    break;
                case '>':
                    c = '&gt;';
                    break;
                case '"':
                    c = '&quot;';
                    break;
                case "'":
                    c = '&apos;';
                    break;
                }
                str += c;
            }
            return str;
        }

        //public function setSelection(beginIndex:int, endIndex:int):void {
            //
        //}
            
        public function applyFormatRuns():void
        {
            var t:Number = getTimer();
            
            var slices:Array = [];
            var pos:int = 0, i:int, lastPos:int;
            var len:int = _runs.length;
            var o:Object;
            var str:String = '', line:String = '';
            var code:String = _text;
            lastPos = code.length;
            var firstPos:int = 0;
            for (i = 0; i < len; i++)
            {
                o = _runs[i];
                if (o.begin > pos) slices.push(htmlEscape(code.substring(pos, o.begin)));
                //if (o.begin > pos) line += (textField.text.substring(pos, o.begin)).freplace(/</g, '&lt;').replace(/>/g, '&gt;');
                
                str = '<font color="#'+o.color+'">' + htmlEscape(code.substring(Math.max(o.begin,firstPos), o.end)) + '</font>';
                if (o.bold) str = '<b>'+str+'</b>';
                if (o.italic) str = '<i>'+str+'</i>';
                slices.push(str);
                //line += str;
                if (o.end > lastPos)
                {
                    pos = lastPos;
                    break;
                }
                pos = o.end;
            }
            if (pos < lastPos)slices.push(htmlEscape(code.substring(pos, lastPos)));
            //if (pos < lastPos)line += textField.text.substring(pos, lastPos).replace(/</g, '&lt;').replace(/>/g, '&gt;');
            
            slices.unshift('<font color="#ffffff" face="_typewriter" size="12">');
            slices.push('</font>');
            //line = '<font color="#ffffff" face="_sans">' + line + '</font>';
            
            
                
            _textField.htmlText = slices.join('');
            
            
			linumField.updateLinePos(true);
            dispatchEvent(new Event(Event.COMPLETE));
            trace('htmlText' +  (getTimer() - t) + ' ms');
        }
        
        public function clearFormatRuns():void
        {
            _runs.length = 0;
        }
        
        public function getLineOffset(lineIndex:int):int {
            return _textField.getLineOffset(lineIndex);
        }
        
        public function open():void {
            fileRef = new FileReference();
            fileRef.addEventListener(Event.SELECT, function (event:Event):void {
                fileRef.load();
            });
            fileRef.addEventListener(Event.COMPLETE, function (event:Event):void {
                text = convertNewlines(String(fileRef.data));
            });
            fileRef.browse();
        }
        
        public function get lastLineIndex():int
        {
            return _textField.numLines - 1;
        }
        
        public function save():void {
            var localName:String = CodeUtil.getDefinitionLocalName(text);
            localName ||= "untitled";
            fileRef = new FileReference();
            fileRef.save(text, localName + ".as");
        }
        
        public function setFontSize(fontSize:Number):void {
            var tabStops:Array = [];
            for (var i:int=1; i<20; i++) {
                tabStops.push(i * fontSize * 2.42);
            }
            
            var fmt:TextFormat = _textField.defaultTextFormat;
            fmt.size = fontSize;
            fmt.tabStops = tabStops;
            _textField.defaultTextFormat = fmt;
            
            fmt.align = TextFormatAlign.RIGHT;
            fmt.color = 0x666666;
            linumField.setTextFormat(fmt);
            
            fmt = new TextFormat();
            fmt.size = fontSize;
            fmt.tabStops = tabStops;
            _textField.setTextFormat(fmt);
            
            dispatchChangeEvent();
        }
        
        
        private function textFieldScrollHandler(event:Event):void {
            dispatchEvent(event);
        }
        
        private function linumResizeHandler(event:Event):void {
            updateSize();
        }
        
        public function get lineNumWidth():int {
            return _textField.x;
        }
        public function get text():String {
            return _text;
        }
        
        public function set text(value:String):void {
            //_textField.text = value;
            _text = value;
            dispatchChangeEvent();
        }
		
		/**
		 * this method does not dispath any event
		 * @param	value
		 */
		public function setText(value:String):void {
			_text = value;
			_textField.text = value;
		}
        
        public function get scrollV():int { return _textField.scrollV; }
        public function set scrollV(value:int):void {
            _textField.scrollV = value;
        }
        public function get scrollH():int { return _textField.scrollH; }
        public function set scrollH(value:int):void {
            _textField.scrollH = value;
        }
            
        
        public function getCharBoundaries(index:int):Rectangle {
            return _textField.getCharBoundaries(index);
        }
        
        protected function dispatchChangeEvent():void {
            _textField.dispatchEvent(new Event(Event.CHANGE, true));
        }
        
        protected function draw():void {
            graphics.clear();
            graphics.beginFill(0x222222);
            graphics.drawRect(0, 0, width, height);
            
            _frameSprite.graphics.clear();
            _frameSprite.graphics.beginFill(0x222222);
            _frameSprite.graphics.drawRect(0, 0, linumField.width, scrollBarH.height);
            _frameSprite.graphics.drawRect(scrollBarH.x + scrollBarH.width, 0, scrollBarV.width, scrollBarH.height);
            _frameSprite.graphics.endFill();
        }
        
        protected override function updateSize():void {
            linumField.height = height;
            _textField.x = linumField.width;
            _textField.width = width - scrollBarV.width - linumField.width;
            _textField.height = height - scrollBarH.height;
            scrollBarV.x = width - scrollBarV.width;
            scrollBarV.height = height - scrollBarH.height;
            scrollBarV.updateView();
            scrollBarH.x = linumField.width;
            scrollBarH.y = height - scrollBarH.height;
            scrollBarH.width = width - scrollBarV.width - linumField.width;
            _frameSprite.y = scrollBarH.y;
            linumField.updateLinePos();
            draw();
        }
        
        /* INTERFACE net.wonderfl.editor.IEditor */
        
        public function get textField():TextField
        {
            return _textField;
        }
        
        public function get selectionEndIndex():int { return _selectionEndIndex; }
        public function get selectionBeginIndex():int { return _selectionBeginIndex; }
        public function get caretIndex():int { return _caretIndex; }
    }    
	}