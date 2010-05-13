package net.wonderfl.editor.completion {
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

import adobe.utils.CustomActions;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextFormat;
import flash.ui.Keyboard;
import flash.utils.ByteArray;
import flash.utils.setTimeout;
import jp.psyark.utils.callLater;

import jp.psyark.psycode.core.TextEditUI;
import jp.psyark.psycode.controls.List;
import jp.psyark.psycode.core.psycode_internal;

import ro.victordramba.util.vectorToArray;

import net.wonderfl.controls.ToolTip;
import net.wonderfl.editor.ASParserController;

[Event(name = "select", type = "flash.events.Event")]
public class AutoCompletion extends Sprite {
	private var menuData:Vector.<String>
	private var fld:TextEditUI;
	private var ctrl:ASParserController;
	private var onComplete:Function;
	private var _stage:Stage;
	
	private var menuStr:String;
	
	private var _width:Number = 200;
	private var _height:Number = 280;
	
	private var background1:Sprite;
	private var background2:Sprite;
	private var list:List;
	
	private const STAGE_KEY_LISTEN_PRIORITY:int = 100;
	
	private var activated:Boolean = false;
	
	public var selectedIdentifier:String;
	public var selectedName:String;
	private var menuRefY:int;
	private var tooltip:ToolTip;
	private var tooltipCaret:int;
	public var captureLength:int;
	private const BORDER_COLOR:uint = 0x444444;
	
	public function AutoCompletion(field:TextEditUI, ctrl:ASParserController, stage:Stage, onComplete:Function) {
		fld = field;
		this.ctrl = ctrl;
		this.onComplete = onComplete;
		this._stage = stage;
		
		
		tabChildren = false;
		
		tooltip = new ToolTip;
		tooltip.width = 200;
		tooltip.height = 100;
		
		// #
		var tfm:TextFormat = new TextFormat;
		tfm.color = 0xffffff;
		tfm.size = 12;
		tooltip.textFormat = tfm;
		
		//used to close the tooltip
		fld.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		
		
		fld.addEventListener(Event.SCROLL, function (event:Event):void {
			//deactivate();
		});
		
		
		background1 = new Sprite();
		background2 = new Sprite();
		background2.filters = [new DropShadowFilter(1, 45, 0x000000, 1, 10, 10, 1.2, 2, false, true)];
		
		list = new List;
		list.labelField = "item";
		list.addEventListener(Event.CHANGE, function (event:Event):void {
			fld.psycode_internal::resetFocus();
		});
		
		addChild(tooltip);
		addChild(background1);
		addChild(background2);
		addChild(list);
		
		
		
		updateLayout();
		
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
	}
	

	
	
	private function filterMenu():Boolean
	{
		var a:Array = [];
		captureLength = menuStr.length;
		
		a = vectorToDataProvidor(menuData.filter(menuFilterCallback).sort(
			function ($a:String, $b:String):int {
				var da:int = diff($a);
				var db:int = diff($b);
				
				if (da < db)
					return -1;
				else if (da > db)
					return 1;
				else return 0;
			}
		));

		if (a.length == 0) {
			deactivate();
			return false;
		}
		list.dataProvider = a;
		list.selectedIndex = 0;
		
		rePositionMenu();
		return true;
	}
	
	private function diff($str:String):int {
		var m:String = $str.toLowerCase();
		$str = menuStr.toLowerCase();
		var dx:int = $str.length;
		var dy:int = m.length;
		var table:Array = [];
		table.length = (dx + 1) * (dy + 1);
		
		var i:int, j:int;
		
		for (i = 0; i <= dx; table[i] = i++);
		for (j = 0; j <= dy; table[j * (dx + 1)] = j++);
		
		var cost:int, u:int;
		
		u = dx + 1;
		for (i = 1; i <= dx; i++)
		{
			for (j = 1; j <= dy; j++)
			{
				cost = ($str.charAt(i - 1) != m.charAt(j - 1) ? 1 : 0);
				table[i + j * u] = Math.min(
											table[i - 1 + u * j] + 1,
											table[i + u * (j - 1)] + 1,
											table[i - 1 + u *(j - 1)] + cost);
			}
		}
		
		return table[dx + u * dy];
	}
	
	private function menuFilterCallback($item:String, $index:int, $vec:Vector.<String>):Boolean {
		return (new RegExp('^' + menuStr.split('').join('.*'), 'i')).test($item);
	}
	
	private function onKeyDown(e:KeyboardEvent):void
	{
		if (tooltip.isShowing())
		{
			//if (e.keyCode == Keyboard.ESCAPE || e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN || 
				//String.fromCharCode(e.charCode) == ')' || fld.selectionBeginIndex < tooltipCaret)
				//tooltip.deactivate();
		}
		
		if (String.fromCharCode(e.keyCode) == ' ' && e.ctrlKey)
		{
			triggerAssist();
		}
	}
	
	private function checkAddImports(name:String):void
	{
		var caret:int = fld.selectionBeginIndex;
		if (!ctrl.isInScope(name, caret-name.length))
		{
			var missing:Vector.<String> = ctrl.getMissingImports(name, caret - name.length);
			if (missing)
			{
				var sumChars:int = 0;
				for (var i:int = 0; i < missing.length; i++)
				{	
					var pos:int = fld.text.lastIndexOf('class ', fld.selectionBeginIndex) - 50;
					pos = (pos < 0) ? 0 : pos;
					var str:String = fld.text.substr(pos, 56);
					//trace(pos, str);
					var place:RegExp = /(\n?[ \t]*)(public|internal)?([ \t]*)class/s;
					var match:Array = str.match(place);
					
					if (!match) return;
					pos += match.index;
					//
					
					if (missing[i] == 'top') return;
					
					var imp:String = match[1] + (i > 0?'//':'') + 'import ' + missing[i] + '.' + name + ';\n';
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
	
	
	public function triggerAssist():void
	{
		var pos:int = fld.selectionBeginIndex;
		//look back for last trigger
		var tmp:String = fld.text.substring(Math.max(0, pos-100), pos).split('').reverse().join('');
		var m:Array = tmp.match(/^(\w*?)\s*(\:|\.|\(|\bsa\b|\bwen\b)/);
		var trigger:String = m ? m[2] : '';
		if (activated && trigger=='(') trigger = '';
		if (m) menuStr = m[1];
		else
		{
			m = tmp.match(/^(\w*)\b/);
			menuStr = m ? m[1] : '';
		}
		menuStr = menuStr.split('').reverse().join('')
		pos -= menuStr.length + 1;
		
		//trace('trigger:'+trigger);
		//trace('str='+menuStr);
		
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
				// #
				//tooltip.text = fd;
				//tooltip.show();
				//trace("tooltip:", fd);
				
				tooltipCaret = fld.selectionBeginIndex;
				return;
			}
		}
		
		
		if (!menuData || menuData.length==0) return;
		
		showMenu(pos+1);			
		if (menuStr.length) filterMenu();
	}

	
	private function showMenu(index:int):void
	{
		var p:Point;
		
		list.dataProvider = vectorToDataProvidor(menuData);
		list.selectedIndex = 0;
		
		//stage.focus = list;
		
		show();
		rePositionMenu();
	}
	
	private function vectorToDataProvidor(v:Object):Array {
		return vectorToArray(v).map(vectorToDataProvidorCallback);
	}
	
	private function vectorToDataProvidorCallback($item:String, $index:int, $array:Array):Object
	{
		return {
			item: $item
		};
	}
	
	private function rePositionMenu():void
	{
		var index:int = fld.selectionBeginIndex - 1;
		index = (index < 0) ? 0 : index;
		var rect:Rectangle = fld.getCharBoundaries(index);
		var scrollIndex:int = fld.getLineOffset(fld.scrollV - 1) + fld.scrollH;
		var rect2:Rectangle = fld.getCharBoundaries(scrollIndex);
		if (rect2) {
			rect.x -= rect2.x;
			rect.y -= rect2.y;
		}
		
		background1.x = background2.x = list.x = rect.x + fld.lineNumWidth + 20;
		background1.y = background2.y = list.y = rect.bottom + 5;
		
		list.x += 7;
		list.y += 7;
	}
	
	private function select(selectedItem:Object):void {
		selectedName = selectedItem.item;
		
		var c:int = fld.selectionBeginIndex;
		fldReplaceText(c - menuStr.length, c, selectedName);
		checkAddImports(selectedName);
		onComplete();
		
		dispatchEvent(new Event(Event.SELECT));
		deactivate();
	}
	
	public function activate():Boolean {
		if (activated) {
			return false;
		}
		
		return false;
	}
	
	private function show():void {
		visible = true;
		activated = true;
		updateLayout();
	}
	
	
	public function deactivate():void {
		visible = false;
		activated = false;
		callLater(fld.psycode_internal::resetFocus);
	}
	
	private function updateLayout():void {
		var borderWidth:Number = 7;
		
		for each (var bg:Sprite in [background1, background2]) {
			bg.graphics.clear();
			bg.graphics.lineStyle(-1, 0x666666, 0.5);
			bg.graphics.beginFill(BORDER_COLOR, 0.9);
			bg.graphics.drawRoundRect(0, 0, _width, _height, borderWidth * 2);
			bg.graphics.endFill();
			bg.graphics.drawRect(borderWidth - 1, borderWidth - 1, _width - borderWidth * 2 + 2, _height - borderWidth * 2 + 2);
		}
		

		list.width = _width - borderWidth * 2;
		list.height = _height - borderWidth * 2;
	}
	
	
	private function stageKeyDownHandler(event:KeyboardEvent):void {
		var c:int = fld.selectionBeginIndex;
		
		if (activated) {
			if (event.keyCode == Keyboard.ENTER) {
				//trace('active: enter');
				stage.focus = null;
				select(list.selectedItem);
				callLater(fld.psycode_internal::resetFocus);
				event.stopPropagation();
				event.stopImmediatePropagation();
			} else if (event.keyCode == Keyboard.DOWN) {
				stage.focus = null;
				list.selectedIndex = Math.min(list.selectedIndex + 1, list.dataProvider.length - 1);
				callLater(fld.psycode_internal::resetFocus);
				event.stopPropagation();
			} else if (event.keyCode == Keyboard.UP) {
				stage.focus = null;
				list.selectedIndex = Math.max(list.selectedIndex - 1, 0);
				callLater(fld.psycode_internal::resetFocus);
				event.stopPropagation();
			} else if (event.charCode > 31 && event.charCode < 127) {
				var ch:String = String.fromCharCode(event.charCode);
				menuStr += ch.toLowerCase();
				//fldReplaceText(c, c, ch);
				if (filterMenu()) return;
			}
			else if (event.keyCode == Keyboard.BACKSPACE)
			{
				//fldReplaceText(c-1, c, '');
				if (menuStr.length > 0)
				{
					menuStr = menuStr.substr(0, -1);
					if (filterMenu()) return;
				} else {
					deactivate();
				}
			}
			else if (event.keyCode == Keyboard.DELETE)
			{
				fldReplaceText(c, c+1, '');
			} else if (event.keyCode == Keyboard.ESCAPE) {
				deactivate();
			}
		}
	}
	
	private function stageMouseDownHandler(event:MouseEvent):void {
		if (!contains(event.target as DisplayObject)) {
			deactivate();
		}
	}
	
	private function addedToStageHandler(event:Event):void {
		stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDownHandler, true, STAGE_KEY_LISTEN_PRIORITY);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler, true, STAGE_KEY_LISTEN_PRIORITY);
	}
	
	private function removedFromStageHandler(event:Event):void {
		stage.removeEventListener(KeyboardEvent.KEY_DOWN, stageKeyDownHandler, true);
		stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler, true);
	}
}

}

