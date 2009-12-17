package jp.psyark 
{
import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.net.FileReference;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import flash.ui.Keyboard;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

/**
 * TextEditorクラス
 */
class TextEditor extends TextEditorBase {
	private var highlightAllTimer:int;
	
	/**
	 * コンストラクタ
	 */
	public function TextEditor() {
		comparator = new StringComparator();
		historyManager = new HistoryManager();
		syntaxHighlighter = new SyntaxHighlighter(this);
		
		contextMenu = createDebugMenu();
		
		addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		addEventListener(Event.CHANGE, function (event:Event):void {
			clearTimeout(highlightAllTimer);
			highlightAllTimer = setTimeout(highlightAll, 1000);
		});
	}
	
	private function highlightAll():void {
		syntaxHighlighter.update(0, text.length);
	}
	
	
	private function createDebugMenu():ContextMenu {
		var menu:ContextMenu = new ContextMenu();
		menu.hideBuiltInItems();
		createMenuItem("ファイルを開く(&O)...", open);
		createMenuItem("ファイルを保存(&S)...", save);
		createMenuItem("元に戻す(&Z)", undo, function ():Boolean { return historyManager.canBack; }, true);
		createMenuItem("やり直し(&Y)", redo, function ():Boolean { return historyManager.canForward; });
		createMenuItem("文字サイズ : &64", function ():void { setFontSize(64); }, null, true);
		createMenuItem("文字サイズ : &48", function ():void { setFontSize(48); });
		createMenuItem("文字サイズ : &32", function ():void { setFontSize(32); });
		createMenuItem("文字サイズ : &24", function ():void { setFontSize(24); });
		createMenuItem("文字サイズ : &13", function ():void { setFontSize(13); });
		return menu;
		
		function createMenuItem(caption:String, func:Function, enabler:Function=null, separator:Boolean=false):void {
			var item:ContextMenuItem = new ContextMenuItem(caption, separator);
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function (event:ContextMenuEvent):void {
				func();
			});
			if (enabler != null) {
				menu.addEventListener(ContextMenuEvent.MENU_SELECT, function (event:ContextMenuEvent):void {
					item.enabled = enabler();
				});
			}
			menu.customItems.push(item);
		}
	}
	
	
	/**
	 * 履歴を消去
	 */
	public function clearHistory():void {
		historyManager.clear();
		prevText = text;
	}
	
	
	/**
	 * キー押下イベントハンドラ
	 */
	private function keyDownHandler(event:KeyboardEvent):void {
		preventFollowingTextInput = false;
		
		// Ctrl+O : ファイルを開く
		if (event.charCode == "o".charCodeAt(0) && event.ctrlKey) {
			open();
			event.preventDefault();
			preventFollowingTextInput = true;
			prevSBI = selectionBeginIndex;
			prevSEI = selectionEndIndex;
			return;
		}
		
		// Ctrl+S : ファイルを保存
		if (event.charCode == "s".charCodeAt(0) && event.ctrlKey) {
			save();
			event.preventDefault();
			preventFollowingTextInput = true;
			prevSBI = selectionBeginIndex;
			prevSEI = selectionEndIndex;
			return;
		}
		
		// Ctrl+Space : コードヒントを表示
		if (event.keyCode == Keyboard.SPACE && event.ctrlKey) {
			activateCodeHint();
			event.preventDefault();
			preventFollowingTextInput = true;
			prevSBI = selectionBeginIndex;
			prevSEI = selectionEndIndex;
			return;
		}
		
		// Ctrl+Backspace : 文字グループを前方消去
		if (event.keyCode == Keyboard.BACKSPACE && event.ctrlKey) {
			deleteGroupBack();
			event.preventDefault();
			preventFollowingTextInput = true;
			prevSBI = selectionBeginIndex;
			prevSEI = selectionEndIndex;
			return;
		}
		
		// Tab : タブ挿入とインデント
		if (event.keyCode == Keyboard.TAB) {
			doTab(event);
			return;
		}
		
		// Enter : 自動インデント
		if (event.keyCode == Keyboard.ENTER) {
			doEnter(event);
			return;
		}
		
		// } : 自動アンインデント
		if (event.charCode == 125) {
			doRightbrace(event);
			return;
		}
		
		// Ctrl+Z : UNDO
		if (event.keyCode == 90 && event.ctrlKey) {
			undo();
			event.preventDefault();
			preventFollowingTextInput = true;
			prevSBI = selectionBeginIndex;
			prevSEI = selectionEndIndex;
			return;
		}
		
		// Ctrl+Y : REDO
		if (event.keyCode == 89 && event.ctrlKey) {
			redo();
			event.preventDefault();
			preventFollowingTextInput = true;
			prevSBI = selectionBeginIndex;
			prevSEI = selectionEndIndex;
			return;
		}
		
		// コードヒント起動
		if (event.charCode == 58 || event.charCode == 32) {
			callLater(activateCodeHint, [true]);
		}
	}
	
	
	/**
	 * 同じ文字グループを前方消去
	 */
	private function deleteGroupBack():void {
		if (selectionBeginIndex != selectionEndIndex) {
			// 範囲選択中なら、範囲を削除
			replaceSelectedText("");
			dispatchChangeEvent();
		} else if (selectionBeginIndex == 0) {
			// カーソル位置が先頭なら、何もしない
		} else {
			var len:int;
			var c:String = text.charAt(selectionBeginIndex - 1);
			if (c == "\r" || c == "\n") {
				// 改行の直後なら、それを消去
				len = 1;
			} else {
				// それ以外なら、同じ文字グループ（単語構成文字・空白・それ以外）を前方消去
				var match:Array = beforeSelection.match(/(?:\w+|[ \t]+|[^\w \t\r\n]+)$/i);
				len = match[0].length;
			}
			var newIndex:int = selectionBeginIndex - len;
			replaceText(selectionBeginIndex - len, selectionEndIndex, "");
			setSelection(newIndex, newIndex);
			dispatchChangeEvent();
		}
	}
	
	
	
	
	/**
	 * Tab : タブ挿入とインデント
	 */
	private function doTab(event:KeyboardEvent):void {
		if (selectionBeginIndex != selectionEndIndex) {
			var b:int, e:int, c:String;
			for (b=selectionBeginIndex; b>0; b--) {
				c = text.charAt(b - 1);
				if (c == "\r" || c == "\n") {
					break;
				}
			}
			for (e=selectionEndIndex; e<text.length; e++) {
				c = text.charAt(e);
				if (c == "\r" || c == "\n") {
					break;
				}
			}
			var replacement:String = text.substring(b, e);
			if (event.shiftKey) {
				replacement = replacement.replace(/^\t/mg, "");
			} else {
				replacement = replacement.replace(/^(.?)/mg, "\t$1");
			}
			replaceText(b, e, replacement);
			setSelection(b, b + replacement.length);
			dispatchChangeEvent();
			event.preventDefault();
			preventFollowingTextInput = true;
		} else {
			// 選択してなければタブ挿入
			replaceSelectedText("\t");
			setSelection(selectionEndIndex, selectionEndIndex);
			dispatchChangeEvent();
			event.preventDefault();
			preventFollowingTextInput = true;
		}
	}
	
	/**
	 * Enter : 自動インデント
	 */
	private function doEnter(event:KeyboardEvent):void {
		var before:String = beforeSelection;
		var match:Array = before.match(/(?:^|\n|\r)([ \t]*).*$/);
		var ins:String = "\n" + match[1];
		if (before.charAt(before.length - 1) == "{") {
			ins += "\t";
		}
		replaceSelectedText(ins);
		setSelection(selectionEndIndex, selectionEndIndex);
		dispatchChangeEvent();
		event.preventDefault();
		preventFollowingTextInput = true;
	}
	
	/**
	 * } : 自動アンインデント
	 */
	private function doRightbrace(event:KeyboardEvent):void {
		var match:Array = beforeSelection.match(/[\r\n]([ \t]*)$/);
		if (match) {
			var preCursorWhite:String = match[1];
			var nest:int = 1;
			for (var i:int=selectionBeginIndex-1; i>=0; i--) {
				var c:String = text.charAt(i);
				if (c == "{") {
					nest--;
					if (nest == 0) {
						match = text.substr(0, i).match(/(?:^|[\r\n])([ \t]*)[^\r\n]*$/);
						var replaceWhite:String = match ? match[1] : "";
						replaceText(
							selectionBeginIndex - preCursorWhite.length,
							selectionEndIndex,
							replaceWhite + "}"
						);
						dispatchChangeEvent();
						event.preventDefault();
						preventFollowingTextInput = true;
						break;
					}
				} else if (c == "}") {
					nest++;
				}
			}
		}
	}
	
	/**
	 * 元に戻す
	 */
	public function undo():void {
		if (historyManager.canBack) {
			var entry:HistoryEntry = historyManager.back();
			replaceText(entry.index, entry.index + entry.newText.length, entry.oldText);
			setSelection(entry.index + entry.oldText.length, entry.index + entry.oldText.length);
			dispatchIgnorableChangeEvent();
		}
	}
	
	/**
	 * やり直し
	 */
	public function redo():void {
		if (historyManager.canForward) {
			var entry:HistoryEntry = historyManager.forward();
			replaceText(entry.index, entry.index + entry.oldText.length, entry.newText);
			setSelection(entry.index + entry.newText.length, entry.index + entry.newText.length);
			dispatchIgnorableChangeEvent();
		}
	}
	
	/**
	 * 選択範囲の前の文字列
	 */
	private function get beforeSelection():String {
		return text.substr(0, selectionBeginIndex);
	}
}

}