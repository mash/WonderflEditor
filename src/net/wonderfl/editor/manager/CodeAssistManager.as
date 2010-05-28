/* license section
The code of this class is mostly taken from the
Flash MiniBuilder's 

ro.minibuilder.main.editor.AssisMenu

all the changes can be seen as git log.

May, 2010
Taro KOBAYASHI

The Flash MiniBuilder's license goes like following : 

Flash MiniBuilder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Flash MiniBuilder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.


Author: Victor Dramba
2009
*/


package net.wonderfl.editor.manager
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	import net.wonderfl.editor.core.UIFTETextInput;
	import net.wonderfl.editor.minibuilder.ASParserController;
	import net.wonderfl.editor.ui.PopupMenu;
	import net.wonderfl.editor.ui.ToolTip;
	import ro.victordramba.util.vectorToArray;
	
	
	public class CodeAssistManager implements IKeyboadEventManager
	{
		private var menuData:Vector.<String>
		private var fld:UIFTETextInput;
		private var menu:PopupMenu;
		private var ctrl:ASParserController;
		private var onComplete:Function;
		private var stage:Stage;
		
		private var menuStr:String;
		
		private var menuRefY:int;
		private var tooltip:ToolTip;
		private var tooltipCaret:int;
		private var _imeMode:Boolean;
		private var _menuActive:Boolean;
		
		public function CodeAssistManager(field:UIFTETextInput, ctrl:ASParserController, stage:Stage, onComplete:Function)
		{
			fld = field;
			this.ctrl = ctrl;
			this.onComplete = onComplete;
			this.stage = stage;

			menu = new PopupMenu;
			//restore the focus to the textfield, delayed			
			menu.addEventListener(Event.REMOVED_FROM_STAGE, onMenuRemoved);
			//menu in action
			//menu.addEventListener(KeyboardEvent.KEY_DOWN, onMenuKey);
			
			tooltip = new ToolTip;
			fld.addChild(tooltip);
		}
		
		private function filterMenu():Boolean
		{
			var a:Array = vectorToArray(menuData.filter(menuFilterCallback));

			if (a.length == 0) return false;
			menu.setListData(a);
			menu.selectedIndex = 0;
		
			rePositionMenu();
			return true;
		}
		
		private function menuFilterCallback($item:String, $index:int, $vec:Vector.<String>):Boolean {
			return (new RegExp('^' + menuStr.split('').join('.*'), 'i')).test($item);
		}
		
		
		private function checkAddImports(name:String):void
		{
			var caret:int = fld.caretIndex;
			if (!ctrl.isInScope(name, caret-name.length))
			{
				var missing:Vector.<String> = ctrl.getMissingImports(name, caret-name.length);
				if (missing)
				{
					var sumChars:int = 0;
					for (var i:int=0; i<missing.length; i++)
					{
						//TODO make a better regexp
						var pos:int = fld.text.lastIndexOf('package ', fld.caretIndex);
						pos = fld.text.indexOf('{', pos) + 1;
						var imp:String = '\r    '+(i>0?'//':'')+'import '+missing[i] + '.' + name + ';';
						sumChars += imp.length;
						fld.replaceText(pos, pos, imp);
					}
					fld.setSelection(caret + sumChars, caret + sumChars);
					fld.parent.dispatchEvent(new Event(Event.CHANGE));
				}
			}
		}
		
		private function fldReplaceText(begin:int, end:int, text:String):void
		{
			//var scrl:int = fld.scrollV;
			fld.replaceText(begin, end, text);
			fld.setSelection(begin+text.length, begin+text.length);
			//fld.scrollV = scrl;
		}
		
		private function onMenuRemoved(e:Event):void
		{
			setTimeout(function():void {
				stage.focus = fld;
			}, 1);
		}
		
		public function triggerAssist():void
		{
			_menuActive = true;
			var pos:int = fld.caretIndex;
			//look back for last trigger
			var tmp:String = fld.text.substring(Math.max(0, pos-100), pos).split('').reverse().join('');
			var m:Array = tmp.match(/^(\w*?)\s*(\:|\.|\(|\bsa\b|\bwen\b)/);
			debug('trigger mat='+(m?m[0]:'')+' 100='+tmp);
			var trigger:String = m ? m[2] : '';
			if (tooltip.isShowing() && trigger=='(') trigger = '';
			if (m) menuStr = m[1];
			else
			{
				m = tmp.match(/^(\w*)\b/);
				menuStr = m ? m[1] : '';
			}
			menuStr = menuStr.split('').reverse().join('')
			pos -= menuStr.length + 1;
			
			debug('trigger:'+trigger);
			debug('str='+menuStr);
			
			menuData = null;
			var rt:String = trigger.split('').reverse().join('');
			if (rt == 'new' || rt == 'as' || rt == 'is' || rt == ':' || rt == 'extends' || rt == 'implements')
				menuData = ctrl.getTypeOptions();
			else if (trigger == '.')
				menuData = ctrl.getMemberList(pos);
			else if (trigger == '')
				menuData = ctrl.getAllOptions(pos);
			else if (trigger == '(')
			{
				var fd:String = ctrl.getFunctionDetails(pos);
				if (fd)
				{
					tooltip.setTipText(fd);
					var p:Point = fld.getPointForIndex(fld.caretIndex-1);
					p = fld.localToGlobal(p);
					tooltip.showToolTip();
					tooltip.moveLocationRelatedTo(p.x, p.y);
					tooltipCaret = fld.caretIndex;
					return;
				}
			}
				
			if (!menuData || menuData.length == 0) {
				_menuActive = false;
				return;
			}
			
			showMenu(pos);			
			if (menuStr.length) filterMenu();
		}
		
		private function showMenu(index:int):void
		{
			debug(this, 'showMenu', index);
			var p:Point;
			menu.setListData(vectorToArray(menuData));
			menu.selectedIndex = 0;
			
			
			p = fld.cursorPosition;
			menu.show(fld, p.x, p.y + fld.boxHeight);
			//stage.focus = menu;
			
			rePositionMenu();
		}
		
		private function rePositionMenu():void
		{
			var p:Point = fld.cursorPosition;
			menu.show(fld, p.x, p.y + fld.boxHeight);
		}
		
		private function debug(...args):void {
			CONFIG::debug { trace('  CodeAssistManager :: ' + args); }
		}
		
		/* INTERFACE net.wonderfl.editor.manager.IKeyboadEventManager */
		
		public function get imeMode():Boolean
		{
			return _imeMode;
		}
		
		public function keyDownHandler($event:KeyboardEvent):Boolean
		{
			_imeMode = false;
			if (tooltip.isShowing())
			{
				if ($event.keyCode == Keyboard.ESCAPE || $event.keyCode == Keyboard.UP || $event.keyCode == Keyboard.DOWN || 
					String.fromCharCode($event.charCode) == ')' || fld.caretIndex < tooltipCaret)
					tooltip.disposeToolTip();
			}
			
			if (String.fromCharCode($event.keyCode) == ' ' && $event.ctrlKey)
			{
				triggerAssist();
			}
			
			if (_menuActive) {
				return onMenuKey($event);
			}
			
			return false;
		}
		
		private function onMenuKey($event:KeyboardEvent):Boolean
		{
			var res:Boolean = true;
			if ($event.charCode != 0)
			{
				var c:int = fld.caretIndex;
				if ($event.ctrlKey)
				{
					debug('onMenuKey : CTRL + ' + String.fromCharCode($event.charCode));
					switch (String.fromCharCode($event.charCode)) {
					case 'n' :
						menu.selectedIndex++;
						return true;
					case 'p' :
						menu.selectedIndex--;
						return true;
					default :
						break;
					}
				}
				else if ($event.keyCode == Keyboard.BACKSPACE)
				{
					//fldReplaceText(c-1, c, '');
					if (menuStr.length > 0)
					{
						menuStr = menuStr.substr(0, -1);
						if (filterMenu()) return false;
					} else {
						_menuActive = false;
					}
				}
				else if ($event.keyCode == Keyboard.DELETE || $event.keyCode == Keyboard.ESCAPE)
				{
					//fldReplaceText(c, c+1, '');
					_menuActive = false;
					res = false;
				}
				else if ($event.charCode > 31 && $event.charCode < 127)
				{
					var ch:String = String.fromCharCode($event.charCode);
					menuStr += ch.toLowerCase();
					//fldReplaceText(c, c, ch);
					if (filterMenu()) return true;
				}
				else if ($event.keyCode == Keyboard.ENTER || $event.keyCode == Keyboard.TAB)
				{
					fldReplaceText(c - menuStr.length, c, menu.getSelectedValue());
					checkAddImports(menu.getSelectedValue());
					fld.preventFollowingTextInput();
					_menuActive = false;
					onComplete();
				} else
					res = false;
					
				menu.dispose();
			} else {
				switch ($event.keyCode) {
				case Keyboard.DOWN:
					menu.selectedIndex++;
					break;
				case Keyboard.UP:
					menu.selectedIndex--;
					break;
				default:
					res = false;
					break;
				}
			}
			
			return res;
		}

	}
}