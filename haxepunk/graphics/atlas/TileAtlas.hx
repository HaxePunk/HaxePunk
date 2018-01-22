package haxepunk.graphics.atlas;

import haxepunk.HXP;
import haxepunk.graphics.atlas.AtlasData;

class TileAtlas extends Atlas
{
	/**
	 *  The number of tiles.
	 */
	public var tileCount(get, never):Int;
	inline function get_tileCount():Int return _regions.length;

	/**
	 *  The width of the tiles.
	 */
	public var tileWidth(get, never):Int;
	inline function get_tileWidth():Int return _tileWidth;
	
	/**
	 *  The height of the tiles.
	 */
	public var tileHeight(get, never):Int;
	inline function get_tileHeight():Int return _tileHeight;

	/**
	 *  The horizontal margin of the tiles.
	 */
	public var tileMarginWidth(get, never):Int;
	inline function get_tileMarginWidth():Int return _tileMarginWidth;

	/**
	 *  The vertical margin of the tiles.
	 */
	public var tileMarginHeight(get, never):Int;
	inline function get_tileMarginHeight():Int return _tileMarginHeight;

	/**
	 * Constructor.
	 *
	 * @param	source		Source texture.
	 */
	public function new(source:AtlasDataType, tileWidth:Int = 0, tileHeight:Int = 0, tileMarginWidth:Int = 0, tileMarginHeight:Int = 0)
	{
		super(source);
		_regions = new Array<AtlasRegion>();
		_tileWidth = tileWidth;
		_tileHeight = tileHeight;
		_tileMarginWidth = tileMarginWidth;
		_tileMarginHeight = tileMarginHeight;
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

		var region = atlas._regions[0];
		atlas._tileWidth = region.width;
		atlas._tileHeight = region.height;

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
		_tileWidth = tileWidth;
		_tileHeight = tileHeight;
		_tileMarginWidth = tileMarginWidth;
		_tileMarginHeight = tileMarginHeight;

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
	var _tileWidth:Int;
	var _tileHeight:Int;
	var _tileMarginWidth:Int;
	var _tileMarginHeight:Int;
}
