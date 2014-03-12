package com.haxepunk.graphics.atlas;

import com.haxepunk.HXP;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.Assets;

class TextureAtlas extends Atlas
{
	private function new(source:Dynamic)
	{
		_regions = new Map<String,AtlasRegion>();

		super(source);
	}

	/**
	 * Loads a TexturePacker xml file and generates all tile regions.
	 * Uses the Generic XML exporter format from Texture Packer.
	 * @param	file	The TexturePacker file to load
	 * @return	A TextureAtlas with all packed images defined as regions
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
	 * @param	name	The name identifier of the region to retrieve.
	 * 
	 * @return	The retrieved region.
	 */
	public function getRegion(name:String):AtlasRegion
	{
		if (_regions.exists(name))
			return _regions.get(name);
			
		throw 'Region has not be defined yet "$name".';
	}

	/**
	 * Creates a new AtlasRegion and assigns it to a name
	 * @param	name	The region name to create
	 * @param	rect	Defines the rectangle of the tile on the tilesheet
	 * @param	center	Positions the local center point to pivot on
	 * 
	 * @return	The new AtlasRegion object.
	 */
	public function defineRegion(name:String, rect:Rectangle, ?center:Point):AtlasRegion
	{
		var region = _data.createRegion(rect, center);
		_regions.set(name, region);
		return region;
	}

	private var _regions:Map<String,AtlasRegion>;
}
