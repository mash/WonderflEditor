package net.wonderfl.editor.ui 
{
	import flash.display.DisplayObjectContainer;
	import net.wonderfl.editor.core.UIComponent;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class PopupMenu extends UIComponent
	{
		private var _data:Array = [];
		private var _selectedIndex:int;
		
		public function PopupMenu() 
		{
			
		}
		
		public function setListData($data:Array):void {
			_data = $data;
		}
		
		public function setSelectedIndex($index:int):void {
			_selectedIndex = $index;
		}
		
		public function setY($value:int):void {
			
		}
		
		public function show($container:DisplayObjectContainer, $xpos:int, $ypos:int):void {
			
		}
		
		public function dispose():void {
			
		}
		
		public function getSelectedValue():String {
			return _data[_selectedIndex];
		}
		
		public function get data():Array { return _data; }
		
		public function set data(value:Array):void 
		{
			_data = value;
		}
		
		override protected function updateSize():void 
		{
			
			
		}
	}
}