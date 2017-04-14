package haxepunk;

import haxepunk.graphics.atlas.Atlas;
import haxepunk.graphics.atlas.AtlasResolutions;
import haxepunk.graphics.atlas.BitmapFont;
import haxepunk.graphics.atlas.BitmapFontAtlas;

class AssetManager
{
	public static function addResolutions(assetName:String, assets:Array<String>)
	{
		if (atlasResolutions.exists(assetName))
		{
			for (asset in assets) atlasResolutions[assetName].addResolution(Atlas.loadImageAsRegion(asset));
		}
		else
		{
			atlasResolutions[assetName] = new AtlasResolutions([for (asset in assets) Atlas.loadImageAsRegion(asset)]);
		}
	}

	public static inline function getResolutions(assetName:String):Null<AtlasResolutions>
	{
		return atlasResolutions.exists(assetName) ? atlasResolutions[assetName] : null;
	}

	public static function addBitmapFont(fontName:String, fonts:Array<String>, format:BitmapFontFormat=BitmapFontFormat.XML, ?extraParams:Dynamic)
	{
		if (!bitmapFonts.exists(fontName))
		{
			bitmapFonts[fontName] = new BitmapFont(fontName);
		}
		for (font in fonts)
		{
			bitmapFonts[fontName].addSize(BitmapFontAtlas.getFont(font, format, extraParams));
		}
	}

	public static inline function getBitmapFont(fontName:String):Null<BitmapFont>
	{
		return bitmapFonts.exists(fontName) ? bitmapFonts[fontName] : null;
	}

	static var atlasResolutions:Map<String, AtlasResolutions> = new Map();
	static var bitmapFonts:Map<String, BitmapFont> = new Map();
}
