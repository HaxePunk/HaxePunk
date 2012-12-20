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

		_renderFlags = Tilesheet.TILE_ALPHA | Tilesheet.TILE_BLEND_NORMAL | Tilesheet.TILE_ROTATION | Tilesheet.TILE_RGB | Tilesheet.TILE_SCALE;
		_tileData = new Array<Float>();

		_atlases.push(this);
	}

	public static function loadTexturePacker(file:String):TextureAtlas
	{
		var xml = Xml.parse(nme.Assets.getText(file));
		var root = xml.firstElement();
		var atlas = new TextureAtlas(root.get("imagePath"));
		var rect = new Rectangle();
		for (sprite in root.elements())
		{
			rect.x = Std.parseInt(sprite.get("x"));
			rect.y = Std.parseInt(sprite.get("y"));
			if (sprite.exists("w")) rect.width = Std.parseInt(sprite.get("w"));
			if (sprite.exists("h")) rect.height = Std.parseInt(sprite.get("h"));

			// set the defined region
			var region = atlas.defineRegion(sprite.get("n"), rect);

			if (sprite.exists("r") && sprite.get("r") == "y") region.rotated = true;
		}
		return atlas;
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

	public static function renderAll(g:Graphics, smooth:Bool=false)
	{
		for (atlas in _atlases)
		{
			atlas.render(g, smooth);
		}
	}

	public inline function prepareTile(tile:Int, x:Float, y:Float, scale:Float, rotation:Float, red:Float, green:Float, blue:Float, alpha:Float)
	{
		_tileData.push(x);
		_tileData.push(y);
		_tileData.push(tile);
		_tileData.push(scale);
		_tileData.push(rotation);

		_tileData.push(red);
		_tileData.push(green);
		_tileData.push(blue);
		_tileData.push(alpha);
	}

	public function getRegion(name:String):AtlasRegion
	{
		if (_regions.exists(name))
			return _regions.get(name);
		throw "Region has not be defined yet: " + name;
	}

	public function defineRegion(name:String, rect:Rectangle, ?center:Point):AtlasRegion
	{
		_tilesheet.addTileRect(rect, center);
		var region = new AtlasRegion(this, _index, rect.width, rect.height);
		_regions.set(name, region);
		_index += 1;
		return region;
	}

	private var _tileData:Array<Float>;
	private var _renderFlags:Int;

	private var _index:Int;
	private var _tilesheet:Tilesheet;
	private var _regions:Hash<AtlasRegion>;

	private static var _atlases:Array<TextureAtlas> = new Array<TextureAtlas>();
}