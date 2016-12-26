package haxepunk.utils;

#if macro
import haxe.macro.Context;

@:dox(hide)
class Platform
{
	static function run()
	{
		Context.onTypeNotFound(function (typeName:String)
		{
			var parts = typeName.split(".");
			if (parts[0] == "com" && parts[1] == "haxepunk")
			{
				var name = parts[parts.length - 1],
					currentPack = parts.slice(1, parts.length - 1),
					deprecatedPack = parts.slice(0, parts.length - 1);
				trace('Warning: the com.haxepunk package is deprecated ($typeName -> ' + currentPack.join(".") + '.$name)');
				return {name: name, pack: deprecatedPack, kind: TDAlias(TPath({name: name, pack: currentPack})), fields: [], pos: Context.currentPos()};
			}
			return null;
		});
	}
}
#end
