package com.haxepunk.graphics;

import com.haxepunk.graphics.atlas.Atlas;
import com.haxepunk.graphics.atlas.TextureAtlas;
import com.haxepunk.graphics.atlas.AtlasRegion;
import com.haxepunk.Graphic;
import com.haxepunk.HXP;
import com.haxepunk.RenderMode;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.BlendMode;
import nme.geom.ColorTransform;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;

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
	public var originX:Float;

	/**
	 * Y origin of the image, determines transformation point.
	 */
	public var originY:Float;

	/**
	 * Optional blend mode to use when drawing this image.
	 * Use constants from the nme.display.BlendMode class.
	 */
	public var blend:BlendMode;

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

		// check if the _source or _region were set in a higher class
		if (_source == null && _region == null)
		{
			_class = name;
			if (Std.is(source, TextureAtlas))
			{
				setAtlasRegion(cast(source, TextureAtlas).getRegion(name));
			}
			else if (Std.is(source, AtlasRegion))
			{
				setAtlasRegion(source);
			}
			else if (Std.is(source, BitmapData))
			{
				setBitmapSource(source);
			}
			else
			{
				if (HXP.renderMode.has(RenderMode.HARDWARE))
				{
					setAtlasRegion(Atlas.loadImageAsRegion(source));
				}
				else
				{
					if (Std.is(source, String))
						_class = source;
					else if (name == "")
						_class = Type.getClassName(Type.getClass(source));
					setBitmapSource(HXP.getBitmap(source));
				}
			}
			if (_source == null && _region == null) throw "Invalid source image.";
		}

		if (clipRect != null)
		{
			if (clipRect.width == 0) clipRect.width = _sourceRect.width;
			if (clipRect.height == 0) clipRect.height = _sourceRect.height;
			if (!_blit)
			{
				_region = _region.clip(clipRect); // create a new clipped region
			}
			_sourceRect = clipRect;
		}

		if (_blit)
		{
			_bitmap = new Bitmap();
			_colorTransform = new ColorTransform();

			createBuffer();
			updateBuffer();
		}
	}

	private inline function setAtlasRegion(region:AtlasRegion)
	{
		_blit = false;
		_region = region;
		_sourceRect = new Rectangle(0, 0, _region.width, _region.height);
	}

	private inline function setBitmapSource(bitmap:BitmapData)
	{
		_blit = true;
		_sourceRect = bitmap.rect;
		_source = bitmap;
	}

	/** @private Initialize variables */
	private inline function init()
	{
		angle = 0;
		scale = scaleX = scaleY = 1;
		originX = originY = 0;

		_alpha = 1;
		_flipped = false;
		_color = 0x00FFFFFF;
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
		// determine drawing location
		_point.x = point.x + x - originX - camera.x * scrollX;
		_point.y = point.y + y - originY - camera.y * scrollY;

		if (_blit)
		{
			// only draw if buffer exists
			if (_buffer != null)
			{
				if (angle == 0 &&
					scaleX * scale == 1 &&
					scaleY * scale == 1 &&
					blend == null)
				{
					// render without transformation
					target.copyPixels(_buffer, _bufferRect, _point, null, null, true);
				}
				else
				{
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
			}
		}
		else // _blit
		{
			if (_flipped) _point.x += _sourceRect.width;
			var sx = HXP.screen.fullScaleX * scale * scaleX,
				sy = HXP.screen.fullScaleY * scale * scaleY;

			_region.draw(_point.x * HXP.screen.fullScaleX,
				_point.y * HXP.screen.fullScaleY,
				layer, sx * (_flipped ? -1 : 1), sy, angle,
				HXP.getRed(_color)/255, HXP.getGreen(_color)/255, HXP.getBlue(_color)/255, _alpha);
		}
	}

	/**
	 * Creates a new rectangle Image.
	 * @param	width		Width of the rectangle.
	 * @param	height		Height of the rectangle.
	 * @param	color		Color of the rectangle.
	 * @return	A new Rect object.
	 */
	public static function createRect(width:Int, height:Int, color:Int = 0xFFFFFF):Graphic
	{
		return new com.haxepunk.graphics.prototype.Rect(width, height, color);
	}

	/**
	 * Creates a new circle Image.
	 * @param	radius		Radius of the circle.
	 * @param	color		Color of the circle.
	 * @return	A new Circle object.
	 */
	public static function createCircle(radius:Int, color:Int = 0xFFFFFF):Graphic
	{
		return new com.haxepunk.graphics.prototype.Circle(radius, color);
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
		if (_buffer == null) return;
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
		if (_blit)
		{
			if (_alpha == 1 && _color == 0xFFFFFF)
			{
				_tint = null;
			}
			else
			{
				_tint = _colorTransform;
				_tint.redMultiplier = HXP.getRed(_color) / 255;
				_tint.greenMultiplier = HXP.getGreen(_color) / 255;
				_tint.blueMultiplier = HXP.getBlue(_color) / 255;
				_tint.alphaMultiplier = _alpha;
			}
			updateBuffer();
		}
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
		if (_blit)
		{
			if (_alpha == 1 && _color == 0xFFFFFF)
			{
				_tint = null;
			}
			else
			{
				_tint = _colorTransform;
				_tint.redMultiplier = HXP.getRed(_color) / 255;
				_tint.greenMultiplier = HXP.getGreen(_color) / 255;
				_tint.blueMultiplier = HXP.getBlue(_color) / 255;
				_tint.alphaMultiplier = _alpha;
			}
			updateBuffer();
		}
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
		if (_blit)
		{
			var temp:BitmapData = _source;
			if (!value || _flip != null)
			{
				_source = _flip;
			}
			else if (_flips.exists(_class))
			{
				_source = _flips.get(_class);
			}
			else
			{
				_source = HXP.createBitmap(_source.width, _source.height, true);
				_flips.set(_class, _source);
				HXP.matrix.identity();
				HXP.matrix.a = -1;
				HXP.matrix.tx = _source.width;
				_source.draw(temp, HXP.matrix);
			}
			_flip = temp;
			updateBuffer();
		}
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
	public var width(getWidth, never):Int;
	private function getWidth():Int { return Std.int(_blit ? _bufferRect.width : _region.width); }

	/**
	 * Height of the image.
	 */
	public var height(getHeight, never):Int;
	private function getHeight():Int { return Std.int(_blit ? _bufferRect.height : _region.height); }

	/**
	 * The scaled width of the image.
	 */
	public var scaledWidth(getScaledWidth, never):Int;
	private function getScaledWidth():Int { return Std.int(width * scaleX * scale); }

	/**
	 * The scaled height of the image.
	 */
	public var scaledHeight(getScaledHeight, never):Int;
	private function getScaledHeight():Int { return Std.int(height * scaleY * scale); }

	/**
	 * Clipping rectangle for the image.
	 */
	public var clipRect(getClipRect, null):Rectangle;
	private function getClipRect():Rectangle { return _sourceRect; }

	// Source and buffer information.
	private var _source:BitmapData;
	private var _sourceRect:Rectangle;
	private var _buffer:BitmapData;
	private var _bufferRect:Rectangle;
	private var _bitmap:Bitmap;
	private var _region:AtlasRegion;

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
	private static var _flips:Map<String,BitmapData> = new Map<String,BitmapData>();

}
