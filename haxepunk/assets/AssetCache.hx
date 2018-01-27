package haxepunk.assets;

import haxepunk.graphics.atlas.Atlas;
import haxepunk.graphics.atlas.AtlasRegion;
import haxepunk.graphics.atlas.AtlasResolutions;
import haxepunk.graphics.atlas.IAtlasRegion;
import haxepunk.graphics.atlas.TextureAtlas;
import haxepunk.graphics.hardware.Texture;
import haxepunk.graphics.text.BitmapFont;
import haxepunk.graphics.text.BitmapFontAtlas;

class AssetCache
{
	public static var global:AssetCache = new AssetCache();
	public static var active:Array<AssetCache> = [global];

	public static function getBitmapFont(fontName:String):Null<BitmapFont>
	{
		for (cache in active)
		{
			if (cache.bitmapFonts.exists(fontName)) return cache.bitmapFonts[fontName];
		}
		return null;
	}

	public static function hasTexture(id:String):Bool
	{
		for (cache in active)
		{
			if (cache.regions.exists(id)) return true;
		}
		return false;
	}

	public static function getRegion(id:String):Null<IAtlasRegion>
	{
		for (cache in active)
		{
			if (cache.regions.exists(id)) return cache.regions[id];
		}
		return null;
	}

	public var enabled(get, never):Bool;
	inline function get_enabled() return active.indexOf(this) > -1;

	var textures:Map<String, Texture> = new Map();
	// TODO
	//var sounds:Map<String, Texture>;
	var regions:Map<String, IAtlasRegion> = new Map();
	var bitmapFonts:Map<String, BitmapFont> = new Map();

	public function new() {}

	public function getTexture(id:String):Texture
	{
		// if we already have this texture cached, return it
		if (textures.exists(id)) return textures[id];
		// if another active cache already has this texture cached, return
		// their version
		for (cache in active)
		{
			if (cache.textures.exists(id))
			{
				// keep this asset cached here too, in case the owning cache is
				// disposed before this one is
				return textures[id] = cache.textures[id];
			}
		}
		// no cached version; load from asset loader
		return textures[id] = AssetLoader.getTexture(id);
	}

	public function saveTexture(id:String, texture:Texture)
	{
		textures[id] = texture;
	}

	/**
	 * Register multiple assets as different resolutions of a single image.
	 *
	 * After calling this method, use assetName wherever image assets are
	 * expected: `new Image(assetName)`. Graphics will pick the appropriate
	 * resolution from the list when rendering this asset.
	 */
	public function addResolutions(assetName:String, assets:Array<String>):AtlasResolutions
	{
		if (regions.exists(assetName))
		{
			var resolutions:AtlasResolutions = cast regions[assetName];
			for (asset in assets)
			{
				var region:AtlasRegion = cast getRegion(asset);
				resolutions.addResolution(region);
			}
			return resolutions;
		}
		else
		{
			var resolutions = new AtlasResolutions([for (asset in assets) Atlas.loadImageAsRegion(asset)]);
			regions[assetName] = resolutions;
			return resolutions;
		}
	}

	/**
	 * Add all of the regions from a TextureAtlas to the AssetCache.
	 *
	 * After calling this method, regions can be specified wherever images
	 * assets are expected, e.g. `new Image("my_atlas_region")`.
	 */
	@:access(haxepunk.graphics.atlas.TextureAtlas)
	public function addTextureAtlas(atlas:TextureAtlas):Void
	{
		for (key in atlas._regions.keys())
		{
			regions[key] = atlas.getRegion(key);
		}
	}

	public function addAtlasRegion(assetName:String, region:AtlasRegion):Void
	{
		regions[assetName] = region;
	}

	public inline function removeRegion(assetName:String):Void
	{
		regions.remove(assetName);
	}

	/**
	 * Add multiple BitmapFontAtlases to a single BitmapFont, representing
	 * multiple sizes of a single font. You can then reference this font as
	 * `fontName` in place of a bitmap font asset. BitmapText will
	 * automatically use the most appropriate size of the font when rendering.
	 */
	public function addBitmapFont(fontName:String, fonts:Array<String>, format:BitmapFontFormat=BitmapFontFormat.XML, ?extraParams:Dynamic):BitmapFont
	{
		if (!bitmapFonts.exists(fontName))
		{
			bitmapFonts[fontName] = new BitmapFont(fontName);
		}
		var bitmapFont = bitmapFonts[fontName];
		for (font in fonts)
		{
			bitmapFont.addSize(BitmapFontAtlas.getFont(font, format, extraParams));
		}
		return bitmapFont;
	}

	public function removeBitmapFont(fontName:String):Void
	{
		bitmapFonts.remove(fontName);
	}

	public function enable()
	{
		if (!enabled) active.push(this);
	}

	public function dispose()
	{
		active.remove(this);
		for (key in textures.keys())
		{
			var stillNeeded:Bool = false;
			for (cache in active)
			{
				if (cache.textures.exists(key))
				{
					stillNeeded = true;
					break;
				}
			}
			if (!stillNeeded)
			{
				var texture = textures[key];
				texture.dispose();
			}
			textures.remove(key);
		}
	}
}
