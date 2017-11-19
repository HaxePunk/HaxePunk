package haxepunk;

#if (lime || nme)

typedef Assets = flash.Assets;

#else

class Assets
{
	public static function getText(file:String):String
	{
		throw "Unimplemented";
	}
}

#end
