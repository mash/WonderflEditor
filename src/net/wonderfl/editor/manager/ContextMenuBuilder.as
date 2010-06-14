package net.wonderfl.editor.manager
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import net.wonderfl.editor.IEditor;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ContextMenuBuilder
	{
		private static const COPY:String = 'Copy (C-c)';
		private static const SELECT_ALL:String = 'Select All (C-a)';
		private static const SAVE:String = 'Save (C-s)';
		private static const MINI_BUILDER:String = 'MiniBuilder';
		private static var _this:ContextMenuBuilder;
		private var _editor:IEditor
		private var _menu:ContextMenu;
		
		public static function getInstance():ContextMenuBuilder { return (_this ||= new ContextMenuBuilder); }
		public function buildMenu($menuContainer:InteractiveObject, $editor:IEditor, $editable:Boolean = false):void
		{
			_menu = new ContextMenu;
			_menu.hideBuiltInItems();
			_editor = $editor;
			
			_menu.customItems = ([COPY, SELECT_ALL, SAVE, MINI_BUILDER]).map(
				function ($caption:String, $index:int, $arr:Array):ContextMenuItem {
					var item:ContextMenuItem = new ContextMenuItem($caption, $caption == MINI_BUILDER || $caption == SAVE);
					item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuItemSelected);
					
					return item;
				}
			);
			_menu.addEventListener(ContextMenuEvent.MENU_SELECT, _menuSelect);
			$menuContainer.contextMenu = _menu;
		}
		
		private function _menuSelect(e:ContextMenuEvent):void {
			_menu.customItems[0].enabled = (_editor.selectionBeginIndex != _editor.selectionEndIndex);
			_menu.customItems[1].enabled = (_editor.selectionBeginIndex > 0 || _editor.selectionEndIndex < _editor.text.length - 1);
		}
		
		private function onMenuItemSelected(e:ContextMenuEvent):void 
		{
			switch (e.currentTarget.caption) {
			case COPY :
				_editor.copy();
				break;
			case SELECT_ALL :
				_editor.selectAll();
				break;
			case SAVE : 
				_editor.saveCode();
				break;
			case MINI_BUILDER :
				navigateToURL(new URLRequest('http://code.google.com/p/minibuilder/'), '_self');
				break;
			}
		}
	}

}