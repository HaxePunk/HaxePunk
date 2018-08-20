package haxepunk.graphics.tile;

import haxepunk.HXP;
import haxepunk.math.Rectangle;
import haxepunk.Graphic.ImageType;
import haxepunk.math.Vector2;

/**
 * Special Image object that can display blocks of tiles.
 */
class TiledImage extends Image
{
	/**
	 * Constructs the TiledImage.
	 * @param	texture		Source texture.
	 * @param	width		The width of the image (the texture will be drawn to fill this area).
	 * @param	height		The height of the image (the texture will be drawn to fill this area).
	 * @param	clipRect	An optional area of the source texture to use (eg. a tile from a tileset).
	 */
	public function new(texture:ImageType, width:Int = 0, height:Int = 0, ?clipRect:Rectangle)
	{
		offsetX = offsetY = 0;
		_width = width;
		_height = height;
		super(texture, clipRect);

		pixelSnapping = true;
	}

	/** Renders the image. */
	@:dox(hide)
	override public function render(point:Vector2, camera:Camera)
	{
		// determine drawing location
		_point.x = point.x + x - originX - camera.x * scrollX;
		_point.y = point.y + y - originY - camera.y * scrollY;

		var fsx = camera.screenScaleX,
			fsy = camera.screenScaleY,
			sx = fsx * scale * scaleX,
			sy = fsy * scale * scaleY,
			x = 0.0, y = 0.0;

		while (y < _height)
		{
			while (x < _width)
			{
				_region.draw(Math.floor((_point.x + x - HXP.halfWidth) * fsx + HXP.halfWidth),
					Math.floor((_point.y + y - HXP.halfHeight) * fsy + HXP.halfHeight),
					sx, sy, angle,
					color, alpha,
					shader, smooth, blend
					);
				x += _sourceRect.width;
			}
			x = 0;
			y += _sourceRect.height;
		}
	}

	override public function pixelPerfectRender(point:Vector2, camera:Camera)
	{
		// determine drawing location
		var fsx = camera.screenScaleX,
			fsy = camera.screenScaleY,
			sx = scale * scaleX,
			sy = scale * scaleY;
		_point.x = (point.x + floorX(camera, x - originX) - floorX(camera, camera.x * scrollX) - HXP.halfWidth) * fsx + HXP.halfWidth;
		_point.y = (point.y + floorY(camera, y - originY) - floorY(camera, camera.y * scrollY) - HXP.halfHeight) * fsy + HXP.halfHeight;

		var x:Float = 0, y:Float = 0,
			x1:Float = 0, y1:Float = 0,
			x2:Float = 0, y2:Float = 0;
		while (y < _height * sy)
		{
			y += _sourceRect.height * sy;
			y2 = floorY(camera, y) * fsy;
			while (x < _width * sx)
			{
				x += _sourceRect.width * sx;
				x2 = floorX(camera, x) * fsx;
				_region.draw(
					_point.x + x1,
					_point.y + y1,
					(x2 - x1) / _region.width, (y2 - y1) / _region.height, angle,
					color, alpha,
					shader, smooth, blend
				);
				x1 = x2;
			}
			x = x1 = x2 = 0;
			y1 = y2;
		}
	}

	/**
	 * The x-offset of the texture.
	 */
	public var offsetX:Float;

	/**
	 * The y-offset of the texture.
	 */
	public var offsetY:Float;

	/**
	 * Sets the texture offset.
	 * @param	x		The x-offset.
	 * @param	y		The y-offset.
	 */
	public function setOffset(x:Float, y:Float)
	{
		offsetX = x;
		offsetY = y;
	}

	// Drawing information.
	var _width:Int;
	var _height:Int;
}
