package haxepunk.graphics.tile;

import flash.geom.Point;
import haxepunk.Graphic.TileType;

/**
 * Special Spritemap object that can display blocks of animated sprites.
 */
class TiledSpritemap extends Spritemap
{
	/**
	 * Constructs the tiled spritemap.
	 * @param	source			Source image.
	 * @param	frameWidth		Frame width.
	 * @param	frameHeight		Frame height.
	 * @param	width			Width of the block to render.
	 * @param	height			Height of the block to render.
	 */
	public function new(source:TileType, frameWidth:Int = 0, frameHeight:Int = 0, width:Int = 0, height:Int = 0)
	{
		_imageWidth = width;
		_imageHeight = height;
		super(source, frameWidth, frameHeight);
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

		while (y < _imageHeight)
		{
			while (x < _imageWidth)
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

	var _imageWidth:Int;
	var _imageHeight:Int;
}
