package haxepunk.graphics.tile;

import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxepunk.HXP;
import haxepunk.Graphic.ImageType;

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
		_graphics = HXP.sprite.graphics;
		offsetX = offsetY = 0;
		_width = width;
		_height = height;
		super(texture, clipRect);
	}

	/** Renders the image. */
	@:dox(hide)
	override public function render(point:Point, camera:Camera)
	{
		// determine drawing location
		_point.x = point.x + x - originX - camera.x * scrollX;
		_point.y = point.y + y - originY - camera.y * scrollY;

		var fsx = camera.fullScaleX,
			fsy = camera.fullScaleY,
			sx = fsx * scale * scaleX,
			sy = fsy * scale * scaleY,
			x = 0.0, y = 0.0;

		while (y < _height)
		{
			while (x < _width)
			{
				_region.draw(Math.floor((_point.x + x) * fsx), Math.floor((_point.y + y) * fsy),
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
	var _graphics:Graphics;
	var _width:Int;
	var _height:Int;
}
