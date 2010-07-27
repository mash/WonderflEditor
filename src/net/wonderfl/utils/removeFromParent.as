package net.wonderfl.utils 
{
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public function removeFromParent($obj:DisplayObject):void
	{
		if ($obj && $obj.parent) $obj.parent.removeChild($obj);
	}

}