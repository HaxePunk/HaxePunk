package haxepunk.graphics;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.Graphics;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import haxepunk.Camera;
import haxepunk.Graphic;
import haxepunk.HXP;
import haxepunk.RenderMode;
import haxepunk.graphics.atlas.Atlas;
import haxepunk.graphics.atlas.AtlasRegion;
import haxepunk.masks.Polygon;
import haxepunk.utils.Color;
import haxepunk.utils.MathUtil;
import haxepunk.utils.Vector;

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
	public var scale(get, set):Float;
	inline function get_scale():Float return _scale;
	inline function set_scale(value:Float):Float return _scale = value;

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
	 * tintMode value to tint in multiply mode.
	 */
	public static inline var TINTING_MULTIPLY:Float = 0.0;

	/**
	 * tintMode value to tint in colorize mode.
	 */
	public static inline var TINTING_COLORIZE:Float = 1.0;

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

		smooth = (HXP.stage.quality != LOW);
	}

	/** @private Initialize variables */
	inline function init()
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
	function createBuffer()
	{
		_buffer = HXP.createBitmap(Std.int(_sourceRect.width), Std.int(_sourceRect.height), true);
		_bufferRect = _buffer.rect;
		_bitmap.bitmapData = _buffer;
	}

	/** Renders the image. */
	@:dox(hide)
	override public function render(target:BitmapData, point:Point, camera:Camera)
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
				if (angle != 0) _matrix.rotate(angle * MathUtil.RAD);
				_matrix.tx += originX + _point.x;
				_matrix.ty += originY + _point.y;
				target.draw(_bitmap, _matrix, null, blend, null, _bitmap.smoothing);
			}
		}
	}

	@:dox(hide)
	override public function renderAtlas(layer:Int, point:Point, camera:Camera)
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

			if (_flipped)
			{
				_point.x += _sourceRect.width * sx;
			}

			_point.x = _point.x * fsx;
			_point.y = _point.y * fsy;

			// render without rotation
			_region.draw(_point.x, _point.y, layer, sx * fsx * (_flipped ? -1 : 1), sy * fsy, angle, _red, _green, _blue, _alpha, smooth, blend);
		}
		else
		{
			if (flipped)
			{
				sx *= -1;
			}

			var angle = angle * MathUtil.RAD;
			var cos = Math.cos(angle);
			var sin = Math.sin(angle);
			var a = sx * cos * fsx;
			var b = sx * sin * fsy;
			var c = -sy * sin * fsx;
			var d = sy * cos * fsy;
			var tx = (-originX * sx * cos + originY * sy * sin + originX + _point.x) * fsx;
			var ty = (-originX * sx * sin - originY * sy * cos + originY + _point.y) * fsy;

			_region.drawMatrix(tx, ty, a, b, c, d, layer, _red, _green, _blue, _alpha, smooth, blend);
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
	public static function createRect(width:Int, height:Int, color:Color = 0xFFFFFF, alpha:Float = 1):Image
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
	public static function createCircle(radius:Int, color:Color = 0xFFFFFF, alpha:Float = 1):Image
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
	 * Creates a new polygon Image from an array of points.
	 * @param	polygon		A Polygon object to create the Image from.
	 * @param	color		Color of the polygon.
	 * @param	alpha		Alpha of the polygon.
	 * @param	fill		If the polygon should be filled with the color (true) or just an outline (false).
	 * @param	thick		How thick the outline should be (only applicable when fill = false).
	 * @return	A new Image object.
	 * @since	2.5.3
	 */
	public static function createPolygon(polygon:Polygon, color:Color = 0xFFFFFF, alpha:Float = 1, fill:Bool = true, thick:Int = 1):Image
	{
		var graphics:Graphics = HXP.sprite.graphics;
		var points:Array<Vector> = polygon.points;

		var minX:Float;
		var maxX:Float;
		var minY:Float;
		var maxY:Float;

		var p:Point;
		var originalAngle:Float = polygon.angle;

		polygon.angle = 0;	// set temporarily angle to 0 so we can sync with image angle later

		minX = minY = MathUtil.NUMBER_MAX_VALUE;
		maxX = maxY = -MathUtil.NUMBER_MAX_VALUE;

		// find polygon bounds
		for (p in points)
		{
			if (p.x < minX) minX = p.x;
			if (p.x > maxX) maxX = p.x;
			if (p.y < minY) minY = p.y;
			if (p.y > maxY) maxY = p.y;
		}

		var w:Int = Math.ceil(maxX - minX);
		var h:Int = Math.ceil(maxY - minY);

		color &= 0xFFFFFF;
		graphics.clear();

		if (fill)
			graphics.beginFill(0xFFFFFF);
		else
			graphics.lineStyle(thick, 0xFFFFFF, 1, false, LineScaleMode.NORMAL, null, JointStyle.MITER);

		graphics.moveTo(points[points.length - 1].x, points[points.length - 1].y);
		for (p in points)
		{
			graphics.lineTo(p.x, p.y);
		}
		graphics.endFill();

		HXP.matrix.identity();
		HXP.matrix.translate( -minX, -minY);

		var data:BitmapData = HXP.createBitmap(w, h, true, 0);
		data.draw(HXP.sprite, HXP.matrix);

		var image:Image;
		if (HXP.renderMode == RenderMode.HARDWARE)
		{
			image = new Image(Atlas.loadImageAsRegion(data));
		}
		else
		{
			image = new Image(data);
		}

		// adjust position, origin and angle
		image.x = polygon.x + polygon.origin.x;
		image.y = polygon.y + polygon.origin.y;
		image.originX = image.x - polygon.minX;
		image.originY = image.y - polygon.minY;
		image.angle = originalAngle;
		polygon.angle = originalAngle;

		image.color = color;
		image.alpha = alpha;

		return image;
	}

	/**
	 * Updates the image buffer.
	 */
	@:dox(hide)
	public function updateBuffer(clearBefore:Bool = false)
	{
		if (_source == null) return;
		if (clearBefore) _buffer.fillRect(_bufferRect, 0);
		_buffer.copyPixels(_source, _sourceRect, HXP.zero);
		if (_tint != null) _buffer.colorTransform(_bufferRect, _tint);
	}

	function updateColorTransform()
	{
		if (_alpha == 1)
		{
			if (_tintFactor == 0 || (_tintMode == TINTING_MULTIPLY && _color == 0xFFFFFF))
			{
				_tint = null;
				return updateBuffer();
			}
		}

		_tint = _colorTransform;

		_tint.redMultiplier = _tintMode * (1.0 - _tintFactor) + (1 - _tintMode) * (_tintFactor * ((_color >> 16 & 0xFF) / 255 - 1) + 1);
		_tint.greenMultiplier = _tintMode * (1.0 - _tintFactor) + (1 - _tintMode) * (_tintFactor * ((_color >>  8 & 0xFF) / 255 - 1) + 1);
		_tint.blueMultiplier = _tintMode * (1.0 - _tintFactor) + (1 - _tintMode) * (_tintFactor * ((_color		& 0xFF) / 255 - 1) + 1);

		_tint.redOffset = _color.r * _tintFactor * _tintMode;
		_tint.greenOffset = _color.g * _tintFactor * _tintMode;
		_tint.blueOffset = _color.b * _tintFactor * _tintMode;

		_tint.alphaMultiplier = _alpha;
		updateBuffer();
	}

	/**
	 * Clears the image buffer.
	 */
	public function clear()
	{
		if (_buffer == null) return;
		_buffer.fillRect(_bufferRect, 0);
	}

	/**
	 * Change the opacity of the Image, a value from 0 to 1.
	 */
	public var alpha(get_alpha, set_alpha):Float;
	inline function get_alpha():Float return _alpha;
	function set_alpha(value:Float):Float
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
	public var color(get_color, set_color):Color;
	inline function get_color():Color return _color;
	function set_color(value:Color):Color
	{
		value &= 0xFFFFFF;
		if (_color == value) return value;
		_color = value;
		// save individual color channel values
		_red = _color.red;
		_green = _color.green;
		_blue = _color.blue;
		if (blit) updateColorTransform();
		return _color;
	}

	/**
	 * The amount the image will be tinted, suggested values from
	 * 0 to 1. 0 Means no change, 1 is full color tint.
	 *
	 * <p>Only works with blit mode.</p>
	 *
	 * <p>You can get cool, weird effects if setting this value outside the 0-1 value range.</p>
	 *
	 * @default 1.
	 */
	public var tinting(get, set):Float;
	inline function get_tinting():Float return _tintFactor;
	function set_tinting(value:Float):Float
	{
		if (_tintFactor == value || !blit) return value;
		_tintFactor = value;
		updateColorTransform();
		return _tintFactor;
	}

	/**
	 * The tint mode - multiply or colorize.
	 *
	 * <p>Only works with blit mode.</p>
	 *
	 * <p>You can get cool, weird effects if this value is not either 0 or 1.</p>
	 *
	 * @default Image.TINTING_MULTIPLY
	 */
	public var tintMode(get, set):Float;
	inline function get_tintMode():Float return _tintMode;
	function set_tintMode(value:Float):Float
	{
		if (_tintMode == value || !blit) return value;
		_tintMode = value;
		updateColorTransform();
		return _tintMode;
	}

	/**
	 * If you want to draw the Image horizontally flipped. This is
	 * faster than setting scaleX to -1 if your image isn't transformed.
	 */
	public var flipped(get_flipped, set_flipped):Bool;
	inline function get_flipped():Bool return _flipped;
	function set_flipped(value:Bool):Bool
	{
		if (_flipped == value) return value;
		_flipped = value;
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
	 *
	 * Default value: false if HXP.stage.quality is LOW, true otherwise.
	 */
	#if flash
	public var smooth(get_smooth, set_smooth):Bool;
	inline function get_smooth():Bool return _bitmap.smoothing;
	inline function set_smooth(s:Bool):Bool return _bitmap.smoothing = s;
	#else
	public var smooth:Bool;
	#end

	/**
	 * Width of the image.
	 */
	public var width(get, never):Int;
	function get_width():Int return Std.int(blit ? _bufferRect.width : (!_region.rotated ? _region.width : _region.height));

	/**
	 * Height of the image.
	 */
	public var height(get, never):Int;
	function get_height():Int return Std.int(blit ? _bufferRect.height : (!_region.rotated ? _region.height : _region.width));

	/**
	 * The scaled width of the image.
	 */
	public var scaledWidth(get, set_scaledWidth):Float;
	inline function get_scaledWidth():Float return width * scaleX * scale;
	inline function set_scaledWidth(w:Float):Float return scaleX = w / scale / width;

	/**
	 * The scaled height of the image.
	 */
	public var scaledHeight(get, set_scaledHeight):Float;
	inline function get_scaledHeight():Float return height * scaleY * scale;
	inline function set_scaledHeight(h:Float):Float return scaleY = h / scale / height;

	/**
	 * Clipping rectangle for the image.
	 */
	public var clipRect(get, null):Rectangle;
	inline function get_clipRect():Rectangle return _sourceRect;

	// Source and buffer information.
	var _source:BitmapData;
	var _sourceRect:Rectangle;
	var _buffer:BitmapData;
	var _bufferRect:Rectangle;
	var _bitmap:Bitmap;
	var _region:AtlasRegion;

	// Color and alpha information.
	var _alpha:Float;
	var _color:Color;
	var _tintFactor:Float = 1.0;
	var _tintMode:Float = TINTING_MULTIPLY;
	var _tint:ColorTransform;
	var _colorTransform:ColorTransform;
	var _matrix:Matrix;
	var _red:Float;
	var _green:Float;
	var _blue:Float;

	// Flipped image information.
	var _flipped:Bool;
	var _flip:BitmapData;
	static var _flips:Map<BitmapData, BitmapData> = new Map<BitmapData, BitmapData>();

	var _scale:Float;
}
