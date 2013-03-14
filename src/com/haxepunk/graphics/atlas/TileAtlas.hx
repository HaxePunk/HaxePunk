package com.haxepunk.graphics.atlas;

import nme.display.BitmapData;

class TileAtlas extends Atlas
{

	private function new(bd:BitmapData, tileWidth:Int, tileHeight:Int)
	{
		super(bd);
		_regions = new Map<Int,AtlasRegion>();
		prepareTiles(bd.width, bd.height, tileWidth, tileHeight);
	}

	public static function create(source:Dynamic, tileWidth:Int, tileHeight:Int):TileAtlas
	{
		var atlas:TileAtlas;
		if (Std.is(source, BitmapData))
		{
#if debug
			HXP.log("Atlases using BitmapData will not be managed.");
#end
			atlas = new TileAtlas(source, tileWidth, tileHeight);
		}
		else
		{
			if (Atlas._atlasPool.exists(source))
			{
				atlas = cast(Atlas._atlasPool.get(source), TileAtlas);
				atlas._refCount += 1;
			}
			else
			{
				atlas = new TileAtlas(HXP.getBitmap(source), tileWidth, tileHeight);
				atlas._name = source;
				Atlas._atlasPool.set(source, atlas);
			}
		}
		return atlas;
	}

	public function getRegion(index:Int):AtlasRegion
	{
		return _regions.get(index);
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

				var region = createRegion(HXP.rect, HXP.point);
				_regions.set(region.tileIndex, region);
			}
		}
	}

	private var _regions:Map<Int,AtlasRegion>;
}
