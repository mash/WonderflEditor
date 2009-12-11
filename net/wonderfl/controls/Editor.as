package net.wonderfl.controls
{

//package jp.psyark.psycode.core 
//{
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.TextEvent;
import flash.geom.Rectangle;
import flash.ui.Keyboard;

//import jp.psyark.psycode.codehint.CodeHint;
import jp.psyark.utils.StringComparator;
import jp.psyark.psycode.core.history.*;
import jp.psyark.psycode.core.psycode_internal;
import jp.psyark.psycode.core.TextEditUI;
//import jp.psyark.psycode.core.coloring.SyntaxHighlighter;

/**
 * @private
 * TextEditorBaseクラスはTextEditUIクラスを継承し、
 * キーイベントのキャンセルなどテキストエディタの実装に必要な機能を提供します。
 */
public class Editor extends TextEditUI {
	//private var codeHint:CodeHint;
	
	protected var preventFollowingTextInput:Boolean = false;
	protected var prevText:String = "";
	protected var prevSBI:int;
	protected var prevSEI:int;
	
	protected var ignoreChange:Boolean = false;
	protected var comparator:StringComparator;
	protected var historyManager:HistoryManager;
	
	/**
	 * TextEditorBaseクラスのインスタンスを作成します。
	 */
	public function Editor() {
		comparator = new StringComparator;
		historyManager = new HistoryManager;
		
		addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		addEventListener(Event.CHANGE, changeHandler);
		addEventListener(TextEvent.TEXT_INPUT, textInputHandler);
	}
	
	
	/**
	 * 次のテキスト入力をキャンセルするように、現在の状態を保存します。
	 */
	psycode_internal function preventNextTextInput():void {
		
	}
	
	
	/**
	 * テキストが変更された
	 */
	private function changeHandler(event:Event):void {
		//trace("change", "changed=" + (prevText != text), "ignore=" + ignoreChange, "prevent=" + preventFollowingTextInput);
		//trace("{" + escapeText(prevText) + "} => {" + escapeText(text) + "}");
		if (prevText != text) {
			if (preventFollowingTextInput) {
				comparator.compare(prevText, text);
				replaceText(
					comparator.commonPrefixLength,
					text.length - comparator.commonSuffixLength,
					prevText.substring(comparator.commonPrefixLength, prevText.length - comparator.commonSuffixLength)
				);
				setSelection(prevSBI, prevSEI);
				preventFollowingTextInput = false;
			} else {
				comparator.compare(prevText, text);
				if (!ignoreChange) {
					var entry:HistoryEntry = new HistoryEntry(comparator.commonPrefixLength);
					entry.oldText = prevText.substring(comparator.commonPrefixLength, prevText.length - comparator.commonSuffixLength);
					entry.newText = text.substring(comparator.commonPrefixLength, text.length - comparator.commonSuffixLength);
					historyManager.appendEntry(entry);
				}
				//callLater(syntaxHighlighter.update, [comparator.commonPrefixLength, text.length - comparator.commonSuffixLength]);
				prevText = text;
			}
		}
	}
	
	
	/**
	 * テキストが入力された
	 */
	private function textInputHandler(event:TextEvent):void {
		if (preventFollowingTextInput) {
			event.preventDefault();
		}
	}
	
	
	/**
	 * 履歴追加の際、自分が無視できる変更イベントを送信
	 */
	protected function dispatchIgnorableChangeEvent():void {
		ignoreChange = true;
		dispatchChangeEvent();
		ignoreChange = false; 
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
		//if (event.keyCode == Keyboard.SPACE && event.ctrlKey) {
			//activateCodeHint();
			//event.preventDefault();
			//preventFollowingTextInput = true;
			//prevSBI = selectionBeginIndex;
			//prevSEI = selectionEndIndex;
			//return;
		//}
		
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
			trace("Ctrl+Z");
			undo();
			event.preventDefault();
			preventFollowingTextInput = true;
			prevSBI = selectionBeginIndex;
			prevSEI = selectionEndIndex;
			return;
		}
		
		// Ctrl+Y : REDO
		if (event.keyCode == 89 && event.ctrlKey) {
			trace("Ctrl+Y");
			redo();
			event.preventDefault();
			preventFollowingTextInput = true;
			prevSBI = selectionBeginIndex;
			prevSEI = selectionEndIndex;
			return;
		}
		
		// コードヒント起動
		//if (event.charCode == 58 || event.charCode == 32) {
			//callLater(activateCodeHint, [true]);
		//}
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
