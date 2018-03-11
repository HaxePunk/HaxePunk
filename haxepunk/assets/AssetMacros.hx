package haxepunk.assets;

class AssetMacros
{
	macro public static function findAsset(cache:haxe.macro.Expr, map:haxe.macro.Expr, id:haxe.macro.Expr, addRef:haxe.macro.Expr, fallback:haxe.macro.Expr)
	{
		var map = haxe.macro.ExprTools.toString(map);
		return macro {
			// if we already have this asset cached, return it
			if ($i{map}.exists(${id})) return $i{map}[${id}];
			// if another active cache already has this texture cached, return
			// their version
			for (otherCache in active)
			{
				if (otherCache.$map.exists(${id}))
				{
					var cached = otherCache.$map[${id}];
					if (${addRef} && cached != null)
					{
						// keep this asset cached here too, in case the owning cache is
						// disposed before this one is
						Log.debug('adding asset cache reference: ' + ${cache} + ':$id -> ' + otherCache.name + ':$id');
						$i{map}[${id}] = cached;
					}
					return cached;
				}
			}
			// no cached version; load from asset loader
			return $i{map}[${id}] = ${fallback};
		}
	}
}
