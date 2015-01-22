package tools;

class Path
{
	public static function extension(str:String):String
	{
		if (EXTENSION_REGEX.match(str))
		{
			return EXTENSION_REGEX.matched(1);
		}
		return "";
	}

	private static var EXTENSION_REGEX = ~/\.([a-z0-9]+)$/;
}
