package haxepunk.assets;

/**
 * Extend this class to implement custom cacheable asset handling.
 *
 * @since 4.1.0
 */
class CustomAssetLoader
{
	public function load(id:String):Dynamic return null;

	/**
	 * Override this to add custom disposal logic.
	 */
	public function dispose(asset:Dynamic):Void {}

	/**
	 * Override this to customize behavior when the asset is loaded after a
	 * cache miss
	 */
	public function onLoad(id:String, asset:Dynamic, cache:AssetCache):Void {}

	/**
	 * Override this to customize behavior when a reference is added to an
	 * asset in another active cache.
	 */
	public function onRef(id:String, asset:Dynamic, cache:AssetCache, otherCache:AssetCache):Void {}
}
