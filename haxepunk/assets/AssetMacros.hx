package haxepunk.assets;

class AssetMacros
{
	macro public static function findAsset(cache:haxe.macro.Expr, map:haxe.macro.Expr, other:haxe.macro.Expr, id:haxe.macro.Expr, addRef:haxe.macro.Expr, fallback:haxe.macro.Expr, ?onRef:haxe.macro.Expr)
	{
		if (onRef == null) onRef = macro {};
		return macro {
			var result = null;
			// if we already have this asset cached, return it
			if (${map}.exists(${id}))
			{
				result = ${map}[${id}];
			}
			else
			{
				// if another active cache already has this texture cached, return
				// their version
				for (otherCache in active)
				{
					if (${other}.exists(${id}))
					{
						var cached = $other[${id}];
						if (${addRef} && cached != null)
						{
							// keep this asset cached here too, in case the owning cache is
							// disposed before this one is
							Log.debug('adding asset cache reference: ' + ${cache} + ':' + ${id} + ' -> ' + otherCache.name + ':' + ${id});
							${map}[${id}] = cached;
							${onRef};
						}
						result = cached;
					}
				}
				// no cached version; load from asset loader
				if (result == null) result = ${map}[${id}] = ${fallback};
			}
			result;
		}
	}
}
