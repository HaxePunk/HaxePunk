package haxepunk.assets;

class AssetMacros
{
	macro public static function findAsset(cache:haxe.macro.Expr, id:haxe.macro.Expr, addRef:haxe.macro.Expr, fallback:haxe.macro.Expr)
	{
		var cache = haxe.macro.ExprTools.toString(cache);
		return macro {
			// if we already have this asset cached, return it
			if ($i{cache}.exists(${id})) return $i{cache}[${id}];
			// if another active cache already has this texture cached, return
			// their version
			for (cache in active)
			{
				if (cache.$cache.exists(${id}))
				{
					if (${addRef})
					{
						// keep this asset cached here too, in case the owning cache is
						// disposed before this one is
						$i{cache}[${id}] = cache.$cache[${id}];
					}
					return cache.$cache[${id}];
				}
			}
			// no cached version; load from asset loader
			return $i{cache}[${id}] = ${fallback};
		}
	}
}
