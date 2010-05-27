package net.wonderfl.editor.ime 
{
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import net.wonderfl.editor.we_internal;
	import net.wonderfl.editor.core.UIFTETextInput;
	import net.wonderfl.editor.manager.IKeyboadEventManager;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class AbstractIMEClient implements IKeyboadEventManager
	{
		protected var _field:UIFTETextInput;
		protected var _imeField:TextField;
		protected var _imeMode:Boolean = false;
		
		public function AbstractIMEClient($field:UIFTETextInput) 
		{
			_field = $field;
			_imeField = $field.we_internal::_imeField;
		}
		
		public function keyDownHandler($event:KeyboardEvent):Boolean { return false; }
		public function get imeMode():Boolean { return _imeMode; }
	}

}