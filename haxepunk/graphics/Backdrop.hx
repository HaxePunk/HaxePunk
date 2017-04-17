package haxepunk.graphics;

import flash.geom.Point;
import haxepunk.graphics.atlas.IAtlasRegion;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.utils.Color;

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

		color = 0xFFFFFF;
		alpha = 1;

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
					_red, _green, _blue, _alpha
				);
			}
		}
	}

	/**
	 * The tinted color of the Canvas. Use 0xFFFFFF to draw the it normally.
	 */
	public var color(get, set):Color;
	function get_color():Color return _color;
	function set_color(value:Color):Color
	{
		value &= 0xFFFFFF;
		if (_color == value) return _color;
		_color = value;
		_red = color.red;
		_green = color.green;
		_blue = color.blue;
		return _color;
	}

	/**
	 * Change the opacity of the Canvas, a value from 0 to 1.
	 */
	public var alpha(get, set):Float;
	function get_alpha():Float return _alpha;
	function set_alpha(value:Float):Float
	{
		if (value < 0) value = 0;
		else if (value > 1) value = 1;
		return _alpha = value;
	}

	// Color tinting information.
	var _color:Color;
	var _alpha:Float;
	var _red:Float;
	var _green:Float;
	var _blue:Float;

	// Backdrop information.
	var _region:IAtlasRegion;
	var _width:Int;
	var _height:Int;
	var _repeatX:Bool;
	var _repeatY:Bool;
}
