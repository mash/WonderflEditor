package net.wonderfl.editor.manager 
{
	import net.wonderfl.editor.we_internal;
	import net.wonderfl.editor.core.FTETextField;
	import net.wonderfl.editor.operations.ReplaceText;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class HistoryManager
	{
		private static const MAX_LENGTH:int = 100 * (1 << 20);
		private static var _this:HistoryManager;
		private static const REDO:String = '_redoStack';
		private static const UNDO:String = '_undoStack';
		private var _totalTextSize:int = 0;
		private var _undoStack:ReplaceText = null;
		private var _redoStack:ReplaceText = null;
		private var _field:FTETextField;
		
		public function HistoryManager($field:FTETextField):void {
			_field = $field;
			_this = this;
		}
		
		public static function getInstance():HistoryManager { return _this; }
		
		public function pushReplaceOperation($startIndex:int, $endIndex:int, $text:String):void {
			var undo:ReplaceText = new ReplaceText($startIndex, $startIndex + $text.length, _field.text.substring($startIndex, $endIndex));
			if (_undoStack) {
				_undoStack.next = undo;
			}
			undo.prev = _undoStack;
			_undoStack = undo;
			
			// clear redo stack
			var next:ReplaceText;
			for (var replace:ReplaceText = _redoStack; replace; replace = next) {
				next = replace.next;
				if (next) next.prev = null;
				replace.next = null;
				replace = null;
			}
			_redoStack = null;
		}
		
		public function redo():void {
			applyOperation(REDO, UNDO);
		}
		
		public function undo():void {
			applyOperation(UNDO, REDO);
		}
		
		private function applyOperation($operationStackName:String, $inverseStackName:String):void {
			if (this[$operationStackName] == null) return;
			
			// push inverse operation stack
			var operation:ReplaceText = calcInverseOperation(this[$operationStackName]);
			operation.prev = this[$inverseStackName];
			if (this[$inverseStackName]) this[$inverseStackName].next = operation;
			this[$inverseStackName] = operation;
			
			// apply operation
			operation = this[$operationStackName];
			var end:int = operation.startIndex + operation.text.length;
			_field.we_internal::__replaceText(operation.startIndex, operation.endIndex, operation.text);
			_field.setSelection(end, end);
			
			// pop operation stack
			operation = this[$operationStackName].prev;
			this[$operationStackName].prev = null;
			if (operation) operation.next = null;
			this[$operationStackName] = operation;
		}
		
		private function calcInverseOperation($operation:ReplaceText):ReplaceText {
			return new ReplaceText(
				$operation.startIndex, $operation.startIndex + $operation.text.length,
				_field.text.substring($operation.startIndex, $operation.endIndex)
			);
		}
		
		public function get undoStack():ReplaceText { return _undoStack; }
		public function get redoStack():ReplaceText { return _redoStack; }
	}

}
