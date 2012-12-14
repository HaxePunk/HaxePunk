package com.haxepunk.graphics.atlas;

import com.haxepunk.HXP;
import nme.display.BitmapData;
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

	private var _index:Int;
	private var _tilesheet:Tilesheet;
	private var _regions:Hash<AtlasRegion>;
}