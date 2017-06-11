package haxepunk;

import haxepunk.graphics.atlas.Atlas;
import haxepunk.graphics.atlas.AtlasRegion;
import haxepunk.graphics.atlas.AtlasResolutions;
import haxepunk.graphics.atlas.IAtlasRegion;
import haxepunk.graphics.atlas.TextureAtlas;
import haxepunk.graphics.text.BitmapFont;
import haxepunk.graphics.text.BitmapFontAtlas;

class AssetManager
{
	/**
	 * Register multiple assets as different resolutions of a single image.
	 *
	 * After calling this method, use assetName wherever image assets are
	 * expected: `new Image(assetName)`. Graphics will pick the appropriate
	 * resolution from the list when rendering this asset.
	 */
	public static function addResolutions(assetName:String, assets:Array<String>):AtlasResolutions
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
	 * Add all of the regions from a TextureAtlas to the AssetManager.
	 *
	 * After calling this method, regions can be specified wherever images
	 * assets are expected, e.g. `new Image("my_atlas_region")`.
	 */
	@:access(haxepunk.graphics.atlas.TextureAtlas)
	public static function addTextureAtlas(atlas:TextureAtlas):Void
	{
		for (key in atlas._regions.keys())
		{
			regions[key] = atlas.getRegion(key);
		}
	}

	public static function addAtlasRegion(assetName:String, region:AtlasRegion):Void
	{
		regions[assetName] = region;
	}

	public static inline function getRegion(assetName:String):Null<IAtlasRegion>
	{
		return regions.exists(assetName) ? regions[assetName] : null;
	}

	public static inline function removeRegion(assetName:String):Void
	{
		regions.remove(assetName);
	}

	/**
	 * Add multiple BitmapFontAtlases to a single BitmapFont, representing
	 * multiple sizes of a single font. You can then reference this font as
	 * `fontName` in place of a bitmap font asset. BitmapText will
	 * automatically use the most appropriate size of the font when rendering.
	 */
	public static function addBitmapFont(fontName:String, fonts:Array<String>, format:BitmapFontFormat=BitmapFontFormat.XML, ?extraParams:Dynamic):BitmapFont
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

	public static inline function getBitmapFont(fontName:String):Null<BitmapFont>
	{
		return bitmapFonts.exists(fontName) ? bitmapFonts[fontName] : null;
	}

	public static inline function removeBitmapFont(fontName:String):Void
	{
		bitmapFonts.remove(fontName);
	}

	static var regions:Map<String, IAtlasRegion> = new Map();
	static var bitmapFonts:Map<String, BitmapFont> = new Map();
}
