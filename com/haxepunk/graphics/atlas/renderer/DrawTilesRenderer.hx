package com.haxepunk.graphics.atlas.renderer;

#if !(openfl >= "4.0.0")
import flash.display.Graphics;
import openfl.display.Tilesheet;

@:access(com.haxepunk.graphics.atlas.AtlasData)
class DrawTilesRenderer
{
	public function new(data:AtlasData)
	{
		_tilesheet = new Tilesheet(data.bitmapData);
	}

	public inline function drawTiles(graphics:Graphics, tileData:Array<Float>, smooth:Bool = false, flags:Int = 0, count:Int = -1):Void
	{
		_tilesheet.drawTiles(graphics, tileData, smooth, flags, count);
	}

	var _tilesheet:Tilesheet;
}
#end
