package haxepunk.graphics;

import flash.geom.Point;
import haxepunk.graphics.atlas.IAtlasRegion;
import haxepunk.HXP;
import haxepunk.Graphic;

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
	 * @param	screenScale	How many screens the backdrop must span (to use with screen scaling)
	 */
	public function new(source:ImageType, repeatX:Bool = true, repeatY:Bool = true, screenScale:Float = 1.)
	{
		_region = source;
		_width = Std.int(_region.width);
		_height = Std.int(_region.height);

		_repeatX = repeatX;
		_repeatY = repeatY;

		super();
	}

	@:dox(hide)
	override public function render(layer:Int, point:Point, camera:Camera)
	{
		_point.x = point.x + x - camera.x * scrollX;
		_point.y = point.y + y - camera.y * scrollY;

		var sx = scale * scaleX * HXP.screen.fullScaleX,
			sy = scale * scaleY * HXP.screen.fullScaleY,
			scaledWidth = _width * sx,
			scaledHeight = _height * sy;

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

		var px:Int = Std.int(_point.x),
			py:Int = Std.int(_point.y);

		for (y in 0 ... yi)
		{
			for (x in 0 ... xi)
			{
				_region.draw(
					px + x * scaledWidth,
					py + y * scaledHeight,
					layer, sx, sy, 0,
					_red, _green, _blue, alpha,
					shader, smooth, blend
				);
			}
		}
	}

	// Backdrop information.
	var _region:IAtlasRegion;
	var _width:Int;
	var _height:Int;
	var _repeatX:Bool;
	var _repeatY:Bool;
}
