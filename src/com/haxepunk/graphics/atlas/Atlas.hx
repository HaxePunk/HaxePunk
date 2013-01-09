package com.haxepunk.graphics.atlas;

import nme.display.BitmapData;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.display.Tilesheet;

class Layer
{
	public var data:Array<Float>;
	public var index:Int;

	public function new()
	{
		data = new Array<Float>();
		index = 0;
	}

	public inline function prepare()
	{
		if (index < data.length)
		{
			data.splice(index, data.length - index);
		}
		index = 0; // reset index for next run
	}
}

class Atlas
{

	public var width(default, null):Int;
	public var height(default, null):Int;

	public function new(bd:BitmapData)
	{
		_layers = new IntHash<Layer>();
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
		var l:Layer;

		for (layer in _layers.keys())
		{
			l = _layers.get(layer);
			// check that we have something to draw
			if (l.index > 0)
			{
				l.prepare();
				g = getSpriteByLayer(layer).graphics;
				g.drawTiles(_tilesheet, l.data, smooth, _renderFlags);
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

	public inline function setLayer(layer:Int)
	{
		if (_layers.exists(layer))
		{
			_layer = _layers.get(layer);
		}
		else
		{
			_layer = new Layer();
			_layers.set(layer, _layer);
		}
		_layerIndex = layer;
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
		if (_layerIndex != layer) setLayer(layer);
		var d = _layer.data;

		d[_layer.index++] = x;
		d[_layer.index++] = y;
		d[_layer.index++] = tile;

		// matrix transformation
		if (angle == 0)
		{
			// fast defaults for non-rotated tiles (cos=1, sin=0)
			d[_layer.index++] = scaleX; // m00
			d[_layer.index++] = 0; // m01
			d[_layer.index++] = 0; // m10
			d[_layer.index++] = scaleY; // m11
		}
		else
		{
			var cos = Math.cos(angle * HXP.RAD);
			var sin = Math.sin(angle * HXP.RAD);
			d[_layer.index++] = cos * scaleX; // m00
			d[_layer.index++] = sin * scaleX; // m01
			d[_layer.index++] = -sin * scaleY; // m10
			d[_layer.index++] = cos * scaleY; // m11
		}

		d[_layer.index++] = red;
		d[_layer.index++] = green;
		d[_layer.index++] = blue;
		d[_layer.index++] = alpha;
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
	private var _layerIndex:Int;
	private var _layer:Layer; // current layer
	private var _layers:IntHash<Layer>;
	private var _renderFlags:Int;

	private static var _atlases:Array<Atlas> = new Array<Atlas>();
	private static var _sprites:IntHash<Sprite> = new IntHash<Sprite>();

}