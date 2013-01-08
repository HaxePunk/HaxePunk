package com.haxepunk.graphics.atlas;

import nme.display.BitmapData;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.display.Tilesheet;

class Atlas
{

	public var width(default, null):Int;
	public var height(default, null):Int;

	public function new(bd:BitmapData)
	{
		_tileData = new IntHash<Array<Float>>();
		_tilesheet = new Tilesheet(bd);

		width = bd.width;
		height = bd.height;

		_renderFlags = Tilesheet.TILE_TRANS_2x2 | Tilesheet.TILE_ALPHA | Tilesheet.TILE_BLEND_NORMAL | Tilesheet.TILE_RGB;

		_atlases.push(this);
	}

	/**
	 * Renders the current TextureAtlas
	 * @param g the graphics context to draw in
	 * @param smooth if rendering should use antialiasing
	 */
	public inline function render(smooth:Bool=false)
	{
		var g:Graphics;
		var td:Array<Float>;

		for (layer in _tileData.keys())
		{
			td = _tileData.get(layer);
			g = getSpriteByLayer(layer).graphics;
			// check that we have something to draw
			if (td.length > 0)
			{
				g.drawTiles(_tilesheet, td, smooth, _renderFlags);
				HXP.clear(td);
			}
		}
	}

	/**
	 * Called by the current World to draw all TextureAtlas
	 * @param smooth if rendering should use antialiasing
	 */
	public static inline function renderAll(smooth:Bool=false)
	{
		for (sprite in _sprites)
		{
			sprite.graphics.clear();
		}

		if (_atlases.length > 0)
		{
			for (atlas in _atlases)
			{
				atlas.render(smooth);
			}
		}
	}

	/**
	 * Prepares tile data for rendering
	 * @param tile the tile index of the tilesheet
	 * @param x the x-axis location to draw the tile
	 * @param y the y-axis location to draw the tile
	 * @param layer the layer to draw on
	 * @param scaleX the scale value for the x-axis
	 * @param scaleY the scale value for the y-axis
	 * @param angle an angle to rotate the tile
	 * @param red a red tint value
	 * @param green a green tint value
	 * @param blue a blue tint value
	 * @param alpha the tile's opacity
	 */
	public inline function prepareTile(tile:Int, x:Float, y:Float, layer:Int,
		scaleX:Float, scaleY:Float, angle:Float,
		red:Float, green:Float, blue:Float, alpha:Float)
	{
		var t:Array<Float>;
		if (_tileData.exists(layer))
		{
			t = _tileData.get(layer);
		}
		else
		{
			t = new Array<Float>();
			_tileData.set(layer, t);
		}
		var i:Int = t.length;

		t[i++] = x;
		t[i++] = y;
		t[i++] = tile;

		// matrix transformation
		var thetaCos = Math.cos(angle * HXP.RAD);
		var thetaSin = Math.sin(angle * HXP.RAD);
		t[i++] = thetaCos * scaleX; // m00
		t[i++] = thetaSin * scaleX; // m01
		t[i++] = -thetaSin * scaleY; // m10
		t[i++] = thetaCos * scaleY; // m11

		t[i++] = red;
		t[i++] = green;
		t[i++] = blue;
		t[i++] = alpha;
	}

	private static inline function getSpriteByLayer(layer:Int):Sprite
	{
		if (_sprites.exists(layer))
		{
			return _sprites.get(layer);
		}
		else
		{
			var sprite = new Sprite();
			_sprites.set(layer, sprite);
			HXP.engine.addChildAt(sprite, 0);
			return sprite;
		}
	}

	private var _tilesheet:Tilesheet;
	private var _tileData:IntHash<Array<Float>>;
	private var _renderFlags:Int;

	private static var _atlases:Array<Atlas> = new Array<Atlas>();
	private static var _sprites:IntHash<Sprite> = new IntHash<Sprite>();

}