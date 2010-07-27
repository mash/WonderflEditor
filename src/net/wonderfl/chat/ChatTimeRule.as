package net.wonderfl.chat 
{
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class ChatTimeRule
	{
		public static function getTimeStr($value:int):String {
			if ($value < 5) return "just now";
			if ($value < 60) return "about " + (($value / 5) >> 0) * 5 + " seconds ago";
			$value /= 60;
			if ($value < 60) return "about " + plural($value, 'minute') + " ago";
			$value /= 60;
			if ($value < 24) return "about " + plural($value, 'hour') + " ago";
			$value /= 24;
			if ($value < 7) return "about " + plural($value, 'day') + " ago";
			if ($value < 30) return "about " + plural($value / 7, 'week') + " ago";
			if ($value < 365) return "about " + plural($value / 12, 'month') + " ago";
			return "about " + plural($value / 365, 'year') + " ago";
		}
		
		private static function plural($number:int, $noun:String):String {
			return $number + ' ' + $noun + (($number > 1) ? 's' : '');
		}
	}

}