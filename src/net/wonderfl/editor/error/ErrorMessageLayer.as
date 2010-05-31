package net.wonderfl.editor.error 
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import net.wonderfl.editor.we_internal;
	import net.wonderfl.editor.core.FTETextField;
	import net.wonderfl.editor.utils.removeAllChildren;
	import net.wonderfl.editor.utils.removeFromParent;
	
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ErrorMessageLayer extends Sprite
	{
		private var _errorMessages:Vector.<ErrorMessage> = new Vector.<ErrorMessage>;
		private var _errorTooltip:ErrorMessageToolTip;
		private var _field:FTETextField;
		private var _toolTipTimer:Timer;
		
		public function ErrorMessageLayer($field:FTETextField) 
		{
			tabChildren = tabEnabled = false;
			_field = $field;
			_errorTooltip = new ErrorMessageToolTip;
		}
		
		public function render():void {
			removeAllChildren(this);
			
			var i:int;
			var len:int = _errorMessages.length;
			var message:ErrorMessage;
			var shp:ErrorRowSprite;
			for (i = 0; i < len; ++i) {
				message = _errorMessages[i];
				if (message.row < _field.scrollY) continue;
				if (message.row >= _field.scrollY + _field.visibleRows) break;
				
				shp = new ErrorRowSprite(message.row, message.message, onMouseOver);
				shp.graphics.beginFill(0x5d2917);
				shp.graphics.drawRect(0, 0, _field.width, _field.boxHeight);
				shp.graphics.endFill();
				shp.y = (message.row - _field.scrollY) * _field.boxHeight;
				addChild(shp);
			}
			
			_toolTipTimer = new Timer(1500, 1);
			_toolTipTimer.addEventListener(TimerEvent.TIMER, hideToolTip);
		}
		
		private function hideToolTip(e:TimerEvent):void 
		{
			removeFromParent(_errorTooltip);
		}
		
		private function onMouseOver($row:int, $message:String):void
		{
			var row:int = $row + 1;
			row = (row >= _field.scrollY + _field.visibleRows) ? _field.scrollY + _field.visibleRows - 2 : row;
			row = (row < 0) ? 0 : row;
			_errorTooltip.show($message);
			if (_toolTipTimer.running) _toolTipTimer.stop();
			_toolTipTimer.start();
			_errorTooltip.y = _field.boxHeight * row;
			_field.we_internal::_container.addChild(_errorTooltip);
		}
		
		public function clearErrorMessages():void {
			_errorMessages.length = 0;
		}
		
		public function addErrorMessage($message:ErrorMessage):void {
			_errorMessages.push($message);
		}
	}
}



