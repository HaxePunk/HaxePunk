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
	 * @param	tileMarginWidth		Tile horizontal margin.
	 * @param	tileMarginHeight	Tile vertical margin.
	 */
	public function new(source:Dynamic, tileWidth:Int, tileHeight:Int,?tileMarginWidth:Int=0,?tileMarginHeight:Int=0)
	{
		super(source);
		_regions = new Array<AtlasRegion>();
		prepareTiles(_data.width, _data.height, tileWidth, tileHeight,tileMarginWidth,tileMarginHeight);
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

	private function prepareTiles(width:Int, height:Int, tileWidth:Int, tileHeight:Int, tileMarginWidth:Int,tileMarginHeight:Int)
	{
		var cols:Int = Math.floor(width / tileWidth);
		var rows:Int = Math.floor(height / tileHeight);

		HXP.rect.width = tileWidth;
		HXP.rect.height = tileHeight;

		HXP.point.x = HXP.point.y = 0;

		for (y in 0...rows)
		{
			HXP.rect.y = y * (tileHeight+tileMarginHeight);

			for (x in 0...cols)
			{
				HXP.rect.x = x * (tileWidth+tileMarginWidth);

				_regions.push(_data.createRegion(HXP.rect, HXP.point));
			}
		}
	}

	private var _regions:Array<AtlasRegion>;
}
