package ro.minibuilder.swcparser.abc
{
	internal dynamic class LabelInfo
	{
		public var count:int
		public function labelFor (target:int):String
		{
			if (target in this)
				return this[target]
			return this[target] = "L" + (++count)
		}
	}
}