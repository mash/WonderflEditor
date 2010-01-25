package net.wonderfl.controls 
{
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import jp.psyark.psycode.controls.ScrollBar;
	import jp.psyark.psycode.controls.TextScrollBar;
	/**
	 * @author kobayashi-taro
	 */
	public class EditorScrollBar extends TextScrollBar
	{
		private var _positions:Array;
		
		public function EditorScrollBar($target:TextField, $direction:String="vertical") {
			super($target, $direction);
		}
		
		public function setErrorPositions($positions:Array):void {
			_positions = $positions;
			
			updateTrack();
		}
		
		override protected function updateTrack():void 
		{
			super.updateTrack();
			
			var len:int = _positions ? _positions.length : 0;
				
			var i:int;
			var rect:Rectangle;
			var scale:Number = height - BAR_THICKNESS;
			var h:int;
			
			track.graphics.beginFill(0xa7360f);
			for (i = 0; i < len; ++i) {
				rect = _positions[i];
				rect.width = BAR_THICKNESS;
				h = rect.height * scale;
				h = (h < 2) ? 2 : h;
				h = (h > 10) ? 10 : h;
				rect.height = h;
				rect.y *= scale;
				track.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
			}
			track.graphics.endFill();
		}
		
		override protected function moveCursor($position:Number):void 
		{
			var len:int = target.text.length - 1;
			if (len < 1) return;
			var lastLine:int = target.getLineIndexOfChar(len);
			var pos:int = lastLine * $position / height;
			pos = (pos > lastLine) ? lastLine : pos;
			pos = target.getLineOffset(pos);
			
			target.setSelection(pos, pos);
		}
	}

}