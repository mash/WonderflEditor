package net.wonderfl.editor.livecoding 
{
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class LiveCommand
	{
		public function LiveCommand(...$arguments:Array) {
			this.arguments = $arguments.slice();
		}
		public var arguments:Array;
	}
}