package haxepunk.assets;

import haxepunk.graphics.hardware.Texture;

#if (lime || nme)

typedef AssetLoader = haxepunk.backend.flash.AssetLoader;

#else

class AssetLoader
{
	public static function getText(id:String):String
	{
		throw "Unimplemented";
	}

	public static function getSound(id:String):Dynamic
	{
		throw "Unimplemented";
	}

	public static function getTexture(id:String):Texture
	{
		throw "Unimplemented";
	}
}

#end
