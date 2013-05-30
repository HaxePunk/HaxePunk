package com.haxepunk.graphics.atlas;

import com.haxepunk.HXP;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
#if nme
import nme.Assets;
#else
import openfl.Assets;
#end

class TextureAtlas extends Atlas
{
	private function new(source:Dynamic)
	{
#if haxe3
		_regions = new Map<String,AtlasRegion>();
#else
		_regions = new Hash<AtlasRegion>();
#end

		super(source);
	}

	/**
	 * Loads a TexturePacker xml file and generates all tile regions.
	 * Uses the Generic XML exporter format from Texture Packer.
	 * @param file the TexturePacker file to load
	 * @return a TextureAtlas with all packed images defined as regions
	 */
	public static function loadTexturePacker(file:String):TextureAtlas
	{
		var xml = Xml.parse(Assets.getText(file));
		var root = xml.firstElement();
		var atlas = new TextureAtlas(root.get("imagePath"));
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
		var region = _data.createRegion(rect, center);
		_regions.set(name, region);
		return region;
	}

#if haxe3
	private var _regions:Map<String,AtlasRegion>;
#else
	private var _regions:Hash<AtlasRegion>;
#end
}
