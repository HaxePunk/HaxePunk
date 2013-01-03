package com.haxepunk.graphics.atlas;

import com.haxepunk.HXP;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.display.Sprite;
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

		if (sprite == null)
		{
			sprite = new Sprite();
			HXP.engine.addChildAt(sprite, 0);
		}

		_tilesheet = new Tilesheet(bd);
		_regions = new Hash<AtlasRegion>();
		_index = 0;

		_renderFlags = Tilesheet.TILE_TRANS_2x2 | Tilesheet.TILE_ALPHA | Tilesheet.TILE_BLEND_NORMAL | Tilesheet.TILE_RGB;
		_tileData = new Array<Float>();

		_atlases.push(this);
	}

	/**
	 * Loads a TexturePacker xml file and generates all tile regions
	 * @param file the TexturePacker file to load
	 */
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

	/**
	 * Renders the current TextureAtlas
	 * @param g the graphics context to draw in
	 * @param smooth if rendering should use antialiasing
	 */
	public inline function render(g:Graphics, smooth:Bool=false)
	{
		// check that we have something to draw
		if (_tileData.length > 0)
		{
			g.drawTiles(_tilesheet, _tileData, smooth, _renderFlags);
			// clear tile data
#if (cpp || php)
			_tileData.splice(0,_tileData.length);
#else
			untyped _tileData.length = 0;
#end
		}
	}

	/**
	 * Called by the current World to draw all TextureAtlas
	 * @param smooth if rendering should use antialiasing
	 */
	public static inline function renderAll(smooth:Bool=false)
	{
		if (_atlases.length > 0)
		{
			sprite.graphics.clear(); // clear sprite
			for (atlas in _atlases)
			{
				atlas.render(sprite.graphics, smooth);
			}
		}
	}

	/**
	 * Prepares tile data for rendering
	 * @param tile the tile index of the tilesheet
	 * @param x the x-axis location to draw the tile
	 * @param y the y-axis location to draw the tile
	 * @param scaleX the scale value for the x-axis
	 * @param scaleY the scale value for the y-axis
	 * @param angle an angle to rotate the tile
	 * @param red a red tint value
	 * @param green a green tint value
	 * @param blue a blue tint value
	 * @param alpha the tile's opacity
	 */
	public inline function prepareTile(tile:Int, x:Float, y:Float,
		scaleX:Float, scaleY:Float, angle:Float,
		red:Float, green:Float, blue:Float, alpha:Float)
	{
		_tileData.push(x);
		_tileData.push(y);
		_tileData.push(tile);

		// matrix transformation
		var thetaCos = Math.cos(angle * HXP.RAD);
		var thetaSin = Math.sin(angle * HXP.RAD);
		_tileData.push(thetaCos * scaleX); // m00
		_tileData.push(thetaSin * scaleX); // m01
		_tileData.push(-thetaSin * scaleY); // m10
		_tileData.push(thetaCos * scaleY); // m11

		_tileData.push(red);
		_tileData.push(green);
		_tileData.push(blue);
		_tileData.push(alpha);
	}

	/**
	 * Gets an atlas region based on an identifier
	 * @param name the name identifier of the region to retrieve
	 */
	public function getRegion(name:String):AtlasRegion
	{
		if (_regions.exists(name))
			return _regions.get(name);
		throw "Region has not be defined yet: " + name;
	}

	/**
	 * Creates a new AtlasRegion and assigns it to a name
	 * @param name the region name to create
	 * @param rect defines the rectangle of the tile on the tilesheet
	 * @param center positions the local center point to pivot on
	 */
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
	private static var sprite:Sprite = null;
}