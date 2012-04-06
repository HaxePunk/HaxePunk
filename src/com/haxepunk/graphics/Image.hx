package com.haxepunk.graphics;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.haxepunk.Graphic;
import com.haxepunk.HXP;

/**
 * Performance-optimized non-animated image. Can be drawn to the screen with transformations.
 */
class Image extends Graphic
{

	/**
	 * Rotation of the image, in degrees.
	 */
	public var angle:Float;

	/**
	 * Scale of the image, effects both x and y scale.
	 */
	public var scale:Float;

	/**
	 * X scale of the image.
	 */
	public var scaleX:Float;

	/**
	 * Y scale of the image.
	 */
	public var scaleY:Float;

	/**
	 * X origin of the image, determines transformation point.
	 */
	public var originX:Int;

	/**
	 * Y origin of the image, determines transformation point.
	 */
	public var originY:Int;

	/**
	 * Optional blend mode to use when drawing this image.
	 * Use constants from the flash.display.BlendMode class.
	 */
#if (flash || js)
	public var blend:BlendMode;
#else
	public var blend:String;
#end

	/**
	 * If the image should be drawn transformed with pixel smoothing.
	 * This will affect drawing performance, but look less pixelly.
	 */
	public var smooth:Bool;

	/**
	 * Constructor.
	 * @param	source		Source image.
	 * @param	clipRect	Optional rectangle defining area of the source image to draw.
	 * @param	name		Optional name, necessary to identify the bitmapData if you are using flipped
	 */
	public function new(source:Dynamic, clipRect:Rectangle = null, name:String = "")
	{
		super();
		init();

		if (Std.is(source, BitmapData))
		{
#if hardware
			imageID = -1;
#end
			_source = source;
			_class = name;
		}
		else
		{
			if (Std.is(source, String))
				_class = source;
			else if (name == "")
				_class = Type.getClassName(Type.getClass(source));
			else
				_class = name;
			_source = HXP.getBitmap(source);
		}
#if hardware
		imageID = HXP.getBitmapIndex(source);
		_bufferRect = HXP.sheetRectangles[imageID];
		_tileSheet = HXP.tilesheet;

		if (imageID == -1) //Temporary fix
		{
			_sourceRect = source.rect;
			_bufferRect = source.rect;
			createBuffer();
			updateBuffer();
		}
#else
		if (_source == null) throw "Invalid source image.";
		_sourceRect = _source.rect;


		if (clipRect != null)
		{
			if (clipRect.width == 0) clipRect.width = _sourceRect.width;
			if (clipRect.height == 0) clipRect.height = _sourceRect.height;
			_sourceRect = clipRect;
		}

		createBuffer();
		updateBuffer();
#end
	}

	/** @private Initialize variables */
	private function init()
	{
		angle = 0;
		scale = 1;
		scaleX = 1;
		scaleY = 1;

		_bitmap = new Bitmap();
		_alpha = 1;
		_color = 0x00FFFFFF;
		_colorTransform = new ColorTransform();
		_matrix = HXP.matrix;
	}

	/** @private Creates the buffer. */
	private function createBuffer()
	{
		_buffer = HXP.createBitmap(Std.int(_sourceRect.width), Std.int(_sourceRect.height), true);
		_bufferRect = _buffer.rect;
		_bitmap.bitmapData = _buffer;
	}

	/** Renders the image. */
	override public function render(target:BitmapData, point:Point, camera:Point)
	{
#if hardware
		if (imageID > -1)
		{
			var useScale = (HXP.tilesheetFlags & HXP.TILE_SCALE) > 0;
			var useRotation = (HXP.tilesheetFlags & HXP.TILE_ROTATION) > 0;
			var useRGB = (HXP.tilesheetFlags & HXP.TILE_RGB) > 0;
			var useAlpha = (HXP.tilesheetFlags & HXP.TILE_ALPHA) > 0;
			HXP.tileData[HXP.currentPos++] = point.x + x - camera.x * scrollX;
			HXP.tileData[HXP.currentPos++] = point.y + y - camera.y * scrollY;
			HXP.tileData[HXP.currentPos++] = imageID;
			if (useScale)
			{
				HXP.tileData[HXP.currentPos++] = scale;
			}

			if (useRotation)
			{
				HXP.tileData[HXP.currentPos++] = angle;
			}

			if (useRGB)
			{
				HXP.tileData[HXP.currentPos++] = _tint.redMultiplier;
				HXP.tileData[HXP.currentPos++] = _tint.greenMultiplier;
				HXP.tileData[HXP.currentPos++] = _tint.blueMultiplier;
			}

			if (useAlpha)
			{
				HXP.tileData[HXP.currentPos++] = _alpha;
			}
			return;
		}

#end

		// quit if no graphic is assigned
		if (_buffer == null) return;

		// determine drawing location
		_point.x = point.x + x - camera.x * scrollX;
		_point.y = point.y + y - camera.y * scrollY;

		// render without transformation
		if (angle == 0 &&
			scaleX * scale == 1 &&
			scaleY * scale == 1 &&
			blend == null)
		{
			target.copyPixels(_buffer, _bufferRect, _point, null, null, true);
			return;
		}

		// render with transformation
		_matrix.b = _matrix.c = 0;
		_matrix.a = scaleX * scale;
		_matrix.d = scaleY * scale;
		_matrix.tx = -originX * _matrix.a;
		_matrix.ty = -originY * _matrix.d;
		if (angle != 0) _matrix.rotate(angle * HXP.RAD);
		_matrix.tx += originX + _point.x;
		_matrix.ty += originY + _point.y;
		target.draw(_bitmap, _matrix, null, blend, null, smooth);
	}

	/**
	 * Creates a new rectangle Image.
	 * @param	width		Width of the rectangle.
	 * @param	height		Height of the rectangle.
	 * @param	color		Color of the rectangle.
	 * @return	A new Image object.
	 */
	public static function createRect(width:Int, height:Int, color:Int = 0xFFFFFF):Image
	{
		var source:BitmapData = HXP.createBitmap(width, height, true, 0xFF000000 | color);
		return new Image(source);
	}

	/**
	 * Creates a new circle Image.
	 * @param	radius		Radius of the circle.
	 * @param	color		Color of the circle.
	 * @return	A new Circle object.
	 */
	public static function createCircle(radius:Int, color:Int = 0xFFFFFF):Image
	{
		HXP.sprite.graphics.clear();
		HXP.sprite.graphics.beginFill(color);
		HXP.sprite.graphics.drawCircle(radius, radius, radius);
		var data:BitmapData = HXP.createBitmap(radius * 2, radius * 2, true);
		data.draw(HXP.sprite);
		return new Image(data);
	}

	/**
	 * Updates the image buffer.
	 */
	public function updateBuffer(clearBefore:Bool = false)
	{
		if (_source == null) return;
		if (clearBefore) _buffer.fillRect(_bufferRect, HXP.blackColor);
		_buffer.copyPixels(_source, _sourceRect, HXP.zero);
		if (_tint != null) _buffer.colorTransform(_bufferRect, _tint);
	}

	/**
	 * Clears the image buffer.
	 */
	public function clear()
	{
		_buffer.fillRect(_bufferRect, HXP.blackColor);
	}

	/**
	 * Change the opacity of the Image, a value from 0 to 1.
	 */
	public var alpha(getAlpha, setAlpha):Float;
	private function getAlpha():Float { return _alpha; }
	private function setAlpha(value:Float):Float
	{
		value = value < 0 ? 0 : (value > 1 ? 1 : value);
		if (_alpha == value) return value;
		_alpha = value;
		if (_alpha == 1 && _color == 0xFFFFFF)
		{
			_tint = null;
			updateBuffer();
			return _alpha;
		}
		_tint = _colorTransform;
		_tint.redMultiplier = (_color >> 16 & 0xFF) / 255;
		_tint.greenMultiplier = (_color >> 8 & 0xFF) / 255;
		_tint.blueMultiplier = (_color & 0xFF) / 255;
		_tint.alphaMultiplier = _alpha;
		updateBuffer();
		return _alpha;
	}

	/**
	 * The tinted color of the Image. Use 0xFFFFFF to draw the Image normally.
	 */
	public var color(getColor, setColor):Int;
	private function getColor():Int { return _color; }
	private function setColor(value:Int):Int
	{
		value &= 0xFFFFFF;
		if (_color == value) return value;
		_color = value;
		if (_alpha == 1 && _color == 0xFFFFFF)
		{
			_tint = null;
			updateBuffer();
			return _color;
		}
		_tint = _colorTransform;
		_tint.redMultiplier = (_color >> 16 & 0xFF) / 255;
		_tint.greenMultiplier = (_color >> 8 & 0xFF) / 255;
		_tint.blueMultiplier = (_color & 0xFF) / 255;
		_tint.alphaMultiplier = _alpha;
		updateBuffer();
		return _color;
	}

	/**
	 * If you want to draw the Image horizontally flipped. This is
	 * faster than setting scaleX to -1 if your image isn't transformed.
	 */
	public var flipped(getFlipped, setFlipped):Bool;
	private function getFlipped():Bool { return _flipped; }
	private function setFlipped(value:Bool):Bool
	{
		if (_flipped == value || _class == "") return value;

		_flipped = value;
		var temp:BitmapData = _source;
		if (!value || _flip != null)
		{
			_source = _flip;
			_flip = temp;
			updateBuffer();
			return _flipped;
		}
		if (_flips.exists(_class))
		{
			_source = _flips.get(_class);
			_flip = temp;
			updateBuffer();
			return _flipped;
		}
		_source = HXP.createBitmap(_source.width, _source.height, true);
		_flips.set(_class, _source);
		_flip = temp;
		HXP.matrix.identity();
		HXP.matrix.a = -1;
		HXP.matrix.tx = _source.width;
		_source.draw(temp, HXP.matrix);
		updateBuffer();
		return _flipped;
	}

	/**
	 * Centers the Image's originX/Y to its center.
	 */
	public function centerOrigin()
	{
		originX = Std.int(width / 2);
		originY = Std.int(height / 2);
	}

	/**
	 * Centers the Image's originX/Y to its center, and negates the offset by the same amount.
	 */
	public function centerOO()
	{
		x += originX;
		y += originY;
		centerOrigin();
		x -= originX;
		y -= originY;
	}

	/**
	 * Width of the image.
	 */
	public var width(getWidth, null):Int;
	private function getWidth():Int { return Std.int(_bufferRect.width); }

	/**
	 * Height of the image.
	 */
	public var height(getHeight, null):Int;
	private function getHeight():Int { return Std.int(_bufferRect.height); }

	/**
	 * The scaled width of the image.
	 */
	public var scaledWidth(getScaledWidth, null):Int;
	private function getScaledWidth():Int { return Std.int(_bufferRect.width * scaleX * scale); }

	/**
	 * The scaled height of the image.
	 */
	public var scaleHeight(getScaledHeight, null):Int;
	private function getScaledHeight():Int { return Std.int(_bufferRect.height * scaleY * scale); }

	/**
	 * Clipping rectangle for the image.
	 */
	public var clipRect(getClipRect, null):Rectangle;
	private function getClipRect():Rectangle { return _sourceRect; }

	/** @private Source BitmapData image. */
	private var source(getSource, null):BitmapData;
	private function getSource():BitmapData { return _source; }

	// Source and buffer information.
	private var _source:BitmapData;
	private var _sourceRect:Rectangle;
	private var _buffer:BitmapData;
	private var _bufferRect:Rectangle;
	private var _bitmap:Bitmap;

	// Color and alpha information.
	private var _alpha:Float;
	private var _color:Int;
	private var _tint:ColorTransform;
	private var _colorTransform:ColorTransform;
	private var _matrix:Matrix;

	// Flipped image information.
	private var _class:String;
	private var _flipped:Bool;
	private var _flip:BitmapData;
	private static var _flips:Hash<BitmapData> = new Hash<BitmapData>();

}