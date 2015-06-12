package com.haxepunk.graphics.atlas;

import com.haxepunk.Scene;
import com.haxepunk.ds.Either;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;
import openfl.display.Tilesheet;

/**
 * Abstract representing either a `String`, a `AtlasData` or a `BitmapData`.
 * 
 * Conversion is automatic, no need to use this.
 */
abstract AtlasDataType(AtlasData)
{
	private inline function new(data:AtlasData) this = data;
	@:dox(hide) @:to public inline function toAtlasData():AtlasData return this;

	@:dox(hide) @:from public static inline function fromString(s:String) {
		return new AtlasDataType(AtlasData.getAtlasDataByName(s, true));
	}
	@:dox(hide) @:from public static inline function fromBitmapData(bd:BitmapData) {
		return new AtlasDataType(new AtlasData(bd));
	}
	@:dox(hide) @:from public static inline function fromAtlasData(data:AtlasData) {
		return new AtlasDataType(data);
	}
}

class AtlasData
{

	public var width(default, null):Int;
	public var height(default, null):Int;
	
	public var isRGB:Bool;
	public var isAlpha:Bool;

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
		_tilesheet = new Tilesheet(bd);
		_name = name;

		if(_name != null)
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

		isAlpha = true;
		isRGB = true;

		width = bd.width;
		height = bd.height;
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
		if(_name != null)
			return HXP.overwriteBitmapCache(_name, bd);
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
	
	@:allow(com.haxepunk.Scene)
	private static inline function drawScene(scene:Scene):Void
	{
		DrawState.drawStates(scene);
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
		if (smooth == null) smooth = Atlas.smooth;
		
		var state:DrawState = DrawState.getDrawState(_tilesheet, isRGB, isAlpha, smooth, blend);
		var data:Array<Float> = state.data;
		var dataIndex:Int = state.dataIndex;
		
		// Destination point
		data[dataIndex++] = tx;
		data[dataIndex++] = ty;

		// Source rectangle
		data[dataIndex++] = rect.x;
		data[dataIndex++] = rect.y;
		data[dataIndex++] = rect.width;
		data[dataIndex++] = rect.height;

		// matrix transformation
		data[dataIndex++] = a; // m00
		data[dataIndex++] = b; // m10
		data[dataIndex++] = c; // m01
		data[dataIndex++] = d; // m11

		// color
		if (isRGB)
		{
			data[dataIndex++] = red;
			data[dataIndex++] = green;
			data[dataIndex++] = blue;
		}
		if (isAlpha)
		{
			data[dataIndex++] = alpha;
		}
		
		state.dataIndex = dataIndex;
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
		if (smooth == null) smooth = Atlas.smooth;

		var state:DrawState = DrawState.getDrawState(_tilesheet, isRGB, isAlpha, smooth, blend);
		var data:Array<Float> = state.data;
		var dataIndex:Int = state.dataIndex;
		
		// Destination point
		data[dataIndex++] = x;
		data[dataIndex++] = y;

		// Source rectangle
		data[dataIndex++] = rect.x;
		data[dataIndex++] = rect.y;
		data[dataIndex++] = rect.width;
		data[dataIndex++] = rect.height;

		// matrix transformation
		if (angle == 0)
		{
			// fast defaults for non-rotated tiles (cos=1, sin=0)
			data[dataIndex++] = scaleX; // m00
			data[dataIndex++] = 0; // m01
			data[dataIndex++] = 0; // m10
			data[dataIndex++] = scaleY; // m11
		}
		else
		{
			var rad = -angle * HXP.RAD;
			var cos = Math.cos(rad);
			var sin = Math.sin(rad);
			data[dataIndex++] = cos * scaleX; // m00
			data[dataIndex++] = -sin * scaleY; // m10
			data[dataIndex++] = sin * scaleX; // m01
			data[dataIndex++] = cos * scaleY; // m11
		}

		if (isRGB)
		{
			data[dataIndex++] = red;
			data[dataIndex++] = green;
			data[dataIndex++] = blue;
		}
		if (isAlpha)
		{
			data[dataIndex++] = alpha;
		}
		
		state.dataIndex = dataIndex;
	}

	/**
	 * Sets the blend mode for rendering (`BLEND_NONE`, `BLEND_NORMAL`, `BLEND_ADD`)
	 * Default: `BLEND_NORMAL`
	 */
	public var blend(default, set):Int = 0;
	private function set_blend(value:Int):Int
	{
		// check that value is actually a blend flag
		if (value == BLEND_ADD ||
			value == BLEND_MULTIPLY ||
			value == BLEND_SCREEN ||
			value == BLEND_NORMAL)
		{
			// set the blend flag
			blend = value;
		}
		
		return blend;
	}
	
	// used for pooling
	private var _name:String;

	private var _layerIndex:Int = 0;

	private var _tilesheet:Tilesheet;

	private static var _scene:Scene;
	private static var _dataPool:Map<String, AtlasData> = new Map<String, AtlasData>();
	private static var _uniqueId:Int = 0; // allows for unique names
}
