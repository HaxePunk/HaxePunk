package com.haxepunk.utils;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;

class Platform
{
	static var remap = [
		"haxepunk.input.Input" => "com.haxepunk.utils.Input",
		"haxepunk.input.Key" => "com.haxepunk.utils.Key",
		"haxepunk.input.Gesture" => "com.haxepunk.utils.Gesture",
		"haxepunk.input.Touch" => "com.haxepunk.utils.Touch",
		"haxepunk.utils.Random" => "com.haxepunk.HXP",
		"haxepunk.utils.MathUtil" => "com.haxepunk.HXP",
	];

	static function run()
	{
		if (Context.defined("flash")) {}
		else if (Context.definedValue("openfl") >= "4.0.0" && !Context.defined("draw_tiles"))
		{
			Compiler.define("tile_shader");
		}
		else
		{
			Compiler.define("draw_tiles");
		}

		Context.onTypeNotFound(function (typeName:String)
		{
			var parts = typeName.split(".");
			if (parts[0] == "haxepunk")
			{
				var name = parts[parts.length - 1],
					futurePack = parts.slice(0, parts.length - 1);
				var currentPack, newName;
				if (remap.exists(typeName))
				{
					currentPack = remap[typeName].split(".");
					newName = currentPack[currentPack.length - 1];
					currentPack = currentPack.slice(0, currentPack.length - 1);
				}
				else
				{
					currentPack = ["com"].concat(parts.slice(0, parts.length - 1));
					newName = name;
				}
				return {name: name, pack: futurePack, kind: TDAlias(TPath({name: newName, pack: currentPack})), fields: [], pos: Context.currentPos()};
			}
			return null;
		});
	}
}
#end
