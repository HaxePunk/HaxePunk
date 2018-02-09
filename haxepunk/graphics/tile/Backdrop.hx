package haxepunk.graphics.tile;

import haxepunk.graphics.atlas.IAtlasRegion;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.math.Vector2;

/**
 * A background texture that can be repeated horizontally and vertically
 * when drawn. Really useful for parallax backgrounds, textures, etc.
 */
class Backdrop extends Graphic
{
	/**
	 * Scale of the image, effects both x and y scale.
	 */
	public var scale:Float = 1;

	/**
	 * X scale of the image.
	 */
	public var scaleX:Float = 1;

	/**
	 * Y scale of the image.
	 */
	public var scaleY:Float = 1;

	/**
	 * Constructor.
	 * @param	source		Source texture.
	 * @param	repeatX		Repeat horizontally.
	 * @param	repeatY		Repeat vertically.
	 */
	public function new(source:ImageType, repeatX:Bool = true, repeatY:Bool = true)
	{
		_region = source;
		_width = Std.int(_region.width);
		_height = Std.int(_region.height);

		_repeatX = repeatX;
		_repeatY = repeatY;

		super();

		pixelSnapping = true;
	}

	/**
	 *  Centers the origin of this Backdrop based on the dimensions of it's graphic.
	 */
	override public function centerOrigin():Void
	{
		originX = _width * 0.5;
		originY = _height * 0.5;
	}

	@:dox(hide)
	override public function render(point:Vector2, camera:Camera)
	{
		_point.x = (point.x - camera.x * scrollX + x) * camera.screenScaleX - originX * scaleX * scale;
		_point.y = (point.y - camera.y * scrollY + y) * camera.screenScaleY - originY * scaleY * scale;

		var sx = scale * scaleX * camera.screenScaleX,
			sy = scale * scaleY * camera.screenScaleY,
			scaledWidth = _width * sx,
			scaledHeight = _height * sy;

		var xi:Int = 1,
			yi:Int = 1;
		if (_repeatX)
		{
			_point.x %= scaledWidth;
			if (_point.x > 0) _point.x -= scaledWidth;
			xi = Std.int(Math.ceil((HXP.screen.width - _point.x) / scaledWidth));
		}
		if (_repeatY)
		{
			_point.y %= scaledHeight;
			if (_point.y > 0) _point.y -= scaledHeight;
			yi = Std.int(Math.ceil((HXP.screen.height - _point.y) / scaledHeight));
		}

		for (y in 0 ... yi)
		{
			for (x in 0 ... xi)
			{
				_region.draw(
					_point.x + x * scaledWidth,
					_point.y + y * scaledHeight,
					sx, sy, 0,
					color, alpha,
					shader, smooth, blend
				);
			}
		}
	}

	@:dox(hide)
	override public function pixelPerfectRender(point:Vector2, camera:Camera)
	{
		var fsx = camera.screenScaleX,
			fsy = camera.screenScaleY,
			sx = scale * scaleX,
			sy = scale * scaleY;
		_point.x = (point.x - floorX(camera, camera.x * scrollX) + floorX(camera, x)) * fsx - floorX(camera, originX * sx);
		_point.y = (point.y - floorY(camera, camera.y * scrollY) + floorY(camera, y)) * fsy - floorY(camera, originY * sy);

		var scaledWidth = _width * sx * fsx,
			scaledHeight = _height * sy * fsy;

		var xi:Int = 1,
			yi:Int = 1;
		if (_repeatX)
		{
			_point.x %= scaledWidth;
			if (_point.x > 0) _point.x -= scaledWidth;
			xi = Std.int(Math.ceil((HXP.screen.width - _point.x) / Std.int(scaledWidth)));
		}
		if (_repeatY)
		{
			_point.y %= scaledHeight;
			if (_point.y > 0) _point.y -= scaledHeight;
			yi = Std.int(Math.ceil((HXP.screen.height - _point.y) / Std.int(scaledHeight)));
		}

		var x1:Float = 0, y1:Float = 0,
			x2:Float = 0, y2:Float = 0;
		for (y in 0 ... yi)
		{
			y2 = floorY(camera, (y + 1) * _height * sy) * fsy;
			for (x in 0 ... xi)
			{
				x2 = floorX(camera, (x + 1) * _width * sx) * fsx;
				_region.draw(
					_point.x + x1,
					_point.y + y1,
					(x2 - x1) / _width, (y2 - y1) / _height, 0,
					color, alpha,
					shader, smooth, blend
				);
				x1 = x2;
			}
			x1 = x2 = 0;
			y1 = y2;
		}
	}

	// Backdrop information.
	var _region:IAtlasRegion;
	var _width:Int;
	var _height:Int;
	var _repeatX:Bool;
	var _repeatY:Bool;
}
