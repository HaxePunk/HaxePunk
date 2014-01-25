package com.haxepunk.graphics.atlas;

import com.haxepunk.Scene;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;
import openfl.display.Tilesheet;

class AtlasData
{

	public var width(default, null):Int;
	public var height(default, null):Int;

	public static inline var BLEND_NONE:Int = -1;
	public static inline var BLEND_ADD:Int = Tilesheet.TILE_BLEND_ADD;
	public static inline var BLEND_NORMAL:Int = Tilesheet.TILE_BLEND_NORMAL;

	/**
	 * Creates a new AtlasData object
	 * @param	source	The image to initialize AtlasData with
	 * @return	An AtlasData object
	 */
	public static function create(source:Dynamic):AtlasData
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
			data = getAtlasDataByName(source, true);
		}

		if (data != null)
		{
			data._refCount += 1;
		}

		return data;
	}

	/**
	 * Get's the atlas data for a specific texture, useful for setting rendering flags
	 * @param	name	The name of the image file
	 * @return	An AtlasData object (will create one if it doesn't already exist)
	 */
	public static inline function getAtlasDataByName(name:String, create:Bool=false):AtlasData
	{
		var data:AtlasData = null;
		if (_dataPool.exists(name))
		{
			data = _dataPool.get(name);
		}
		else if(create)
		{
			var bitmap:BitmapData = HXP.getBitmap(name);
			if (bitmap != null)
			{
				data = new AtlasData(bitmap);
				data._name = name;
				_dataPool.set(name, data);
			}
		}
		return data;
	}

	private function new(bd:BitmapData)
	{
		_data = new Array<Float>();

		_tilesheet = new Tilesheet(bd);

		_renderFlags = Tilesheet.TILE_TRANS_2x2 | Tilesheet.TILE_ALPHA | Tilesheet.TILE_BLEND_NORMAL | Tilesheet.TILE_RGB;
		_flagAlpha = true;
		_flagRGB = true;

		width = bd.width;
		height = bd.height;

		_refCount = 0;
		_layerIndex = -1;
		_atlases.push(this);
	}

	/**
	 * Sets the scene object
	 * @param	scene	The scene object to set
	 */
	public static inline function startScene(scene:Scene)
	{
		_scene = scene;
		_scene.sprite.graphics.clear();
	}

	public static inline function endScene()
	{
		if (_lastAtlas != null)
			_lastAtlas.flush();
		_lastAtlas = null;
	}

	/**
	 * Removes the object from memory
	 */
	public function destroy()
	{
		_refCount -= 1;
		if (_refCount <= 0)
		{
			HXP.removeBitmap(this._name);
			_dataPool.remove(this._name);
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
	 * Creates a new AtlasRegion
	 * @param	rect	Defines the rectangle of the tile on the tilesheet
	 * @param	center	Positions the local center point to pivot on
	 *
	 * @return The new AtlasRegion object.
	 */
	public inline function createRegion(rect:Rectangle, ?center:Point):AtlasRegion
	{
		var r = rect.clone();
		var p = center != null ? new Point(center.x, center.y) : null;
		var tileIndex = _tilesheet.addTileRect(r, p);
		return new AtlasRegion(this, tileIndex, rect);
	}

	public inline function flush()
	{
		if (_dataIndex != 0)
		{
			if (_dataIndex < _data.length)
			{
				_data.splice(_dataIndex, _data.length - _dataIndex);
			}
			_dataIndex = 0;
			_tilesheet.drawTiles(_scene.sprite.graphics, _data, Atlas.smooth, _renderFlags);
		}
	}

	/**
	 * Performs several checks to see if data needs to be flushed to drawTiles
	 * @param layer The layer to check
	 */
	private inline function checkForFlush(layer:Int)
	{
		if (_lastAtlas != this)
		{
			if (_lastAtlas != null)
				_lastAtlas.flush();
			_lastAtlas = this;
		}
		else if (_layerIndex != layer)
		{
			flush();
			_layerIndex = layer;
		}
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
		checkForFlush(layer);

		_data[_dataIndex++] = tx;
		_data[_dataIndex++] = ty;
		_data[_dataIndex++] = tile;

		// matrix transformation
		_data[_dataIndex++] = a; // m00
		_data[_dataIndex++] = b; // m10
		_data[_dataIndex++] = c; // m01
		_data[_dataIndex++] = d; // m11

		// color
		if (_flagRGB)
		{
			_data[_dataIndex++] = red;
			_data[_dataIndex++] = green;
			_data[_dataIndex++] = blue;
		}
		if (_flagAlpha)
		{
			_data[_dataIndex++] = alpha;
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
		checkForFlush(layer);

		_data[_dataIndex++] = x;
		_data[_dataIndex++] = y;
		_data[_dataIndex++] = tile;

		// matrix transformation
		if (angle == 0)
		{
			// fast defaults for non-rotated tiles (cos=1, sin=0)
			_data[_dataIndex++] = scaleX; // m00
			_data[_dataIndex++] = 0; // m01
			_data[_dataIndex++] = 0; // m10
			_data[_dataIndex++] = scaleY; // m11
		}
		else
		{
			var cos = Math.cos(-angle * HXP.RAD);
			var sin = Math.sin(-angle * HXP.RAD);
			_data[_dataIndex++] = cos * scaleX; // m00
			_data[_dataIndex++] = -sin * scaleY; // m10
			_data[_dataIndex++] = sin * scaleX; // m01
			_data[_dataIndex++] = cos * scaleY; // m11
		}

		if (_flagRGB)
		{
			_data[_dataIndex++] = red;
			_data[_dataIndex++] = green;
			_data[_dataIndex++] = blue;
		}
		if (_flagAlpha)
		{
			_data[_dataIndex++] = alpha;
		}
	}

	/**
	 * Sets the render flag to enable/disable alpha
	 * Default: true
	 */
	public var alpha(get_alpha, set_alpha):Bool;
	private function get_alpha():Bool { return (_renderFlags & Tilesheet.TILE_ALPHA != 0); }
	private function set_alpha(value:Bool):Bool
	{
		if (value) _renderFlags |= Tilesheet.TILE_ALPHA;
		else _renderFlags &= ~Tilesheet.TILE_ALPHA;
		_flagAlpha = value;
		return value;
	}

	/**
	 * Sets the render flag to enable/disable rgb tinting
	 * Default: true
	 */
	public var rgb(get_rgb, set_rgb):Bool;
	private function get_rgb():Bool { return (_renderFlags & Tilesheet.TILE_RGB != 0); }
	private function set_rgb(value:Bool)
	{
		if (value) _renderFlags |= Tilesheet.TILE_RGB;
		else _renderFlags &= ~Tilesheet.TILE_RGB;
		_flagRGB = value;
		return value;
	}

	/**
	 * Sets the blend mode for rendering (BLEND_NONE, BLEND_NORMAL, BLEND_ADD)
	 * Default: BLEND_NORMAL
	 */
	public var blend(get_blend, set_blend):Int;
	private function get_blend():Int {
		if (_renderFlags & Tilesheet.TILE_BLEND_NORMAL != 0)
			return BLEND_NORMAL;
		else if (_renderFlags & Tilesheet.TILE_BLEND_ADD != 0)
			return BLEND_ADD;
		else
			return BLEND_NONE;
	}
	private function set_blend(value:Int):Int
	{
		switch (value)
		{
			case BLEND_NONE:
				_renderFlags &= ~Tilesheet.TILE_BLEND_ADD;
				_renderFlags &= ~Tilesheet.TILE_BLEND_NORMAL;
			case BLEND_ADD:
				_renderFlags |= Tilesheet.TILE_BLEND_ADD;
				_renderFlags &= ~Tilesheet.TILE_BLEND_NORMAL;
			case BLEND_NORMAL:
				_renderFlags &= ~Tilesheet.TILE_BLEND_ADD;
				_renderFlags |= Tilesheet.TILE_BLEND_NORMAL;
		}
		return value;
	}


	// used for pooling
	private var _name:String;
	private var _refCount:Int = 0; // memory management

	private var _layerIndex:Int = 0;

	private var _renderFlags:Int;
	private var _flagRGB:Bool;
	private var _flagAlpha:Bool;

	private var _tilesheet:Tilesheet;
	private var _data:Array<Float>;
	private var _dataIndex:Int = 0;

	private static var _scene:Scene;
	private static var _lastAtlas:AtlasData;
	private static var _dataPool:Map<String,AtlasData> = new Map<String,AtlasData>();
	private static var _atlases:Array<AtlasData> = new Array<AtlasData>();
}
