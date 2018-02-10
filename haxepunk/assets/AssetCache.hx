package haxepunk.assets;

import haxepunk.graphics.atlas.Atlas;
import haxepunk.graphics.atlas.AtlasData;
import haxepunk.graphics.atlas.AtlasRegion;
import haxepunk.graphics.atlas.AtlasResolutions;
import haxepunk.graphics.atlas.IAtlasRegion;
import haxepunk.graphics.atlas.TextureAtlas;
import haxepunk.graphics.atlas.TileAtlas;
import haxepunk.graphics.hardware.Texture;
import haxepunk.graphics.text.BitmapFont;
import haxepunk.graphics.text.BitmapFontAtlas;
import haxepunk.graphics.text.IBitmapFont;
using haxepunk.assets.AssetMacros;

class AssetCache
{
	public static var global:AssetCache = new AssetCache("global");
	public static var active:Array<AssetCache> = [global];

	public var name:String;

	public var enabled(get, never):Bool;
	inline function get_enabled() return active.indexOf(this) > -1;

	var textures:Map<String, Texture> = new Map();
	var text:Map<String, String> = new Map();
	// TODO: abstraction for Sound type
	var sounds:Map<String, Dynamic> = new Map();
	var regions:Map<String, IAtlasRegion> = new Map();
	var bitmapFonts:Map<String, IBitmapFont> = new Map();
	var tileAtlases:Map<String, TileAtlas> = new Map();
	var atlasData:Map<String, AtlasData> = new Map();

	public function new(name:String)
	{
		this.name = name;
	}

	public function addTexture(id:String, texture:Texture)
	{
		textures[id] = texture;
	}

	public function getTexture(id:String, addRef:Bool=true):Texture
	{
		return AssetMacros.findAsset(this, textures, id, addRef, {
			Log.info('loading texture $id into cache $name');
			AssetLoader.getTexture(id);
		});
	}

	public function removeTexture(id:String)
	{
		var texture = textures[id];
		textures.remove(id);
		var stillNeeded:Bool = false;
		for (cache in active)
		{
			if (cache.textures.exists(id))
			{
				stillNeeded = true;
				break;
			}
		}
		if (!stillNeeded)
		{
			Log.info('disposing texture $id');
			texture.dispose();
		}
	}

	public function addText(id:String, value:String)
	{
		text[id] = value;
	}

	public function getText(id:String, addRef:Bool=true):String
	{
		return AssetMacros.findAsset(this, text, id, addRef, AssetLoader.getText(id));
	}

	public function removeText(id:String)
	{
		text.remove(id);
	}

	public function addSound(id:String, sound:Dynamic)
	{
		sounds[id] = sound;
	}

	public function getSound(id:String, addRef:Bool=true):Dynamic
	{
		return AssetMacros.findAsset(this, sounds, id, addRef, AssetLoader.getSound(id));
	}

	public function removeSound(id:String)
	{
		sounds.remove(id);
	}

	public function addTileAtlas(id:String, atlas:TileAtlas)
	{
		tileAtlases[id] = atlas;
	}

	public function getTileAtlas(id:String, addRef:Bool=true):TileAtlas
	{
		return AssetMacros.findAsset(this, tileAtlases, id, addRef, {
			var texture = getTexture(id);
			var atlas = new TileAtlas(texture);
			atlas;
		});
	}

	public function removeTileAtlas(id:String)
	{
		tileAtlases.remove(id);
	}

	public function addAtlasData(id:String, data:AtlasData)
	{
		atlasData[id] = data;
	}

	public function getAtlasData(id:String, addRef:Bool=true):AtlasData
	{
		return AssetMacros.findAsset(this, atlasData, id, addRef, new AtlasData(getTexture(id), id));
	}

	public function removeAtlasData(id:String)
	{
		atlasData.remove(id);
	}

	public function addAtlasRegion(id:String, region:IAtlasRegion):Void
	{
		regions[id] = region;
	}

	public function getAtlasRegion(id:String, addRef:Bool=true):IAtlasRegion
	{
		return AssetMacros.findAsset(this, regions, id, addRef, {
			var data = getAtlasData(id);
			Atlas.loadImageAsRegion(data);
		});
	}

	public inline function removeAtlasRegion(id:String):Void
	{
		regions.remove(id);
	}

	public function addBitmapFont(fontName:String, font:IBitmapFont)
	{
		bitmapFonts[fontName] = font;
	}

	public function getBitmapFont(fontName:String, addRef:Bool=true):IBitmapFont
	{
		return AssetMacros.findAsset(this, bitmapFonts, fontName, addRef, null);
	}

	public function removeBitmapFont(fontName:String):Void
	{
		bitmapFonts.remove(fontName);
	}

	/**
	 * Add multiple BitmapFontAtlases to a single BitmapFont, representing
	 * multiple sizes of a single font. You can then reference this font as
	 * `fontName` in place of a bitmap font asset. BitmapText will
	 * automatically use the most appropriate size of the font when rendering.
	 */
	public function addBitmapFontSizes(fontName:String, fonts:Array<String>, format:BitmapFontFormat=BitmapFontFormat.XML, ?extraParams:Dynamic):BitmapFont
	{
		var bmf:BitmapFont = new BitmapFont(fontName);
		if (!bitmapFonts.exists(fontName))
		{
			bitmapFonts[fontName] = bmf;
		}
		var bitmapFont = bitmapFonts[fontName];
		for (font in fonts)
		{
			bmf.addSize(BitmapFontAtlas.getFont(font, format, extraParams));
		}
		return bmf;
	}

	/**
	 * Register multiple assets as different resolutions of a single image.
	 *
	 * After calling this method, use id wherever image assets are
	 * expected: `new Image(id)`. Graphics will pick the appropriate
	 * resolution from the list when rendering this asset.
	 */
	public function addResolutions(id:String, assets:Array<String>):AtlasResolutions
	{
		if (regions.exists(id))
		{
			var resolutions:AtlasResolutions = cast regions[id];
			for (asset in assets)
			{
				var region:AtlasRegion = cast getAtlasRegion(asset);
				resolutions.addResolution(region);
			}
			return resolutions;
		}
		else
		{
			var resolutions = new AtlasResolutions([for (asset in assets) Atlas.loadImageAsRegion(asset)]);
			regions[id] = resolutions;
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

	public function enable()
	{
		if (!enabled)
		{
			active.push(this);
			Log.debug('enabled asset cache $name');
		}
	}

	public function dispose()
	{
		if (enabled)
		{
			var pos = active.indexOf(this);
			Log.debug('disposing asset cache $name');
			active.remove(this);
			for (key in textures.keys())
			{
				removeTexture(key);
			}
		}
	}
}
