package haxepunk;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.filters.BitmapFilter;
import flash.geom.Matrix;
import haxepunk.graphics.Image;
import haxepunk.graphics.atlas.Atlas;
import haxepunk.graphics.hardware.Renderer;
import haxepunk.screen.ScaleMode;

/**
 * Container for the main screen buffer. Can be used to transform the screen.
 * To be used through `HXP.screen`.
 */
@:allow(haxepunk.screen)
class Screen
{
	/**
	 * Controls how the game scale changes when the window is resized.
	 */
	public var scaleMode:ScaleMode = new ScaleMode();

	/**
	 * For hardware rendering.
	 */
	public var renderer:Renderer = new Renderer();

	/**
	 * Constructor.
	 */
	@:allow(haxepunk)
	function new()
	{
		_sprite = new Sprite();
		_bitmap = new Array<Bitmap>();

		x = y = 0;
		_current = 0;
		scale = scaleX = scaleY = 1;
		updateTransformation();

		// create screen buffers
		if (HXP.engine.contains(_sprite))
		{
			HXP.engine.removeChild(_sprite);
		}
	}

	/** @private Re-applies transformation matrix. */
	function updateTransformation()
	{
		if (_matrix == null)
		{
			_matrix = new Matrix();
		}
		_matrix.b = _matrix.c = 0;
		_matrix.a = fullScaleX;
		_matrix.d = fullScaleY;
		_matrix.tx = x;
		_matrix.ty = y;
		_sprite.transform.matrix = _matrix;
	}

	inline function disposeBitmap(bd:Bitmap)
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
	@:allow(haxepunk.HXP)
	function resize(width:Int, height:Int)
	{
		var oldWidth:Int = HXP.width,
			oldHeight:Int = HXP.height;

		scaleMode.resize(width, height);

		width = HXP.width = Std.int(HXP.screen.width / HXP.screen.fullScaleX);
		height = HXP.height = Std.int(HXP.screen.height / HXP.screen.fullScaleY);

		_current = 0;
		needsResize = false;
	}

	/**
	 * Add a filter.
	 * @param	filter	The filter to add.
	 */
	public function addFilter(filter:Array<BitmapFilter>)
	{
		_sprite.filters = filter;
	}

	@:dox(hide)
	public function update()
	{
		// screen shake
		if (_shakeTime > 0)
		{
			var sx:Int = Std.random(_shakeMagnitude * 2 + 1) - _shakeMagnitude;
			var sy:Int = Std.random(_shakeMagnitude * 2 + 1) - _shakeMagnitude;

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
	inline function get_color():Null<Int> return HXP.stage.color;
	inline function set_color(value:Null<Int>):Null<Int> return HXP.stage.color = value;

	/**
	 * X offset of the screen.
	 */
	public var x(default, set):Int = 0;
	function set_x(value:Int):Int
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
	function set_y(value:Int):Int
	{
		if (y == value) return value;
		HXP.engine.y = y = value;
		updateTransformation();
		return y;
	}

	/**
	 * X scale of the screen.
	 */
	public var scaleX(default, set):Float = 1;
	function set_scaleX(value:Float):Float
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
	function set_scaleY(value:Float):Float
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
	function set_scale(value:Float):Float
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
	 * Whether screen smoothing should be used or not.
	 */
	public var smoothing(get, set):Bool;
	function get_smoothing():Bool
	{
		return Atlas.smooth;
	}
	function set_smoothing(value:Bool):Bool
	{
		return Atlas.smooth = value;
	}

	/**
	 * Width of the screen.
	 */
	public var width(default, null):Int = 0;

	/**
	 * Height of the screen.
	 */
	public var height(default, null):Int = 0;

	/**
	 * X position of the mouse on the screen.
	 */
	public var mouseX(get, null):Int;
	function get_mouseX():Int return Std.int(_sprite.mouseX);

	/**
	 * Y position of the mouse on the screen.
	 */
	public var mouseY(get, null):Int;
	function get_mouseY():Int return Std.int(_sprite.mouseY);

	/**
	 * Captures the current screen as an Image object.
	 * @return	A new Image object.
	 */
	public function capture():Image
	{
		throw "Screen.capture not currently supported";
	}

	/**
	 * Cause the screen to shake for a specified length of time.
	 * @param	duration	Duration of shake effect, in seconds.
	 * @param	magnitude	Number of pixels to shake in any direction.
	 * @since	2.5.3
	 */
	public function shake(duration:Float = 0.5, magnitude:Int = 4)
	{
		if (_shakeTime < duration) _shakeTime = duration;
		_shakeMagnitude = magnitude;
	}

	/**
	 * Stop the screen from shaking immediately.
	 * @since	2.5.3
	 */
	public function shakeStop()
	{
		_shakeTime = 0;
	}

	// Screen infromation.
	var _sprite:Sprite;
	var _bitmap:Array<Bitmap>;
	var _current:Int;
	var _matrix:Matrix;
	var _shakeTime:Float=0;
	var _shakeMagnitude:Int=0;
	var _shakeX:Int=0;
	var _shakeY:Int=0;
}
