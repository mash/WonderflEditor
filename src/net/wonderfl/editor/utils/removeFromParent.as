package net.wonderfl.editor.utils 
{
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public function removeFromParent($obj:DisplayObject) 
	{
		if ($obj && $obj.parent) $obj.parent.removeChild($obj);
	}

}