package com.haxepunk;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.filters.BitmapFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Transform;
import com.haxepunk.graphics.Image;

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
		init();

		// create screen buffers
		HXP.engine.addChild(_sprite);

		//Added this so that the tilesheet can use a graphics object which is in front of the ones used by software rendering
		#if cpp
		HXP.engine.addChild(HXP.sprite);
		#end
	}

	public function init()
	{
		_sprite = new Sprite();
		_matrix = new Matrix();
		_bitmap = new Array<Bitmap>();
		_current = 0;
		_scaleX = 1;
		_scaleY = 1;
		_scale = 1;
		_angle = 0;
		_color = 0x202020;
	}

	/**
	 * Resizes the screen by recreating the bitmap buffer
	 * @param width the width of the screen
	 * @param height the height of the screen
	 */
	public function resize(width:Float, height:Float)
	{
		if (_bitmap[0] != null)
		{
			_sprite.removeChild(_bitmap[0]);
			_sprite.removeChild(_bitmap[1]);
		}

		HXP.width = _width = Std.int(width);
		HXP.height = _height = Std.int(height);
		HXP.bounds.width = width;
		HXP.bounds.height = height;

		_bitmap[0] = new Bitmap(new BitmapData(_width, _height, false, 0), PixelSnapping.NEVER);
		_bitmap[1] = new Bitmap(new BitmapData(_width, _height, false, 0), PixelSnapping.NEVER);

		_sprite.addChild(_bitmap[0]).visible = true;
		_sprite.addChild(_bitmap[1]).visible = false;
		HXP.buffer = _bitmap[0].bitmapData;

		update();
	}

	/**
	 * Swaps screen buffers.
	 */
	public function swap()
	{
		_current = 1 - _current;
		HXP.buffer = _bitmap[_current].bitmapData;
	}

	public function addFilter(filter:Array<Dynamic>)
	{
		_sprite.filters = filter;
	}

	/**
	 * Refreshes the screen.
	 */
	public function refresh()
	{
		// refreshes the screen
		HXP.buffer.fillRect(HXP.bounds, _color);
	}

	/**
	 * Redraws the screen.
	 */
	public function redraw()
	{
		// refresh the buffers
		_bitmap[_current].visible = true;
		_bitmap[1 - _current].visible = false;
	}

	/** @private Re-applies transformation matrix. */
	public function update()
	{
		_matrix.b = _matrix.c = 0;
		_matrix.a = _scaleX * _scale;
		_matrix.d = _scaleY * _scale;
		_matrix.tx = -_originX * _matrix.a;
		_matrix.ty = -_originY * _matrix.d;
		if (_angle != 0) _matrix.rotate(_angle);
		_matrix.tx += _originX * _scaleX * _scale + _x;
		_matrix.ty += _originY * _scaleX * _scale + _y;
		_sprite.transform.matrix = _matrix;
	}

	/**
	 * Refresh color of the screen.
	 */
	public var color(getColor, setColor):Int;
	private function getColor():Int { return _color; }
	private function setColor(value:Int):Int { _color = 0xFF000000 | value; return _color; }

	/**
	 * X offset of the screen.
	 */
	public var x(getX, setX):Int;
	private function getX():Int { return _x; }
	private function setX(value:Int):Int
	{
		if (_x == value) return value;
		_x = value;
		update();
		return _x;
	}

	/**
	 * Y offset of the screen.
	 */
	public var y(getY, setY):Int;
	private function getY():Int { return _y; }
	private function setY(value:Int):Int
	{
		if (_y == value) return value;
		_y = value;
		update();
		return _y;
	}

	/**
	 * X origin of transformations.
	 */
	public var originX(getOriginX, setOriginX):Int;
	private function getOriginX():Int { return _originX; }
	private function setOriginX(value:Int):Int
	{
		if (_originX == value) return value;
		_originX = value;
		update();
		return _originX;
	}

	/**
	 * Y origin of transformations.
	 */
	public var originY(getOriginY, setOriginY):Int;
	private function getOriginY():Int { return _originY; }
	private function setOriginY(value:Int):Int
	{
		if (_originY == value) return value;
		_originY = value;
		update();
		return _originY;
	}

	/**
	 * X scale of the screen.
	 */
	public var scaleX(getScaleX, setScaleX):Float;
	private function getScaleX():Float { return _scaleX; }
	private function setScaleX(value:Float):Float
	{
		if (_scaleX == value) return value;
		_scaleX = value;
		update();
		return _scaleX;
	}

	/**
	 * Y scale of the screen.
	 */
	public var scaleY(getScaleY, setScaleY):Float;
	private function getScaleY():Float { return _scaleY; }
	private function setScaleY(value:Float):Float
	{
		if (_scaleY == value) return value;
		_scaleY = value;
		update();
		return _scaleY;
	}

	/**
	 * Scale factor of the screen. Final scale is scaleX * scale by scaleY * scale, so
	 * you can use this factor to scale the screen both horizontally and vertically.
	 */
	public var scale(getScale, setScale):Float;
	private function getScale():Float { return _scale; }
	private function setScale(value:Float):Float
	{
		if (_scale == value) return value;
		_scale = value;
		update();
		return _scale;
	}

	/**
	 * Rotation of the screen, in degrees.
	 */
	public var angle(getAngle, setAngle):Float;
	private function getAngle():Float { return _angle * HXP.DEG; }
	private function setAngle(value:Float):Float
	{
		if (_angle == value * HXP.RAD) return value;
		_angle = value * HXP.RAD;
		update();
		return _angle;
	}

	/**
	 * Whether screen smoothing should be used or not.
	 */
	public var smoothing(getSmoothing, setSmoothing):Bool;
	private function getSmoothing():Bool { return _bitmap[0].smoothing; }
	private function setSmoothing(value:Bool):Bool { _bitmap[0].smoothing = _bitmap[1].smoothing = value; return _bitmap[0].smoothing; }

	/**
	 * Width of the screen.
	 */
	public var width(getWidth, null):Int;
	private function getWidth():Int { return _width; }

	/**
	 * Height of the screen.
	 */
	public var height(getHeight, null):Int;
	private function getHeight():Int { return _height; }

	/**
	 * X position of the mouse on the screen.
	 */
	public var mouseX(getMouseX, null):Int;
	private function getMouseX():Int { return Std.int((HXP.stage.mouseX - _x) / (_scaleX * _scale)); }

	/**
	 * Y position of the mouse on the screen.
	 */
	public var mouseY(getMouseY, null):Int;
	private function getMouseY():Int { return Std.int((HXP.stage.mouseY - _y) / (_scaleY * _scale)); }

	/**
	 * Captures the current screen as an Image object.
	 * @return	A new Image object.
	 */
	public function capture():Image
	{
		return new Image(_bitmap[_current].bitmapData.clone());
	}

	// Screen infromation.
	private var _sprite:Sprite;
	private var _bitmap:Array<Bitmap>;
	private var _current:Int;
	private var _matrix:Matrix;
	private var _x:Int;
	private var _y:Int;
	private var _width:Int;
	private var _height:Int;
	private var _originX:Int;
	private var _originY:Int;
	private var _scaleX:Float;
	private var _scaleY:Float;
	private var _scale:Float;
	private var _angle:Float;
	private var _color:Int;
}