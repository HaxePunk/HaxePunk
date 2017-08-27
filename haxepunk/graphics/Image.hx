package haxepunk.graphics;

import flash.geom.Point;
import flash.geom.Rectangle;
import haxepunk.Camera;
import haxepunk.Graphic;
import haxepunk.HXP;
import haxepunk.graphics.atlas.Atlas;
import haxepunk.graphics.atlas.IAtlasRegion;
import haxepunk.graphics.hardware.Texture;
import haxepunk.utils.Color;
import haxepunk.math.MathUtil;

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
	 * Defaults to top-left corner.
	 */
	public var originX:Float;

	/**
	 * Y origin of the image, determines transformation point.
	 * Defaults to top-left corner.
	 */
	public var originY:Float;

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
	override public function render(point:Point, camera:Camera)
	{
		var sx = scale * scaleX,
			sy = scale * scaleY,
			fsx = camera.fullScaleX,
			fsy = camera.fullScaleY;

		var x = camera.floorX(x);
		var y = camera.floorY(y);

		if (angle == 0)
		{
			_point.x = camera.floorX(point.x) - camera.floorX(originX * sx) - camera.floorX(camera.x * scrollX) + x;
			_point.y = camera.floorY(point.y) - camera.floorY(originY * sy) - camera.floorY(camera.y * scrollY) + y;

			// render without rotation
			var clipRect = screenClipRect(camera, _point.x, _point.y);
			_region.draw(_point.x * fsx, _point.y * fsy,
				sx * fsx, sy * fsy, angle,
				color, alpha,
				shader, smooth, blend, clipRect
			);
		}
		else
		{
			_point.x = camera.floorX(point.x) - camera.floorX(originX) - camera.floorX(camera.x * scrollX) + x;
			_point.y = camera.floorY(point.y) - camera.floorY(originY) - camera.floorY(camera.y * scrollY) + y;
			var angle = angle * MathUtil.RAD;
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
				shader, smooth, blend, clipRect
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

		HXP.sprite.graphics.clear();
		HXP.sprite.graphics.beginFill(0xFFFFFF);
		HXP.sprite.graphics.drawCircle(radius, radius, radius);
		var texture:Texture = Texture.create(radius * 2, radius * 2, true, 0);
		texture.bitmap.draw(HXP.sprite);

		var image = new Image(Atlas.loadImageAsRegion(texture));

		image.color = color;
		image.alpha = alpha;

		return image;
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
	public var scaledWidth(get, set_scaledWidth):Float;
	inline function get_scaledWidth():Float return width * scaleX * scale;
	inline function set_scaledWidth(w:Float):Float return scaleX = w / scale / width;

	/**
	 * The scaled height of the image.
	 */
	public var scaledHeight(get, set_scaledHeight):Float;
	inline function get_scaledHeight():Float return height * scaleY * scale;
	inline function set_scaledHeight(h:Float):Float return scaleY = h / scale / height;

	override public function toString():String return '[$_class $width x $height]';

	// Source and buffer information.
	var _sourceRect:Rectangle;
	var _region:IAtlasRegion;
}
