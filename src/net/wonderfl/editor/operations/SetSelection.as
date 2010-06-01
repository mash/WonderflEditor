package net.wonderfl.editor.operations 
{
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class SetSelection
	{
		public var beginIndex:int;
		public var endIndex:int;
		
		public function SetSelection($beginIndex:int, $endIndex:int) 
		{
			beginIndex = $beginIndex;
			endIndex = $endIndex;
		}
		
	}

}