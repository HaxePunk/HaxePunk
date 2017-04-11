package haxepunk.graphics.atlas;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;
import haxepunk.Scene;
import haxepunk.utils.MathUtil;

/**
 * Abstract representing either a `String`, a `AtlasData` or a `BitmapData`.
 *
 * Conversion is automatic, no need to use this.
 */
abstract AtlasDataType(AtlasData)
{
	inline function new(data:AtlasData) this = data;
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
	public var width(default, null):Int;
	public var height(default, null):Int;
	public var bitmapData:BitmapData;

	/**
	 * Creates a new AtlasData class
	 *
	 * **NOTE**: Only create one instance of AtlasData per name. An error will be thrown if you try to create a duplicate.
	 *
	 * @param bd     BitmapData image to use for rendering
	 * @param name   A reference to the image data, used with destroy and for setting rendering flags
	 */
	public function new(bd:BitmapData, ?name:String)
	{
		bitmapData = bd;

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
	public inline function toString():String
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
	@:allow(haxepunk.Scene)
	static inline function startScene(scene:Scene):Void
	{
		_scene = scene;
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
	public inline function prepareTileMatrix(
		rect:Rectangle, layer:Int,
		tx:Float, ty:Float, a:Float, b:Float, c:Float, d:Float,
		red:Float, green:Float, blue:Float, alpha:Float,
		?smooth:Bool, ?blend:BlendMode)
	{
		if (smooth == null) smooth = Atlas.smooth;
		var batch = _scene.sprite.batch;
		batch.addRect(bitmapData, smooth, blend, rect.x, rect.y, rect.width, rect.height, a, b, c, d, tx, ty, red, green, blue, alpha);
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
	public inline function prepareTile(
		rect:Rectangle, tx:Float, ty:Float, layer:Int,
		scaleX:Float, scaleY:Float, angle:Float,
		red:Float, green:Float, blue:Float, alpha:Float,
		?smooth:Bool, ?blend:BlendMode):Void
	{
		if (smooth == null) smooth = Atlas.smooth;

		var a:Float, b:Float, c:Float, d:Float;

		// matrix transformation
		if (angle == 0)
		{
			// fast defaults for non-rotated tiles (cos=1, sin=0)
			a = scaleX; // m00
			b = 0; // m01
			c = 0; // m10
			d = scaleY; // m11
		}
		else
		{
			var cos = Math.cos(-angle * MathUtil.RAD);
			var sin = Math.sin(-angle * MathUtil.RAD);
			a = cos * scaleX; // m00
			b = -sin * scaleY; // m10
			c = sin * scaleX; // m01
			d = cos * scaleY; // m11
		}

		var batch = _scene.sprite.batch;
		batch.addRect(bitmapData, smooth, blend, rect.x, rect.y, rect.width, rect.height, a, b, c, d, tx, ty, red, green, blue, alpha);
	}

	public function prepareTriangle(
		tx1:Float, ty1:Float, uvx1:Float, uvy1:Float,
		tx2:Float, ty2:Float, uvx2:Float, uvy2:Float,
		tx3:Float, ty3:Float, uvx3:Float, uvy3:Float,
		red:Float, green:Float, blue:Float, alpha:Float,
		?smooth:Bool, ?blend:BlendMode):Void
	{
		var batch = _scene.sprite.batch;
		batch.addTriangle(bitmapData, smooth, blend, tx1, ty1, uvx1, uvy1, tx2, ty2, uvx2, uvy2, tx3, ty3, uvx3, uvy3, red, green, blue, alpha);
	}

	// used for pooling
	var _name:String;

	static var _scene:Scene;
	static var _dataPool:Map<String, AtlasData> = new Map<String, AtlasData>();
	static var _uniqueId:Int = 0; // allows for unique names
	static var _rect:Rectangle = new Rectangle();
}
