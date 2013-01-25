package com.haxepunk.graphics.atlas;

import nme.display.BitmapData;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.display.Tilesheet;
import nme.geom.Rectangle;
import nme.geom.Point;

class Layer
{
	public var data:Array<Float>;
	public var index:Int;
	public var dirty:Bool;

	public function new()
	{
		data = new Array<Float>();
		prepare();
	}

	public inline function prepare()
	{
		if (index < data.length)
		{
			data.splice(index, data.length - index);
		}
		index = 0; // reset index for next run
		dirty = false;
	}
}

class Atlas
{

	public var width(default, null):Int;
	public var height(default, null):Int;

	public static var drawCallThreshold:Int = 25000;
	public static var smooth:Bool = false;

	public function new(bd:BitmapData)
	{
		_layers = new IntHash<Layer>();
		_tilesheet = new Tilesheet(bd);

		width = bd.width;
		height = bd.height;

		_renderFlags = Tilesheet.TILE_TRANS_2x2 | Tilesheet.TILE_ALPHA | Tilesheet.TILE_BLEND_NORMAL | Tilesheet.TILE_RGB;

		_atlases.push(this);
		_tileIndex = 0;
	}

	/**
	 * Renders the current TextureAtlas
	 * @param g the graphics context to draw in
	 * @param smooth if rendering should use antialiasing
	 */
	public inline function render()
	{
		var l:Layer;

		for (layer in _layers.keys())
		{
			l = _layers.get(layer);
			// check that we have something to draw
			if (l.dirty)
			{
				l.prepare();
				getSpriteByLayer(layer).graphics.drawTiles(_tilesheet, l.data, smooth, _renderFlags);
			}
		}
	}

	public static inline function clear()
	{
		for (sprite in _sprites)
		{
			sprite.graphics.clear();
		}
	}

	/**
	 * Called by the current World to draw all TextureAtlas
	 */
	public static inline function renderAll()
	{
		if (_atlases.length > 0)
		{
			for (atlas in _atlases)
			{
				atlas.render();
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
	public function prepareTile(tile:Int, x:Float, y:Float, layer:Int,
		scaleX:Float, scaleY:Float, angle:Float,
		red:Float, green:Float, blue:Float, alpha:Float)
	{
		if (_layerIndex != layer) setLayer(layer);
		var d = _layer.data;
		_layer.dirty = true;

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

		if (_layer.index > drawCallThreshold)
		{
			_layer.prepare();
			getSpriteByLayer(layer).graphics.drawTiles(_tilesheet, _layer.data, smooth, _renderFlags);
		}
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
			var idx = 0;
			for (l in _sprites.keys())
			{
				if (l < layer) break;
				idx += 1;
			}
			_sprites.set(layer, sprite);
			HXP.stage.addChildAt(sprite, idx);
			return sprite;
		}
	}

	/**
	 * Creates a new AtlasRegion and assigns it to a name
	 * @param name the region name to create
	 * @param rect defines the rectangle of the tile on the tilesheet
	 * @param center positions the local center point to pivot on
	 */
	public inline function createRegion(rect:Rectangle, ?center:Point):AtlasRegion
	{
		_tilesheet.addTileRect(rect, center);
		var region = new AtlasRegion(this, _tileIndex, rect);
		_tileIndex += 1;
		return region;
	}

	private var _tileIndex:Int;
	private var _tilesheet:Tilesheet;
	private var _layerIndex:Int;
	private var _layer:Layer; // current layer
	private var _layers:IntHash<Layer>;
	private var _renderFlags:Int;

	private static var _atlases:Array<Atlas> = new Array<Atlas>();
	private static var _sprites:IntHash<Sprite> = new IntHash<Sprite>();

}