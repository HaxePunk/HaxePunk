package com.haxepunk;

import com.haxepunk.graphics.atlas.Atlas;
import com.haxepunk.graphics.Image;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.filters.BitmapFilter;
import flash.geom.Matrix;

/**
 * Container for the main screen buffer. Can be used to transform the screen.
 */
class Screen
{
	/**
	 * Constructor.
	 */
	public function new()
	{
		_sprite = new Sprite();
		_bitmap = new Array<Bitmap>();
		init();
	}

	public function init()
	{
		x = y = originX = originY = 0;
		_angle = _current = 0;
		scale = scaleX = scaleY = 1;
		_color = 0;
		update();

		// create screen buffers
		if (HXP.engine.contains(_sprite))
		{
			HXP.engine.removeChild(_sprite);
		}
		if (HXP.renderMode == RenderMode.BUFFER)
		{
			HXP.engine.addChild(_sprite);
		}
	}

	private inline function disposeBitmap(bd:Bitmap)
	{
		if (bd != null)
		{
			_sprite.removeChild(bd);
			bd.bitmapData.dispose();
		}
	}

	/**
	 * Resizes the screen by recreating the bitmap buffer.
	 */
	public function resize()
	{
		width = HXP.width;
		height = HXP.height;

		if (HXP.renderMode == RenderMode.BUFFER)
		{
			disposeBitmap(_bitmap[0]);
			disposeBitmap(_bitmap[1]);

			_bitmap[0] = new Bitmap(HXP.createBitmap(width, height, true), PixelSnapping.NEVER);
			_bitmap[1] = new Bitmap(HXP.createBitmap(width, height, true), PixelSnapping.NEVER);

			_sprite.addChild(_bitmap[0]).visible = true;
			_sprite.addChild(_bitmap[1]).visible = false;
			HXP.buffer = _bitmap[0].bitmapData;
		}

		_current = 0;
		needsResize = false;
	}

	/**
	 * Swaps screen buffers.
	 */
	public function swap()
	{
		if (HXP.renderMode == RenderMode.BUFFER)
		{
			#if !bitfive _current = 1 - _current; #end
			HXP.buffer = _bitmap[_current].bitmapData;
		}
	}

	/**
	 * Add a filter.
	 *
	 * @param	filter	The filter to add.
	 */
	public function addFilter(filter:Array<BitmapFilter>)
	{
		_sprite.filters = filter;
	}

	/**
	 * Refreshes the screen.
	 */
	public function refresh()
	{
		// refreshes the screen
#if neko
		HXP.buffer.fillRect(HXP.bounds, HXP.convertColor(_color));
#else
		HXP.buffer.fillRect(HXP.bounds, _color);
#end
	}

	/**
	 * Redraws the screen.
	 */
	public function redraw()
	{
		// refresh the buffers
		if (HXP.renderMode == RenderMode.BUFFER)
		{
			_bitmap[_current].visible = true;
			_bitmap[1 - _current].visible = false;
		}
	}

	/** @private Re-applies transformation matrix. */
	public function update()
	{
		if (_matrix == null)
		{
			_matrix = new Matrix();
		}
		_matrix.b = _matrix.c = 0;
		_matrix.a = fullScaleX;
		_matrix.d = fullScaleY;
		_matrix.tx = -originX * _matrix.a;
		_matrix.ty = -originY * _matrix.d;
		if (_angle != 0) _matrix.rotate(_angle);
		_matrix.tx += originX * fullScaleX + x;
		_matrix.ty += originY * fullScaleY + y;
		_sprite.transform.matrix = _matrix;
	}

	/**
	 * Refresh color of the screen.
	 */
	public var color(get_color, set_color):Int;
	private function get_color():Int { return _color; }
	private function set_color(value:Int):Int
	{
#if (flash || html5)
		_color = 0xFF000000 | value;
#elseif debug
		HXP.log("screen.color should only be set in flash and html5");
#end
		return value;
	}

	/**
	 * X offset of the screen.
	 */
	public var x(default, set_x):Int;
	private function set_x(value:Int):Int
	{
		if (x == value) return value;
		x = value;
		update();
		return x;
	}

	/**
	 * Y offset of the screen.
	 */
	public var y(default, set_y):Int;
	private function set_y(value:Int):Int
	{
		if (y == value) return value;
		y = value;
		update();
		return y;
	}

	/**
	 * X origin of transformations.
	 */
	public var originX(default, set_originX):Int;
	private function set_originX(value:Int):Int
	{
		if (originX == value) return value;
		originX = value;
		update();
		return originX;
	}

	/**
	 * Y origin of transformations.
	 */
	public var originY(default, set_originY):Int;
	private function set_originY(value:Int):Int
	{
		if (originY == value) return value;
		originY = value;
		update();
		return originY;
	}

	/**
	 * X scale of the screen.
	 */
	public var scaleX(default, set_scaleX):Float = 1;
	private function set_scaleX(value:Float):Float
	{
		if (scaleX == value) return value;
		scaleX = value;
		fullScaleX = scaleX * scale;
		update();
		needsResize = true;
		return scaleX;
	}

	/**
	 * Y scale of the screen.
	 */
	public var scaleY(default, set_scaleY):Float = 1;
	private function set_scaleY(value:Float):Float
	{
		if (scaleY == value) return value;
		scaleY = value;
		fullScaleY = scaleY * scale;
		update();
		needsResize = true;
		return scaleY;
	}

	/**
	 * Scale factor of the screen. Final scale is scaleX * scale by scaleY * scale, so
	 * you can use this factor to scale the screen both horizontally and vertically.
	 */
	public var scale(default, set_scale):Float = 1;
	private function set_scale(value:Float):Float
	{
		if (scale == value) return value;
		scale = value;
		fullScaleX = scaleX * scale;
		fullScaleY = scaleY * scale;
		update();
		needsResize = true;
		return scale;
	}

	/**
	 * Final X scale value of the screen
	 */
	public var fullScaleX(default, null):Float = 1;

	/**
	 * Final Y scale value of the screen
	 */
	public var fullScaleY(default, null):Float = 1;

	/**
	 * True if the scale of the screen has changed.
	 */
	public var needsResize(default, null):Bool = false;

	/**
	 * Rotation of the screen, in degrees.
	 */
	public var angle(get_angle, set_angle):Float;
	private function get_angle():Float { return _angle * HXP.DEG; }
	private function set_angle(value:Float):Float
	{
		if (_angle == value * HXP.RAD) return value;
		_angle = value * HXP.RAD;
		update();
		return _angle;
	}

	/**
	 * Whether screen smoothing should be used or not.
	 */
	public var smoothing(get_smoothing, set_smoothing):Bool;
	private function get_smoothing():Bool
	{
		if (HXP.renderMode == RenderMode.BUFFER)
		{
			return _bitmap[0].smoothing;
		}
		else
		{
			return Atlas.smooth;
		}
	}
	private function set_smoothing(value:Bool):Bool
	{
		if (HXP.renderMode == RenderMode.BUFFER)
		{
			_bitmap[0].smoothing = _bitmap[1].smoothing = value;
		}
		else
		{
			Atlas.smooth = value;
		}
		return value;
	}

	/**
	 * Width of the screen.
	 */
	public var width(default, null):Int;

	/**
	 * Height of the screen.
	 */
	public var height(default, null):Int;

	/**
	 * X position of the mouse on the screen.
	 */
	public var mouseX(get_mouseX, null):Int;
	private function get_mouseX():Int { return Std.int(_sprite.mouseX); }

	/**
	 * Y position of the mouse on the screen.
	 */
	public var mouseY(get_mouseY, null):Int;
	private function get_mouseY():Int { return Std.int(_sprite.mouseY); }

	/**
	 * Captures the current screen as an Image object.
	 * @return	A new Image object.
	 */
	public function capture():Image
	{
		if (HXP.renderMode == RenderMode.BUFFER)
		{
			return new Image(_bitmap[_current].bitmapData.clone());
		}
		else
		{
			throw "Screen.capture only supported with buffer rendering";
		}
	}

	// Screen infromation.
	private var _sprite:Sprite;
	private var _bitmap:Array<Bitmap>;
	private var _current:Int;
	private var _matrix:Matrix;
	private var _angle:Float;
	private var _color:Int;
}
