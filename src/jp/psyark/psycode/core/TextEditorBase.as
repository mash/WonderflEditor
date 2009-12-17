package jp.psyark.psycode.core 
{
import flash.events.Event;
import flash.events.TextEvent;
import flash.geom.Rectangle;

import jp.psyark.psycode.codehint.CodeHint;
import jp.psyark.utils.StringComparator;
import jp.psyark.psycode.core.history.*;
import jp.psyark.psycode.core.coloring.SyntaxHighlighter;

/**
 * @private
 * TextEditorBaseクラスはTextEditUIクラスを継承し、
 * キーイベントのキャンセルなどテキストエディタの実装に必要な機能を提供します。
 */
public class TextEditorBase extends TextEditUI {
	private var codeHint:CodeHint;
	
	protected var preventFollowingTextInput:Boolean = false;
	protected var prevText:String = "";
	protected var prevSBI:int = 0;
	protected var prevSEI:int = 0;
	
	protected var ignoreChange:Boolean = false;
	protected var comparator:StringComparator;
	protected var historyManager:HistoryManager;
	protected var syntaxHighlighter:SyntaxHighlighter;
	
	/**
	 * TextEditorBaseクラスのインスタンスを作成します。
	 */
	public function TextEditorBase() {
		codeHint = new CodeHint(this);
		codeHint.visible = false;
		codeHint.addEventListener(Event.SELECT, codeHintSelectHandler);
		addChild(codeHint);
		
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
				callLater(syntaxHighlighter.update, [comparator.commonPrefixLength, text.length - comparator.commonSuffixLength]);
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
	 * コードヒントを起動します
	 * 現在のカーソル前のテキストから続くコードを類推し、
	 * 候補が無ければそのまま終了、
	 * 候補がひとつなら直ちに補完を行い、
	 * 候補が複数なら選択パネルを表示します。
	 */
	public function activateCodeHint(a:Boolean=false):void {
		var rect:Rectangle = getCharBoundaries(textField.caretIndex);
		if (rect) {
			var scrollIndex:int = textField.getLineOffset(textField.scrollV - 1) + textField.scrollH;
			var rect2:Rectangle = getCharBoundaries(scrollIndex);
			if (rect2) {
				rect.x -= rect2.x;
				rect.y -= rect2.y;
			}
			codeHint.x = rect.x + textField.x;
			codeHint.y = rect.bottom + 2;
		}
		codeHint.activate();
		
		function getCharBoundaries(index:int):Rectangle {
			var char:String = text.charAt(index);
			replaceText(index, index + 1, "M");
			var bound:Rectangle = textField.getCharBoundaries(index);
			replaceText(index, index + 1, char);
			return bound;
		}
	}
	
	/**
	 * コードヒントが選択された
	 */
	private function codeHintSelectHandler(event:Event):void {
		preventFollowingTextInput = false;
		var newIndex:int = textField.caretIndex - codeHint.captureLength + codeHint.selectedName.length;
		replaceText(textField.caretIndex - codeHint.captureLength, textField.caretIndex, codeHint.selectedName);
		setSelection(newIndex, newIndex);
		dispatchChangeEvent();
		
		var identifier:String = codeHint.selectedIdentifier;
		if (identifier.indexOf(":") != -1) {
			autoImport(identifier.replace(/:/, "."));
		}
	}
	
	/**
	 * インポート文の自動追加
	 */
	private function autoImport(qname:String):void {
		var regex:String = "";
		regex += "(package\\s*(?:[_a-zA-Z]\\w*(?:\\.[_a-zA-Z]\\w*)*)?\\s*{)"; // package
		regex += "(\\s*(?:import\\s*(?:[_a-zA-Z]\\w*(?:\\.[_a-zA-Z]\\w*)*(?:\\.\\*)?[\\s;]+))*$)"; // import 
		regex += "(.*?public\\s+(?:class|interface|function|namespace))"; // def
		var match:Array = text.match(new RegExp(regex, "sm"));
		if (match) {
			var importTable:Object = {};
			match[2].replace(/import\s*([_a-zA-Z]\w*(?:\.[_a-zA-Z]\w*)*(?:\.\*)?)/g, function (match:String, cap1:String, index:int, source:String):void {
				importTable[cap1] = true;
			});
			importTable[qname] = true;
			var importList:Array = [];
			for (var i:String in importTable) {
				importList.push("\timport " + i + ";");
			}
			var importStr:String = importList.sort().join("\n");
			var newStr:String = "\n" + importStr + "\n" + match[3];
			var index:int = selectionBeginIndex;
			replaceText(
				match.index + match[1].length,
				match.index + match[1].length + match[2].length + match[3].length,
				newStr
			);
			
			if (index > match.index + match[1].length) {
				var newSel:int = index + newStr.length - match[2].length - match[3].length;
				setSelection(newSel, newSel);
			}
			dispatchChangeEvent();
		}
	}
}
}