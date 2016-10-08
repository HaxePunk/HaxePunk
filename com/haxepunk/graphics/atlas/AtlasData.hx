package com.haxepunk.graphics.atlas;

import com.haxepunk.Scene;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;

/**
 * Abstract representing either a `String`, a `AtlasData` or a `BitmapData`.
 * 
 * Conversion is automatic, no need to use this.
 */
abstract AtlasDataType(AtlasData)
{
	private inline function new(data:AtlasData) this = data;
	@:dox(hide) @:to public inline function toAtlasData():AtlasData return this;

	@:dox(hide) @:from public static inline function fromString(s:String)
	{
		return new AtlasDataType(AtlasData.getAtlasDataByName(s, true));
	}
	@:dox(hide) @:from public static inline function fromBitmapData(bd:BitmapData)
	{
		return new AtlasDataType(new AtlasData(bd));
	}
	@:dox(hide) @:from public static inline function fromAtlasData(data:AtlasData)
	{
		return new AtlasDataType(data);
	}
}

class AtlasData
{
	public var renderer:Renderer;

	public var width(default, null):Int;
	public var height(default, null):Int;
	public var bitmapData:BitmapData;

	public static inline var BLEND_NONE:Int = 0;
	public static inline var BLEND_ADD:Int = Tilesheet.TILE_BLEND_ADD;
	public static inline var BLEND_NORMAL:Int = Tilesheet.TILE_BLEND_NORMAL;
#if flash
	public static inline var BLEND_MULTIPLY:Int = BLEND_NONE;
	public static inline var BLEND_SCREEN:Int = BLEND_NONE;
#else
	public static inline var BLEND_MULTIPLY:Int = Tilesheet.TILE_BLEND_MULTIPLY;
	public static inline var BLEND_SCREEN:Int = Tilesheet.TILE_BLEND_SCREEN;
#end

	/**
	 * Creates a new AtlasData class
	 * 
	 * **NOTE**: Only create one instace of AtlasData per name. An error will be thrown if you try to create a duplicate.
	 * 
	 * @param bd     BitmapData image to use for rendering
	 * @param name   A reference to the image data, used with destroy and for setting rendering flags
	 */
	public function new(bd:BitmapData, ?name:String, ?flags:Int)
	{
		bitmapData = bd;

		_data = new Array<Float>();
		_smoothData = new Array<Float>();
		_dataIndex = _smoothDataIndex = 0;

		_name = name;

		if (_name != null)
		{
			if (_dataPool.exists(_name))
			{
				throw 'Cannot cache duplicate AtlasData with the name "$_name"';
			}
			else
			{
				_dataPool.set(_name, this);
			}
		}

		_renderFlags = Tilesheet.TILE_TRANS_2X2 | Tilesheet.TILE_ALPHA | Tilesheet.TILE_BLEND_NORMAL | Tilesheet.TILE_RGB | Tilesheet.TILE_RECT;

		width = bd.width;
		height = bd.height;

		renderer = new Renderer(this);
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
		else if (create)
		{
			var bitmap:BitmapData = HXP.getBitmap(name);
			if (bitmap != null)
			{
				data = new AtlasData(bitmap, name);
			}
		}
		return data;
	}

	/**
	 * String representation of AtlasData
	 * @return the name of the AtlasData
	 */
	public function toString():String
	{
		return (_name == null ? "AtlasData" : _name); 
	}

	/**
	 * Reloads the image for a particular atlas object
	 */
	public function reload(bd:BitmapData):Bool
	{
		if (_name != null)
		{
			bitmapData = bd;
			return HXP.overwriteBitmapCache(_name, bd);
		}
		return false;
	}

	/**
	 * Sets the scene object
	 * @param	scene	The scene object to set
	 */
	@:allow(com.haxepunk.Scene)
	private static inline function startScene(scene:Scene):Void
	{
		_scene = scene;
		_scene.sprite.graphics.clear();
	}

	/**
	 * The active atlas data object
	 */
	public static var active(default, set):AtlasData;
	private static inline function set_active(?value:AtlasData):AtlasData
	{
		if (active != value)
		{
			if (active != null)
				active.flush();
			active = value;
		}
		return value;
	}

	/**
	 * Removes the object from memory
	 */
	public function destroy():Void
	{
		if (_name != null)
		{
			HXP.removeBitmap(_name);
			_dataPool.remove(_name);
		}
	}

	/**
	 * Removes all atlases from the display list
	 */
	public static function destroyAll():Void
	{
		for (atlas in _dataPool)
		{
			atlas.destroy();
		}
	}

	/**
	 * Creates a new AtlasRegion
	 * @param	rect	Defines the rectangle of the tile on the tilesheet
	 * @param	center	Positions the local center point to pivot on (not used)
	 *
	 * @return The new AtlasRegion object.
	 */
	public inline function createRegion(rect:Rectangle, ?center:Point):AtlasRegion
	{
		return new AtlasRegion(this, rect.clone());
	}

	/**
	 * Flushes the renderable data array
	 */
	public inline function flush():Void
	{
		if (_dataIndex != 0)
		{
			renderer.drawTiles(_scene.sprite.graphics, _data, false, _renderFlags, _dataIndex);
			_dataIndex = 0;
		}

		if (_smoothDataIndex != 0)
		{
			renderer.drawTiles(_scene.sprite.graphics, _smoothData, true, _renderFlags, _smoothDataIndex);
			_smoothDataIndex = 0;
		}
	}

	/**
	 * Prepares a tile to be drawn using a matrix
	 * @param  rect   The source rectangle to draw
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
	public inline function prepareTileMatrix(rect:Rectangle, layer:Int,
		tx:Float, ty:Float, a:Float, b:Float, c:Float, d:Float,
		red:Float, green:Float, blue:Float, alpha:Float, ?smooth:Bool)
	{
		active = this;

		if (smooth == null) smooth = Atlas.smooth;

		var _data = smooth ? _smoothData : _data;
		var _dataIndex = smooth ? _smoothDataIndex : _dataIndex;

		// Destination point
		_data[_dataIndex++] = tx;
		_data[_dataIndex++] = ty;

		// Source rectangle
		_data[_dataIndex++] = rect.x;
		_data[_dataIndex++] = rect.y;
		_data[_dataIndex++] = rect.width;
		_data[_dataIndex++] = rect.height;

		// matrix transformation
		_data[_dataIndex++] = a; // m00
		_data[_dataIndex++] = b; // m10
		_data[_dataIndex++] = c; // m01
		_data[_dataIndex++] = d; // m11

		// color
		_data[_dataIndex++] = red;
		_data[_dataIndex++] = green;
		_data[_dataIndex++] = blue;
		_data[_dataIndex++] = alpha;

		if (smooth)
		{
			this._smoothDataIndex = _dataIndex;
		}
		else
		{
			this._dataIndex = _dataIndex;
		}
	}

	/**
	 * Prepares a tile to be drawn
	 * @param  rect   The source rectangle to draw
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
	public inline function prepareTile(rect:Rectangle, x:Float, y:Float, layer:Int,
		scaleX:Float, scaleY:Float, angle:Float,
		red:Float, green:Float, blue:Float, alpha:Float, ?smooth:Bool)
	{
		active = this;

		if (smooth == null) smooth = Atlas.smooth;

		var _data = smooth ? _smoothData : _data;
		var _dataIndex = smooth ? _smoothDataIndex : _dataIndex;

		// Destination point
		_data[_dataIndex++] = x;
		_data[_dataIndex++] = y;

		// Source rectangle
		_data[_dataIndex++] = rect.x;
		_data[_dataIndex++] = rect.y;
		_data[_dataIndex++] = rect.width;
		_data[_dataIndex++] = rect.height;

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

		_data[_dataIndex++] = red;
		_data[_dataIndex++] = green;
		_data[_dataIndex++] = blue;
		_data[_dataIndex++] = alpha;

		if (smooth)
		{
			this._smoothDataIndex = _dataIndex;
		}
		else
		{
			this._dataIndex = _dataIndex;
		}
	}

	/**
	 * Sets the blend mode for rendering (`BLEND_NONE`, `BLEND_NORMAL`, `BLEND_ADD`)
	 * Default: `BLEND_NORMAL`
	 */
	public var blend(get, set):Int;
	private function get_blend():Int
	{
		if (_renderFlags & Tilesheet.TILE_BLEND_NORMAL != 0)
			return BLEND_NORMAL;
		else if (_renderFlags & Tilesheet.TILE_BLEND_ADD != 0)
			return BLEND_ADD;
#if !flash
		else if (_renderFlags & Tilesheet.TILE_BLEND_MULTIPLY != 0)
			return BLEND_MULTIPLY;
		else if (_renderFlags & Tilesheet.TILE_BLEND_SCREEN != 0)
			return BLEND_SCREEN;
#end
		else
			return BLEND_NONE;
	}
	private function set_blend(value:Int):Int
	{
		// unset blend flags
		_renderFlags &= ~(BLEND_ADD | BLEND_SCREEN | BLEND_MULTIPLY | BLEND_NORMAL);

		// check that value is actually a blend flag
		if (value == BLEND_ADD ||
			value == BLEND_MULTIPLY ||
			value == BLEND_SCREEN ||
			value == BLEND_NORMAL)
		{
			// set the blend flag
			_renderFlags |= value;
			return value;
		}
		return BLEND_NONE;
	}

	// used for pooling
	private var _name:String;

	private var _layerIndex:Int = 0;

	private var _renderFlags:Int;

	private var _data:Array<Float>;
	private var _dataIndex:Int;
	private var _smoothData:Array<Float>;
	private var _smoothDataIndex:Int;

	private static var _scene:Scene;
	private static var _dataPool:Map<String, AtlasData> = new Map<String, AtlasData>();
	private static var _uniqueId:Int = 0; // allows for unique names
}
