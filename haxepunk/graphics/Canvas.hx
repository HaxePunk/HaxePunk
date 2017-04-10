package haxepunk.graphics;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Graphics;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.utils.Color;
import haxepunk.utils.MathUtil;


/**
 * A  multi-purpose drawing canvas, can be sized beyond the normal Flash BitmapData limits.
 * Works only on flash and html5 targets.
 */
class Canvas extends Graphic
{
	/**
	 * Optional blend mode to use (see flash.display.BlendMode for blending modes).
	 */
	public var blend:BlendMode;

	/**
	 * Rotation of the canvas, in degrees.
	 */
	public var angle:Float;

	/**
	 * Scale of the canvas, effects both x and y scale.
	 */
	public var scale:Float;

	/**
	 * X scale of the canvas.
	 */
	public var scaleX:Float;

	/**
	 * Y scale of the canvas.
	 */
	public var scaleY:Float;

	/**
	 * Constructor.
	 * @param	width		Width of the canvas.
	 * @param	height		Height of the canvas.
	 */
	public function new(width:Int, height:Int)
	{
		super();
		_color = 0xFFFFFF;
		_red = _green = _blue = 1;
		_alpha = 1;
		_graphics = HXP.sprite.graphics;
		_matrix = new Matrix();
		_rect = new Rectangle();
		_colorTransform = new ColorTransform();
		_buffers = new Array<BitmapData>();
		_midBuffers = new Array<BitmapData>();
		angle = 0;
		scale = scaleX = scaleY = 1;

		_width = width;
		_height = height;
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

		if (_alpha == 1 && _color == 0xFFFFFF)
		{
			_tint = null;
			return _color;
		}
		_tint = _colorTransform;
		_tint.redMultiplier = _red;
		_tint.greenMultiplier = _green;
		_tint.blueMultiplier = _blue;
		_tint.alphaMultiplier = _alpha;
		_redrawBuffers = true;
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
		if (value > 1) value = 1;
		if (_alpha == value) return _alpha;
		_alpha = value;
		if (_alpha == 1 && _color == 0xFFFFFF)
		{
			_tint = null;
			return _alpha;
		}
		_tint = _colorTransform;
		_tint.redMultiplier = _red;
		_tint.greenMultiplier = _green;
		_tint.blueMultiplier = _blue;
		_tint.alphaMultiplier = _alpha;
		_redrawBuffers = true;
		return _alpha;
	}

	/**
	 * Width of the canvas.
	 */
	public var width(get, null):Int;
	function get_width():Int return _width;

	/**
	 * Height of the canvas.
	 */
	public var height(get, null):Int;
	function get_height():Int return _height;

	// Buffer information.
	var _buffers:Array<BitmapData>;
	var _midBuffers:Array<BitmapData>;
	var _redrawBuffers:Bool=false;
	var _width:Int;
	var _height:Int;
	var _maxWidth:Int = 4000;
	var _maxHeight:Int = 4000;

	// Color tinting information.
	var _color:Color;
	var _alpha:Float;
	var _tint:ColorTransform;
	var _colorTransform:ColorTransform;
	var _matrix:Matrix;
	var _red:Float;
	var _green:Float;
	var _blue:Float;

	// Canvas reference information.
	var _ref:BitmapData;
	var _refWidth:Int;
	var _refHeight:Int;

	// Global objects.
	var _rect:Rectangle;
	var _graphics:Graphics;
}
