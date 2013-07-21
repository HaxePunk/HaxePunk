package com.haxepunk.graphics.atlas;

import flash.display.BitmapData;

class TileAtlas extends Atlas
{
	/**
	 * Constructor.
	 * 
	 * @param	source		Source texture.
	 * @param	tileWidth	With of the tiles.
	 * @param	tileHeight	Height of the tiles.
	 */
	public function new(source:Dynamic, tileWidth:Int, tileHeight:Int)
	{
		super(source);
		_regions = new Array<AtlasRegion>();
		prepareTiles(_data.width, _data.height, tileWidth, tileHeight);
	}

	/**
	 * Gets an atlas region based on an identifier
	 * @param 	index	The tile index of the region to retrieve
	 * 
	 * @return	The atlas region object.
	 */
	public function getRegion(index:Int):AtlasRegion
	{
		return _regions[index];
	}

	private function prepareTiles(width:Int, height:Int, tileWidth:Int, tileHeight:Int)
	{
		var cols:Int = Math.floor(width / tileWidth);
		var rows:Int = Math.floor(height / tileHeight);

		HXP.rect.width = tileWidth;
		HXP.rect.height = tileHeight;

		HXP.point.x = HXP.point.y = 0;

		for (y in 0...rows)
		{
			HXP.rect.y = y * tileHeight;

			for (x in 0...cols)
			{
				HXP.rect.x = x * tileWidth;

				_regions.push(_data.createRegion(HXP.rect, HXP.point));
			}
		}
	}

	private var _regions:Array<AtlasRegion>;
}
