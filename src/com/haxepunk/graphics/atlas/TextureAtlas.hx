package com.haxepunk.graphics.atlas;

import com.haxepunk.HXP;
import nme.display.BitmapData;
import nme.geom.Point;
import nme.geom.Rectangle;

class TextureAtlas extends Atlas
{
	private function new(bd:BitmapData)
	{
		_regions = new Hash<AtlasRegion>();

		super(bd);
	}

	public static function create(source:Dynamic):TextureAtlas
	{
		var atlas:TextureAtlas;
		if (Std.is(source, BitmapData))
		{
#if debug
			HXP.log("Atlases using BitmapData will not be managed.");
#end
			atlas = new TextureAtlas(source);
		}
		else
		{
			if (Atlas._atlasPool.exists(source))
			{
				atlas = cast(Atlas._atlasPool.get(source), TextureAtlas);
				atlas._refCount += 1;
			}
			else
			{
				atlas = new TextureAtlas(HXP.getBitmap(source));
				atlas._name = source;
				Atlas._atlasPool.set(source, atlas);
			}
		}
		return atlas;
	}

	/**
	 * Loads a TexturePacker xml file and generates all tile regions
	 * @param file the TexturePacker file to load
	 * @return a TextureAtlas with all packed images defined as regions
	 */
	public static function loadTexturePacker(file:String):TextureAtlas
	{
		var xml = Xml.parse(nme.Assets.getText(file));
		var root = xml.firstElement();
		var atlas = TextureAtlas.create(root.get("imagePath"));
		for (sprite in root.elements())
		{
			HXP.rect.x = Std.parseInt(sprite.get("x"));
			HXP.rect.y = Std.parseInt(sprite.get("y"));
			if (sprite.exists("w")) HXP.rect.width = Std.parseInt(sprite.get("w"));
			if (sprite.exists("h")) HXP.rect.height = Std.parseInt(sprite.get("h"));

			// set the defined region
			var region = atlas.defineRegion(sprite.get("n"), HXP.rect);

			if (sprite.exists("r") && sprite.get("r") == "y") region.rotated = true;
		}
		return atlas;
	}

	/**
	 * Gets an atlas region based on an identifier
	 * @param name the name identifier of the region to retrieve
	 */
	public function getRegion(name:String):AtlasRegion
	{
		if (_regions.exists(name))
			return _regions.get(name);
		throw "Region has not be defined yet: " + name;
	}

	/**
	 * Creates a new AtlasRegion and assigns it to a name
	 * @param name the region name to create
	 * @param rect defines the rectangle of the tile on the tilesheet
	 * @param center positions the local center point to pivot on
	 */
	public function defineRegion(name:String, rect:Rectangle, ?center:Point):AtlasRegion
	{
		var region = createRegion(rect, center);
		_regions.set(name, region);
		return region;
	}

	private var _regions:Hash<AtlasRegion>;
}