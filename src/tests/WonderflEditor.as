package tests 
{
	import net.wonderfl.editor.core.UIComponent;
	import net.wonderfl.editor.error.ErrorMessage;
	
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class WonderflEditor extends UIComponent
	{
		private var _errors:Array = [];
		
		
		public function WonderflEditor() 
		{
			
		}
		
		public function clearErrors():void {
			_errors.length = 0;
			setErrorPositions([]);
			//draw();
			
		}
		
		public function setFontSize($size:int):void {
			
		}
		
		private function setErrorPositions($errors:Array):void
		{
			
		}
		
		public function setError($row:int, $col:int, $message:String):void {
			_errors.push(new ErrorMessage([$row, $col, $message]));
			
			// draw error positions
			setErrorPositions(_errors.map(
				function ($error:ErrorMessage, $index:int, $array:Array):int {
					return $error.row;
				}
			));
			
			draw();
		}
		
		private function draw():void
		{
			
		}
		override protected function updateSize():void 
		{
			
		}
		
		public function get text():String {
			return '';
		}
		
		public function set text(value:String):void {
			
		}
	}
}