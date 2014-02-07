package com.haxepunk.graphics;

import com.haxepunk.graphics.atlas.Atlas;
import com.haxepunk.graphics.atlas.TextureAtlas;
import com.haxepunk.graphics.atlas.AtlasRegion;
import com.haxepunk.Graphic;
import com.haxepunk.HXP;
import com.haxepunk.RenderMode;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

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
	public var scale(get_scale, set_scale):Float;
	public function get_scale():Float { return _scale; }
	public function set_scale(value:Float):Float { return _scale = value; }

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
	 * Defaults to top-left corner.
	 */
	public var originX:Float;

	/**
	 * Y origin of the image, determines transformation point.
	 * Defaults to top-left corner.
	 */
	public var originY:Float;

	/**
	 * Optional blend mode to use when drawing this image.
	 * Use constants from the flash.display.BlendMode class.
	 */
	public var blend:BlendMode;

	/**
	 * Constructor.
	 * @param	source		Source image.
	 * @param	clipRect	Optional rectangle defining area of the source image to draw.
	 */
	public function new(?source:ImageType, ?clipRect:Rectangle)
	{
		super();
		init();

		// check if the _source or _region were set in a higher class
		if (source != null)
		{
			switch (source.type)
			{
				case Left(bitmap):
					blit = true;
					_source = bitmap;
					_sourceRect = bitmap.rect;
				case Right(region):
					blit = false;
					_region = region;
					_sourceRect = new Rectangle(0, 0, _region.width, _region.height);
			}
		}

		if (clipRect != null)
		{
			if (clipRect.width == 0) clipRect.width = _sourceRect.width;
			if (clipRect.height == 0) clipRect.height = _sourceRect.height;
			if (!blit)
			{
				_region = _region.clip(clipRect); // create a new clipped region
			}
			_sourceRect = clipRect;
		}

		if (blit)
		{
			_bitmap = new Bitmap();
			_colorTransform = new ColorTransform();

			createBuffer();
			updateBuffer();
		}
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
		_red = _green = _blue = 1;
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
		var sx = scale * scaleX,
			sy = scale * scaleY;

		// determine drawing location
		_point.x = point.x + x - originX - camera.x * scrollX;
		_point.y = point.y + y - originY - camera.y * scrollY;

		// only draw if buffer exists
		if (_buffer != null)
		{
			if (angle == 0 && sx == 1 && sy == 1 && blend == null)
			{
				// render without transformation
				target.copyPixels(_buffer, _bufferRect, _point, null, null, true);
			}
			else
			{
				// render with transformation
				_matrix.b = _matrix.c = 0;
				_matrix.a = sx;
				_matrix.d = sy;
				_matrix.tx = -originX * sx;
				_matrix.ty = -originY * sy;
				if (angle != 0) _matrix.rotate(angle * HXP.RAD);
				_matrix.tx += originX + _point.x;
				_matrix.ty += originY + _point.y;
				target.draw(_bitmap, _matrix, null, blend, null, _bitmap.smoothing);
			}
		}
	}

	public override function renderAtlas(layer:Int, point:Point, camera:Point)
	{
		var sx = scale * scaleX,
			sy = scale * scaleY,
			fsx = HXP.screen.fullScaleX,
			fsy = HXP.screen.fullScaleY;

		// determine drawing location
		_point.x = point.x + x - originX - camera.x * scrollX;
		_point.y = point.y + y - originY - camera.y * scrollY;

		if (angle == 0)
		{
			// UGH... recalculation of _point for scaled origins
			if (!(sx == 1 && sy == 1))
			{
				_point.x = (point.x + x - originX * sx - camera.x * scrollX);
				_point.y = (point.y + y - originY * sy - camera.y * scrollY);
			}

			if (_flipped) _point.x += _sourceRect.width * sx;

			_point.x = Math.floor(_point.x * fsx);
			_point.y = Math.floor(_point.y * fsy);

			// render without rotation
			_region.draw(_point.x, _point.y, layer,
				sx * fsx * (_flipped ? -1 : 1), sy * fsy, angle,
				_red, _green, _blue, _alpha);
		}
		else
		{
			var theta = angle * HXP.RAD;
			var cos = Math.cos(theta);
			var sin = Math.sin(theta);

			if (flipped) sx *= -1;

			// optimized matrix math
			var b = sx * fsx * sin;
			var a = sx * fsx * cos;

			var d = sy * fsy * cos;
			var c = sy * fsy * -sin;

			var tx = -originX * sx,
				ty = -originY * sy;
			var tx1 = tx * cos - ty * sin;
			ty = ((tx * sin + ty * cos) + originY + _point.y) * fsy;
			tx = (tx1 + originX + _point.x) * fsx;

			_region.drawMatrix(Std.int(tx), Std.int(ty), a, b, c, d, layer, _red, _green, _blue, _alpha);
		}
	}

	/**
	 * Creates a new rectangle Image.
	 * @param	width		Width of the rectangle.
	 * @param	height		Height of the rectangle.
	 * @param	color		Color of the rectangle.
	 * @param	alpha		Alpha of the rectangle.
	 * @return	A new Image object of a rectangle.
	 */
	public static function createRect(width:Int, height:Int, color:Int = 0xFFFFFF, alpha:Float = 1):Image
	{
		if (width == 0 || height == 0)
			throw "Illegal rect, sizes cannot be 0.";

		var source:BitmapData = HXP.createBitmap(width, height, true, 0xFFFFFFFF);
		var image:Image;
		if (HXP.renderMode == RenderMode.HARDWARE)
		{
			image = new Image(Atlas.loadImageAsRegion(source));
		}
		else
		{
			image = new Image(source);
		}

		image.color = color;
		image.alpha = alpha;

		return image;
	}

	/**
	 * Creates a new circle Image.
	 * @param	radius		Radius of the circle.
	 * @param	color		Color of the circle.
	 * @param	alpha		Alpha of the circle.
	 * @return	A new Image object of a circle.
	 */
	public static function createCircle(radius:Int, color:Int = 0xFFFFFF, alpha:Float = 1):Image
	{
		if (radius == 0)
			throw "Illegal circle, radius cannot be 0.";

		HXP.sprite.graphics.clear();
		HXP.sprite.graphics.beginFill(0xFFFFFF);
		HXP.sprite.graphics.drawCircle(radius, radius, radius);
		var data:BitmapData = HXP.createBitmap(radius * 2, radius * 2, true, 0);
		data.draw(HXP.sprite);

		var image:Image;
		if (HXP.renderMode == RenderMode.HARDWARE)
		{
			image = new Image(Atlas.loadImageAsRegion(data));
		}
		else
		{
			image = new Image(data);
		}

		image.color = color;
		image.alpha = alpha;

		return image;
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

	private function updateColorTransform()
	{
		if (_alpha == 1 && _color == 0xFFFFFF)
		{
			_tint = null;
		}
		else
		{
			_tint = _colorTransform;
			_tint.redMultiplier = _red;
			_tint.greenMultiplier = _green;
			_tint.blueMultiplier = _blue;
			_tint.alphaMultiplier = _alpha;
		}
		updateBuffer();
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
	public var alpha(get_alpha, set_alpha):Float;
	private function get_alpha():Float { return _alpha; }
	private function set_alpha(value:Float):Float
	{
		value = value < 0 ? 0 : (value > 1 ? 1 : value);
		if (_alpha == value) return value;
		_alpha = value;
		if (blit) updateColorTransform();
		return _alpha;
	}

	/**
	 * The tinted color of the Image. Use 0xFFFFFF to draw the Image normally.
	 */
	public var color(get_color, set_color):Int;
	private function get_color():Int { return _color; }
	private function set_color(value:Int):Int
	{
		value &= 0xFFFFFF;
		if (_color == value) return value;
		_color = value;
		// save individual color channel values
		_red = HXP.getRed(_color) / 255;
		_green = HXP.getGreen(_color) / 255;
		_blue = HXP.getBlue(_color) / 255;
		if (blit) updateColorTransform();
		return _color;
	}

	/**
	 * If you want to draw the Image horizontally flipped. This is
	 * faster than setting scaleX to -1 if your image isn't transformed.
	 */
	public var flipped(get_flipped, set_flipped):Bool;
	private function get_flipped():Bool { return _flipped; }
	private function set_flipped(value:Bool):Bool
	{
		if (_flipped == value) return value;

		if (blit)
		{
			var temp:BitmapData = _source;
			if (!value || _flip != null)
			{
				_source = _flip;
			}
			else if (_flips.exists(temp))
			{
				_source = _flips.get(temp);
			}
			else
			{
				_source = HXP.createBitmap(_source.width, _source.height, true);
				_flips.set(temp, _source);
				HXP.matrix.identity();
				HXP.matrix.a = -1;
				HXP.matrix.tx = _source.width;
				_source.draw(temp, HXP.matrix);
			}
			_flip = temp;
			updateBuffer();
		}
		_flipped = value;
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
	 * If the image should be drawn transformed with pixel smoothing.
	 * This will affect drawing performance, but look less pixelly.
	 */
	#if flash
	public var smooth(get_smooth, set_smooth):Bool;
	private function get_smooth():Bool { return _bitmap.smoothing; }
	private function set_smooth(s:Bool):Bool {
		_bitmap.smoothing = s;
		return _bitmap.smoothing;
	}
	#else
	public var smooth : Bool = false;
	#end

	/**
	 * Width of the image.
	 */
	public var width(get_width, never):Int;
	private function get_width():Int { return Std.int(blit ? _bufferRect.width : (!_region.rotated ? _region.width : _region.height)); }

	/**
	 * Height of the image.
	 */
	public var height(get_height, never):Int;
	private function get_height():Int { return Std.int(blit ? _bufferRect.height : (!_region.rotated ? _region.height : _region.width)); }

	/**
	 * The scaled width of the image.
	 */
	public var scaledWidth(get_scaledWidth, set_scaledWidth):Float;
	private function get_scaledWidth():Float { return width * scaleX * scale; }
	public function set_scaledWidth(w:Float):Float {
		scaleX = w / scale / width;
		return scaleX;
	}

	/**
	 * The scaled height of the image.
	 */
	public var scaledHeight(get_scaledHeight, set_scaledHeight):Float;
	private function get_scaledHeight():Float { return height * scaleY * scale; }
	public function set_scaledHeight(h:Float):Float {
		scaleY = h / scale / height;
		return scaleY;
	}

	/**
	 * Clipping rectangle for the image.
	 */
	public var clipRect(get_clipRect, null):Rectangle;
	private function get_clipRect():Rectangle { return _sourceRect; }

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
	private var _red:Float;
	private var _green:Float;
	private var _blue:Float;

	// Flipped image information.
	private var _flipped:Bool;
	private var _flip:BitmapData;
	private static var _flips:Map<BitmapData, BitmapData> = new Map<BitmapData, BitmapData>();

	private var _scale:Float;
}
