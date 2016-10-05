package com.haxepunk.graphics.atlas.renderer;

#if !(openfl >= "4.0.0")
import com.haxepunk.ds.Either;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;
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
