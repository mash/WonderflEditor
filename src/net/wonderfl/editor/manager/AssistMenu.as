/* license section

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


package ro.minibuilder.main.editor
{
	import __AS3__.vec.Vector;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import org.aswing.FocusManager;
	import org.aswing.JToolTip;
	import org.aswing.geom.IntPoint;
	
	import ro.minibuilder.asparser.Controller;
	import ro.victordramba.util.vectorToArray;
	import com.victordramba.console.debug;
	
	public class AssistMenu
	{
		private var menuData:Vector.<String>
		private var fld:ScriptAreaComponent;
		private var menu:ScrollPopupMenu;
		private var ctrl:Controller;
		private var onComplete:Function;
		private var stage:Stage;
		
		private var menuStr:String;
		
		private var tooltip:JToolTip;
		private var tooltipCaret:int;
		
		public function AssistMenu(field:ScriptAreaComponent, ctrl:Controller, stage:Stage, onComplete:Function)
		{
			fld = field;
			this.ctrl = ctrl;
			this.onComplete = onComplete;
			this.stage = stage;

			menu = new ScrollPopupMenu;
			//restore the focus to the textfield, delayed			
			menu.addEventListener(Event.REMOVED_FROM_STAGE, onMenuRemoved);
			//menu in action
			menu.addEventListener(KeyboardEvent.KEY_DOWN, onMenuKey);
			/*menu.addEventListener(MouseEvent.DOUBLE_CLICK, function(e:Event):void {
				var c:int = fld.caretIndex;
				fldReplaceText(c-menuStr.length, c, menu.getSelectedValue());
				ctrl.sourceChanged(fld.text);
				menu.dispose();
			})*/
			
			tooltip = new JToolTip;
			
			//used to close the tooltip
			fld.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function filterMenu():Boolean
		{
			var a:Array = [];
			for each (var s:String in menuData)
				if (s.toLowerCase().indexOf(menuStr.toLowerCase())==0) a.push(s);

			if (a.length == 0) return false;
			menu.setListData(a);
			menu.setSelectedIndex(0);
			
			rePositionMenu();
			return true;
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (tooltip.isShowing())
			{
				if (e.keyCode == Keyboard.ESCAPE || e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN || 
					String.fromCharCode(e.charCode) == ')' || fld.caretIndex < tooltipCaret)
					tooltip.disposeToolTip();
			}
			
			if (String.fromCharCode(e.keyCode) == ' ' && e.ctrlKey)
			{
				/*menuData = ctrl.getAllOptions();
				if (menuData && menuData.length)
					showMenu(fld.caretIndex);*/
				triggerAssist();
			}
		}
		
		private function onMenuKey(e:KeyboardEvent):void
		{
			if (e.charCode != 0)
			{
				var c:int = fld.caretIndex;
				if (e.ctrlKey)
				{
					
				}
				else if (e.keyCode == Keyboard.BACKSPACE)
				{
					fldReplaceText(c-1, c, '');
					if (menuStr.length > 0)
					{
						menuStr = menuStr.substr(0, -1);
						if (filterMenu()) return;
					}
				}
				else if (e.keyCode == Keyboard.DELETE)
				{
					fldReplaceText(c, c+1, '');
				}
				else if (e.charCode > 31 && e.charCode < 127)
				{
					var ch:String = String.fromCharCode(e.charCode);
					menuStr += ch.toLowerCase();
					fldReplaceText(c, c, ch);
					if (filterMenu()) return;
				}
				else if (e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.TAB)
				{
					fldReplaceText(c-menuStr.length, c, menu.getSelectedValue());
					checkAddImports(menu.getSelectedValue());
					onComplete();
				}
				menu.dispose();
			}
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
						var imp:String = '\n\t'+(i>0?'//':'')+'import '+missing[i] + '.' + name + ';';
						sumChars += imp.length;
						fld.replaceText(pos, pos, imp);
					}
					fld.setSelection(caret+sumChars, caret+sumChars);
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
				//???
				FocusManager.getManager(stage).setFocusOwner(fld);
			}, 1);
		}
		
		public function triggerAssist():void
		{
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
			
			//debug('trigger:'+trigger);
			//debug('str='+menuStr);
			
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
					tooltip.moveLocationRelatedTo(new IntPoint(p.x, p.y));
					tooltipCaret = fld.caretIndex;
					return;
				}
			}
				
			if (!menuData || menuData.length==0) return;
			
			showMenu(pos+1);			
			if (menuStr.length) filterMenu();
		}

		private var menuRefY:int;
		
		private function showMenu(index:int):void
		{
			var p:Point;
			menu.setListData(vectorToArray(menuData));
			menu.setSelectedIndex(0);
			
			p = fld.getPointForIndex(index);
			p.x += fld.scrollH;
			
			p = fld.localToGlobal(p);
			menuRefY = p.y;
			
			//menu.show(stage, p.x, p.y + 15);
			menu.show(stage, p.x, 0);
			
			stage.focus = menu;
			FocusManager.getManager(stage).setFocusOwner(menu);
			
			rePositionMenu();
		}
		
		private function rePositionMenu():void
		{
			var menuH:int = Math.min(8, menu.getModel().getSize()) * 17;
			if (menuRefY +15 + menuH > stage.stageHeight)
				menu.setY(menuRefY - menuH - 2);
			else
				menu.setY(menuRefY + 15);
		}

	}
}