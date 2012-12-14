package com.haxepunk.graphics.atlas;

import com.haxepunk.HXP;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.display.Tilesheet;
import nme.geom.Point;
import nme.geom.Rectangle;

class TextureAtlas
{
	public function new(source:Dynamic)
	{
		var bd:BitmapData;
		if (Std.is(source, BitmapData)) bd = source;
		else bd = HXP.getBitmap(source);

		_tilesheet = new Tilesheet(bd);
		_regions = new Hash<AtlasRegion>();
		_index = 0;

		_renderFlags = 0;
		_tileData = new Array<Float>();
	}

	public function render(g:Graphics, smooth:Bool=false)
	{
		_tilesheet.drawTiles(g, _tileData, smooth, _renderFlags);
		// clear tile data
#if (cpp||php)
		_tileData.splice(0,_tileData.length);
#else
		untyped _tileData.length = 0;
#end
	}

	public function prepareTile(tile:Int, x:Float, y:Float, scale:Float, rotation:Float, color:Int)
	{
		var red = 0, green = 0, blue = 0, alpha = 1;
		_tileData.push(x);
		_tileData.push(y);
		_tileData.push(tile);
		_tileData.push(scale);
		_tileData.push(rotation);

		// _tileData.push(red);
		// _tileData.push(green);
		// _tileData.push(blue);
		// _tileData.push(alpha);
	}

	public function getRegion(name:String):AtlasRegion
	{
		if (_regions.exists(name))
			return _regions.get(name);
		throw "Region has not be defined yet: " + name;
	}

	public function defineRegion(name:String, rect:Rectangle, ?center:Point)
	{
		_tilesheet.addTileRect(rect, center);
		_regions.set(name, new AtlasRegion(this, _index));
		_index += 1;
	}

	private var _tileData:Array<Float>;
	private var _renderFlags:Int;

	private var _index:Int;
	private var _tilesheet:Tilesheet;
	private var _regions:Hash<AtlasRegion>;
}