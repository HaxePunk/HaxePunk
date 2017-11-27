package haxepunk;

#if (lime || nme)

typedef Assets = haxepunk.backend.flash.Assets;

#else

class Assets
{
	public static function getText(file:String):String
	{
		throw "Unimplemented";
	}
}

#end
