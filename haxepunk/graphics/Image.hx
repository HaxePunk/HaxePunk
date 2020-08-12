package haxepunk.graphics;

import haxepunk.Camera;
import haxepunk.Graphic;
import haxepunk.graphics.atlas.Atlas;
import haxepunk.graphics.atlas.IAtlasRegion;
import haxepunk.graphics.hardware.Texture;
import haxepunk.utils.Color;
import haxepunk.math.Degrees;
import haxepunk.math.MathUtil;
import haxepunk.math.Radians;
import haxepunk.math.Rectangle;
import haxepunk.math.Vector2;

/**
 * Performance-optimized non-animated image. Can be drawn to the screen with transformations.
 */
class Image extends Graphic
{
	/**
	 * Rotation of the image, in degrees.
	 */
	public var angle:Degrees;

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
	 * Flips the image horizontally.
	 */
	public var flipX:Bool = false;

	/**
	 * Flips the image vertically.
	 */
	public var flipY:Bool = false;

	public var flipped(get, set):Bool;
	inline function get_flipped() return flipX;
	inline function set_flipped(v:Bool) return flipX = v;

	/**
	 * Constructor.
	 * @param	source		Source image.
	 * @param	clipRect	Optional rectangle defining area of the source image to draw.
	 */
	public function new(?source:ImageType, ?clipRect:Rectangle)
	{
		super();
		init();

		_sourceRect = new Rectangle(0, 0, 1, 1);

		if (source != null)
		{
			_region = source;
			_sourceRect.width = _region.width;
			_sourceRect.height = _region.height;
		}

		if (clipRect != null)
		{
			if (clipRect.width == 0) clipRect.width = _sourceRect.width;
			if (clipRect.height == 0) clipRect.height = _sourceRect.height;
			_region = _region.clip(clipRect); // create a new clipped region
			_sourceRect = clipRect;
		}
	}

	/** @private Initialize variables */
	inline function init()
	{
		angle = 0;
		scale = scaleX = scaleY = 1;
		originX = originY = 0;

		alpha = 1;
		color = 0xFFFFFF;
	}

	@:dox(hide)
	override public function render(point:Vector2, camera:Camera)
	{
		var sx = scale * scaleX * (flipX ? -1 : 1),
			sy = scale * scaleY * (flipY ? -1 : 1),
			fsx = camera.screenScaleX,
			fsy = camera.screenScaleY;

		var x = floorX(camera, x),
			y = floorY(camera, y);
		if (flipX) x += floorX(camera, (originX * 2 - _region.width) * sx);
		if (flipY) y += floorY(camera, (originY * 2 - _region.height) * sy);

		if (angle == 0)
		{
			_point.x = floorX(camera, point.x) - floorX(camera, originX * sx) - floorX(camera, camera.x * scrollX) + x;
			_point.y = floorY(camera, point.y) - floorY(camera, originY * sy) - floorY(camera, camera.y * scrollY) + y;

			// render without rotation
			var clipRect = screenClipRect(camera, _point.x, _point.y);
			_region.draw(_point.x * fsx, _point.y * fsy,
				sx * fsx, sy * fsy, angle,
				color, alpha,
				shader, smooth, blend, clipRect, flexibleLayer
			);
		}
		else
		{
			_point.x = floorX(camera, point.x) - floorX(camera, originX) - floorX(camera, camera.x * scrollX) + x;
			_point.y = floorY(camera, point.y) - floorY(camera, originY) - floorY(camera, camera.y * scrollY) + y;
			var angle:Radians = angle;
			var cos = Math.cos(angle);
			var sin = Math.sin(angle);
			var a = sx * cos * fsx;
			var b = sx * sin * fsy;
			var c = -sy * sin * fsx;
			var d = sy * cos * fsy;
			var tx = (-originX * sx * cos + originY * sy * sin + originX + _point.x);
			var ty = (-originX * sx * sin - originY * sy * cos + originY + _point.y);
			var clipRect = screenClipRect(camera, tx, ty);
			_region.drawMatrix(tx * fsx, ty * fsy, a, b, c, d,
				color, alpha,
				shader, smooth, blend, clipRect, flexibleLayer
			);
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

		var source:Texture = Texture.create(width, height, true, 0xFFFFFFFF);
		var image = new Image(Atlas.loadImageAsRegion(source));

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

		var texture:Texture = Texture.create(radius * 2, radius * 2, true, 0);
		texture.drawCircle(radius, radius, radius);

		var image = new Image(Atlas.loadImageAsRegion(texture));

		image.color = color;
		image.alpha = alpha;

		return image;
	}

	/**
	 * Centers the Image's originX/Y to its center.
	 */
	override public function centerOrigin()
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
	public var width(get, never):Int;
	function get_width():Int return _region.width;

	/**
	 * Height of the image.
	 */
	public var height(get, never):Int;
	function get_height():Int return _region.height;

	/**
	 * The scaled width of the image.
	 */
	public var scaledWidth(get, set):Float;
	inline function get_scaledWidth():Float return width * scaleX * scale;
	inline function set_scaledWidth(w:Float):Float return scaleX = w / scale / width;

	/**
	 * The scaled height of the image.
	 */
	public var scaledHeight(get, set):Float;
	inline function get_scaledHeight():Float return height * scaleY * scale;
	inline function set_scaledHeight(h:Float):Float return scaleY = h / scale / height;

	override public function toString():String return '[$_class $width x $height]';

	// Source and buffer information.
	var _sourceRect:Rectangle;
	var _region:IAtlasRegion;
}
