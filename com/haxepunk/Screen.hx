package com.haxepunk;

import com.haxepunk.graphics.atlas.Atlas;
import com.haxepunk.graphics.Image;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.filters.BitmapFilter;
import flash.geom.Matrix;
import flash.Lib;

/**
 * Container for the main screen buffer. Can be used to transform the screen.
 * To be used through `HXP.screen`.
 */
class Screen
{
	/**
	 * Constructor.
	 */
	@:allow(com.haxepunk)
	private function new()
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
		updateTransformation();

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
	@:dox(hide)
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
		HXP.buffer.fillRect(HXP.bounds, 0xFF000000 | HXP.stage.color);
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
	private function updateTransformation()
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

	@:dox(hide)
	public function update()
	{
		// screen shake
		if (_shakeTime > 0)
		{
			var sx:Int = Std.random(_shakeMagnitude*2+1) - _shakeMagnitude;
			var sy:Int = Std.random(_shakeMagnitude*2+1) - _shakeMagnitude;

			x += sx - _shakeX;
			y += sy - _shakeY;

			_shakeX = sx;
			_shakeY = sy;

			_shakeTime -= HXP.elapsed;
			if (_shakeTime < 0) _shakeTime = 0;
		}
		else if (_shakeX != 0 || _shakeY != 0)
		{
			x -= _shakeX;
			y -= _shakeY;
			_shakeX = _shakeY = 0;
		}
	}

	/**
	 * Refresh color of the screen.
	 */
	public var color(get, set):Int;
	private function get_color():Int { return HXP.stage.color; }
	private function set_color(value:Int):Int
	{
		HXP.stage.color = value;
		
		return value;
	}

	/**
	 * X offset of the screen.
	 */
	public var x(default, set):Int = 0;
	private function set_x(value:Int):Int
	{
		if (x == value) return value;
		HXP.engine.x = x = value;
		updateTransformation();
		return x;
	}

	/**
	 * Y offset of the screen.
	 */
	public var y(default, set):Int = 0;
	private function set_y(value:Int):Int
	{
		if (y == value) return value;
		HXP.engine.y = y = value;
		updateTransformation();
		return y;
	}

	/**
	 * X origin of transformations.
	 */
	public var originX(default, set):Int = 0;
	private function set_originX(value:Int):Int
	{
		if (originX == value) return value;
		originX = value;
		updateTransformation();
		return originX;
	}

	/**
	 * Y origin of transformations.
	 */
	public var originY(default, set):Int = 0;
	private function set_originY(value:Int):Int
	{
		if (originY == value) return value;
		originY = value;
		updateTransformation();
		return originY;
	}

	/**
	 * X scale of the screen.
	 */
	public var scaleX(default, set):Float = 1;
	private function set_scaleX(value:Float):Float
	{
		if (scaleX == value) return value;
		scaleX = value;
		fullScaleX = scaleX * scale;
		updateTransformation();
		needsResize = true;
		return scaleX;
	}

	/**
	 * Y scale of the screen.
	 */
	public var scaleY(default, set):Float = 1;
	private function set_scaleY(value:Float):Float
	{
		if (scaleY == value) return value;
		scaleY = value;
		fullScaleY = scaleY * scale;
		updateTransformation();
		needsResize = true;
		return scaleY;
	}

	/**
	 * Scale factor of the screen. Final scale is scaleX * scale by scaleY * scale, so
	 * you can use this factor to scale the screen both horizontally and vertically.
	 */
	public var scale(default, set):Float = 1;
	private function set_scale(value:Float):Float
	{
		if (scale == value) return value;
		scale = value;
		fullScaleX = scaleX * scale;
		fullScaleY = scaleY * scale;
		updateTransformation();
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
	@:dox(hide)
	public var needsResize(default, null):Bool = false;

	/**
	 * Rotation of the screen, in degrees.
	 */
	public var angle(get, set):Float;
	private function get_angle():Float { return _angle * HXP.DEG; }
	private function set_angle(value:Float):Float
	{
		if (_angle == value * HXP.RAD) return value;
		_angle = value * HXP.RAD;
		updateTransformation();
		return _angle;
	}

	/**
	 * Whether screen smoothing should be used or not.
	 */
	public var smoothing(get, set):Bool;
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
	public var mouseX(get, null):Int;
	private function get_mouseX():Int { return Std.int(_sprite.mouseX); }

	/**
	 * Y position of the mouse on the screen.
	 */
	public var mouseY(get, null):Int;
	private function get_mouseY():Int { return Std.int(_sprite.mouseY); }

	/**
	 * Captures the current screen as an Image object.
	 * Will only work in buffer rendermode (flash or html5).
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

	/**
	 * Cause the screen to shake for a specified length of time.
	 *
	 * @param	magnitude	Number of pixels to shake in any direction.
	 * @param	duration	Duration of shake effect, in seconds.
	 */
	public function shake(magnitude:Int, duration:Float)
	{
		if (_shakeTime < duration) _shakeTime = duration;
		_shakeMagnitude = magnitude;
	}

	/**
	 * Stop the screen from shaking immediately.
	 */
	public function shakeStop()
	{
		_shakeTime = 0;
	}

	// Screen infromation.
	private var _sprite:Sprite;
	private var _bitmap:Array<Bitmap>;
	private var _current:Int;
	private var _matrix:Matrix;
	private var _angle:Float;
	private var _shakeTime:Float=0;
	private var _shakeMagnitude:Int=0;
	private var _shakeX:Int=0;
	private var _shakeY:Int=0;
}
