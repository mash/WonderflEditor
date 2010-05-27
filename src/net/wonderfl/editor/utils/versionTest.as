package net.wonderfl.editor.utils 
{
	import flash.system.Capabilities;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public function versionTest(major:int,minor:int):Boolean
	{ 
		var versionData:Array = Capabilities.version.split(" ")[1].split(","); 
		return int(versionData[0]) > major || (int(versionData[0]) == major && int(versionData[1]) >= minor);
	}
}