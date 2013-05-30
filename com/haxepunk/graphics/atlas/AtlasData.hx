package com.haxepunk.graphics.atlas;

import com.haxepunk.Scene;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;
#if nme
import nme.display.Tilesheet;
#else
import openfl.display.Tilesheet;
#end

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

class AtlasData
{

	public var width(default, null):Int;
	public var height(default, null):Int;

	/**
	 * Creates a new AtlasData object
	 * @param  source The image to initialize AtlasData with
	 * @return        An AtlasData object
	 */
	public static inline function create(source:Dynamic):AtlasData
	{
		var data:AtlasData;
		if (Std.is(source, BitmapData))
		{
#if debug
			HXP.log("Atlases using BitmapData will not be managed.");
#end
			data = new AtlasData(source);
		}
		else
		{
			if (_dataPool.exists(source))
			{
				data = _dataPool.get(source);
				data._refCount += 1;
			}
			else
			{
				data = new AtlasData(HXP.getBitmap(source));
				data._name = source;
				_dataPool.set(source, data);
			}
		}
		return data;
	}

	private function new(bd:BitmapData)
	{
#if haxe3
		_layers = new Map<Int,Layer>();
#else
		_layers = new IntHash<Layer>();
#end

		_tilesheet = new Tilesheet(bd);
		_renderFlags = Tilesheet.TILE_TRANS_2x2 | Tilesheet.TILE_ALPHA | Tilesheet.TILE_BLEND_NORMAL | Tilesheet.TILE_RGB;

		width = bd.width;
		height = bd.height;

		_tileIndex = 0;
		_refCount = 1;
		_layerIndex = -1;
		_atlases.push(this);
	}

	/**
	 * Sets the scene object
	 * @param scene The scene object to set
	 */
	public static inline function setScene(scene:Scene)
	{
		_scene = scene;
	}

	/**
	 * Called by the current Scene to draw all TextureAtlas
	 */
	public static inline function render()
	{
		if (_atlases.length > 0)
		{
			for (atlas in _atlases)
			{
				atlas.renderData();
			}
		}
	}

	/**
	 * Renders the current TextureAtlas
	 * @param g the graphics context to draw in
	 * @param smooth if rendering should use antialiasing
	 */
	private inline function renderData()
	{
		var l:Layer;

		for (layer in _layers.keys())
		{
			l = _layers.get(layer);
			// check that we have something to draw
			if (l.dirty)
			{
				renderLayer(l, layer);
			}
		}
	}

	/**
	 * Removes the object from memory
	 */
	public function destroy()
	{
		_refCount -= 1;
		if (_refCount < 0)
		{
			_atlases.remove(this);
		}
	}

	/**
	 * Removes all atlases from the display list
	 */
	public static function destroyAll()
	{
		for (atlas in _atlases)
		{
			atlas.destroy();
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

	private inline function renderLayer(layer:Layer, layerIndex:Int)
	{
		layer.prepare();
		_tilesheet.drawTiles(_scene.getSpriteByLayer(layerIndex).graphics, layer.data, Atlas.smooth, _renderFlags);
	}

	private inline function setLayer(layer:Int)
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
	 * Prepares a tile to be drawn using a matrix
	 * @param  tile  The tile index to draw
	 * @param  layer The layer to draw on
	 * @param  tx    X-Axis translation
	 * @param  ty    Y-Axis translation
	 * @param  a     Top-left
	 * @param  b     Top-right
	 * @param  c     Bottom-left
	 * @param  d     Bottom-right
	 * @param  red   Red color value
	 * @param  green Green color value
	 * @param  blue  Blue color value
	 * @param  alpha Alpha value
	 */
	public inline function prepareTileMatrix(tile:Int, layer:Int,
		tx:Float, ty:Float, a:Float, b:Float, c:Float, d:Float,
		red:Float, green:Float, blue:Float, alpha:Float)
	{
		if (_layerIndex != layer) setLayer(layer);
		var data = _layer.data;
		_layer.dirty = true;

		data[_layer.index++] = tx;
		data[_layer.index++] = ty;
		data[_layer.index++] = tile;

		// matrix transformation
		data[_layer.index++] = a; // m00
		data[_layer.index++] = c; // m01
		data[_layer.index++] = b; // m10
		data[_layer.index++] = d; // m11

		data[_layer.index++] = red;
		data[_layer.index++] = green;
		data[_layer.index++] = blue;
		data[_layer.index++] = alpha;

		if (_layer.index > Atlas.drawCallThreshold)
		{
			renderLayer(_layer, layer);
		}
	}

	/**
	 * Prepares a tile to be drawn
	 * @param  tile   The tile index to draw
	 * @param  x      The x-axis value
	 * @param  y      The y-axis value
	 * @param  layer  The layer to draw on
	 * @param  scaleX X-Axis scale
	 * @param  scaleY Y-Axis scale
	 * @param  angle  Angle (in degrees)
	 * @param  red    Red color value
	 * @param  green  Green color value
	 * @param  blue   Blue color value
	 * @param  alpha  Alpha value
	 */
	public inline function prepareTile(tile:Int, x:Float, y:Float, layer:Int,
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
			var cos = Math.cos(-angle * HXP.RAD);
			var sin = Math.sin(-angle * HXP.RAD);
			d[_layer.index++] = cos * scaleX; // m00
			d[_layer.index++] = sin * scaleX; // m01
			d[_layer.index++] = -sin * scaleY; // m10
			d[_layer.index++] = cos * scaleY; // m11
		}

		d[_layer.index++] = red;
		d[_layer.index++] = green;
		d[_layer.index++] = blue;
		d[_layer.index++] = alpha;

		if (_layer.index > Atlas.drawCallThreshold)
		{
			renderLayer(_layer, layer);
		}
	}

	// used for pooling
	private var _name:String;
	private var _refCount:Int; // memory management

	private var _layerIndex:Int;
	private var _layer:Layer; // current layer
	private var _renderFlags:Int;
	private var _tileIndex:Int;
	private var _tilesheet:Tilesheet;
#if haxe3
	private var _layers:Map<Int,Layer>;
#else
	private var _layers:IntHash<Layer>;
#end

	private static var _scene:Scene;
#if haxe3
	private static var _dataPool:Map<String,AtlasData> = new Map<String,AtlasData>();
#else
	private static var _dataPool:Hash<AtlasData> = new Hash<AtlasData>();
#end
	private static var _atlases:Array<AtlasData> = new Array<AtlasData>();
}
