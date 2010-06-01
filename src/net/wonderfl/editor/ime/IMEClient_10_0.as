package net.wonderfl.editor.ime 
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.system.IME;
	import flash.text.TextField;
	import mx.controls.TextInput;
	import net.wonderfl.editor.core.UIFTETextInput;
	import net.wonderfl.editor.manager.IKeyboadEventManager;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class IMEClient_10_0 extends AbstractIMEClient implements IKeyboadEventManager
	{
		public function IMEClient_10_0($field:UIFTETextInput) 
		{
			super($field);
			
			_imeField.addEventListener(TextEvent.TEXT_INPUT, onIMEInput);
		}
		
		private function onIMEInput(e:Event):void 
		{
			_imeField.text = '';
			_field.resetIMETFPosition();
			e.preventDefault();
		}
		
		override public function keyDownHandler($event:KeyboardEvent):Boolean
		{
            if (IME.enabled && IME.conversionMode != "ALPHANUMERIC_HALF") {
                if (!_imeMode) {
					_field.resetIMETFPosition();
                    _imeMode = true;
                    _imeField.text = '';
                    _imeField.visible = true;
                    if (_field.stage.focus != _imeField) _field.stage.focus = _imeField;
                }
            } else if (_imeMode) {
                _imeMode = false;
                _imeField.text = '';
                _imeField.visible = false;
                _field.stage.focus = _field;
            }
			
			return _imeField.visible;
		}
	}

}