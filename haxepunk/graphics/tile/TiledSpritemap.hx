package haxepunk.graphics.tile;

import haxepunk.Graphic.TileType;
import haxepunk.math.Vector2;

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

		pixelSnapping = true;
	}

	/** Renders the image. */
	@:dox(hide)
	override public function render(point:Vector2, camera:Camera)
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

	/** Renders the image. */
	@:dox(hide)
	override public function pixelPerfectRender(point:Vector2, camera:Camera)
	{
		// determine drawing location
		_point.x = point.x + floorX(camera, x - originX) - floorX(camera, camera.x * scrollX);
		_point.y = point.y + floorY(camera, y - originY) - floorY(camera, camera.y * scrollY);

		var fsx = camera.fullScaleX,
			fsy = camera.fullScaleY,
			sx = fsx * scale * scaleX,
			sy = fsy * scale * scaleY,
			x = 0.0, y = 0.0;

		var x:Float = 0, y:Float = 0,
			x1:Float = 0, y1:Float = 0,
			x2:Float = 0, y2:Float = 0;
		while (y < _imageHeight * sy)
		{
			y += _sourceRect.height * sy;
			y2 = floorY(camera, y) * fsy;
			while (x1 < _imageWidth * sx)
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
			x1 = x2 = 0;
			y1 = y2;
		}
	}

	var _imageWidth:Int;
	var _imageHeight:Int;
}
