package haxepunk.graphics.atlas;

import flash.Assets;
import haxepunk.HXP;
import haxepunk.graphics.atlas.AtlasData;

class TileAtlas extends Atlas
{

	public var tileCount(get, never):Int;
	inline function get_tileCount():Int return _regions.length;

	/**
	 * Constructor.
	 *
	 * @param	source		Source texture.
	 */
	public function new(source:AtlasDataType)
	{
		super(source);
		_regions = new Array<AtlasRegion>();
	}

	/**
	 * Gets an atlas region based on an identifier
	 * @param 	index	The tile index of the region to retrieve
	 *
	 * @return	The atlas region object.
	 */
	public function getRegion(index:Int):AtlasRegion
	{
		if (index >= _regions.length)
		{
			throw 'Atlas doesn\'t have a region number "$index"';
		}

		return _regions[index];
	}

	/**
	 * Loads a TileAtlas from a named TextureAtlas
	 * @param	textureAtlas	A TextureAtlas object to pull frames from
	 * @param	regions			A list of atlas region names in the order they should be in TileAtlas
	 * @return	A TileAtlas with all packed images defined as regions ordered by sprite names supplied
	 */
	public static function loadFromTextureAtlas(textureAtlas:TextureAtlas, regions:Array<String>):TileAtlas
	{
		var atlas = new TileAtlas(textureAtlas._data);
		for (spriteName in regions)
		{
			var region = textureAtlas.getRegion(spriteName);
			atlas._regions.push(region);
		}
		return atlas;
	}

	/**
	 * Prepares the atlas for drawing.
	 * @param	tileWidth	With of the tiles.
	 * @param	tileHeight	Height of the tiles.
	 * @param	tileMarginWidth		Tile horizontal margin.
	 * @param	tileMarginHeight	Tile vertical margin.
	 */
	public function prepare(tileWidth:Int, tileHeight:Int, tileMarginWidth:Int=0, tileMarginHeight:Int=0)
	{
		if (_regions.length > 0) return; // only prepare once
		var cols:Int = Math.floor(_data.width / tileWidth);
		var rows:Int = Math.floor(_data.height / tileHeight);

		HXP.rect.width = tileWidth;
		HXP.rect.height = tileHeight;

		HXP.point.x = HXP.point.y = 0;

		for (y in 0...rows)
		{
			HXP.rect.y = y * (tileHeight + tileMarginHeight);

			for (x in 0...cols)
			{
				HXP.rect.x = x * (tileWidth + tileMarginWidth);

				_regions.push(_data.createRegion(HXP.rect, HXP.point));
			}
		}
	}

	var _regions:Array<AtlasRegion>;
}
