package net.wonderfl.utils 
{
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public function bind($function:Function, $args:Array = null, $numOriginalArgs:int = 0):Function
	{
		$args ||= [];
		
		return function (...$$originalArgs:Array):* {
			return $function.apply(null, $args.concat($$originalArgs.slice(0, $numOriginalArgs)));
		}
	}
}