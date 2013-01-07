package com.haxepunk.graphics.atlas;

import flash.display.BitmapData;

class TileAtlas extends Atlas
{
	public function new(source:Dynamic, tileWidth:Int, tileHeight:Int)
	{
		var bd:BitmapData;
		if (Std.is(source, BitmapData)) bd = source;
		else bd = HXP.getBitmap(source);

		super(bd);

		prepareTiles(bd.width, bd.height, tileWidth, tileHeight);
	}

	public function getIndex(index:Int):AtlasRegion
	{
		return _regions.get(index);
	}

	private inline function prepareTiles(width:Int, height:Int, tileWidth:Int, tileHeight:Int)
	{
		var tile = 0;
		var cols:Int = Math.floor(width / tileWidth);
		var rows:Int = Math.floor(height / tileHeight);

		HXP.rect.width = tileWidth;
		HXP.rect.height = tileHeight;

		HXP.point.x = tileWidth / 2;
		HXP.point.y = tileHeight / 2;

		for (y in 0...rows)
		{
			HXP.rect.y = y * tileHeight;

			for (x in 0...cols)
			{
				HXP.rect.x = x * tileWidth;

				_tilesheet.addTileRect(HXP.rect, HXP.point);
				_regions.set(tile, new AtlasRegion(this, tile, tileWidth, tileHeight));
			}
		}
	}

	private var _regions:IntHash<AtlasRegion>;
}