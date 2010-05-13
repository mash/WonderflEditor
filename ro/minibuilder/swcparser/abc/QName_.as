package ro.minibuilder.swcparser.abc
{
	internal class QName_ extends Multiname_
	{
		function QName_(ns:Namespace_, name:String)
		{
			super(ns ? [ns] : [], name);
		}
	}
}