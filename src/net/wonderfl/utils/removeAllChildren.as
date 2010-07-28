package net.wonderfl.utils 
{
	import flash.display.DisplayObjectContainer;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public function removeAllChildren($container:DisplayObjectContainer):void
	{
		while ($container.numChildren) $container.removeChildAt(0);
	}
}