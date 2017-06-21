package haxepunk.utils;

import flash.display.BlendMode;
import haxepunk.graphics.shader.Shader;

/**
 * Static class with access to miscellanious drawing functions.
 * These functions are not meant to replace Graphic components
 * for Entities, but rather to help with testing and debugging.
 * The primitives are drawn in screen space and do not utilize
 * camera movement unless passed as x/y values.
 */
class Draw
{
	@:isVar static var instance(get, null):DrawContext;
	static inline function get_instance()
	{
		if (instance == null) instance = new DrawContext();
		return instance;
	}

	/**
	 * The blending mode used by Draw functions. This will not
	 * apply to Draw.line(), but will apply to Draw.linePlus().
	 */
	public static var blend(get, set):BlendMode;
	static inline function get_blend() return instance.blend;
	static inline function set_blend(v:BlendMode) return instance.blend = v;

	/**
	 * The shader used by Draw functions. This will default to
	 * a color shader if not set.
	 */
	public static var shader(get, set):Shader;
	static inline function get_shader() return instance.shader;
	static inline function set_shader(v:Shader) return instance.shader = v;

	/**
	 * Whether shapes should be drawn with antialiasing.
	 */
	public static var smooth(get, set):Bool;
	static inline function get_smooth() return instance.smooth;
	static inline function set_smooth(v:Bool) return instance.smooth = v;

	/**
	 * The red, green, and blue values in a single integer value.
	 */
	public static var color(get, set):Color;
	static inline function get_color() return instance.color;
	static inline function set_color(v:Color) return instance.color = v;

	/**
	 * The alpha value to draw. Ranges between 0-1 where 0 is completely transparent and 1 is opaque.
	 */
	public static var alpha(get, set):Float;
	static inline function get_alpha() return instance.alpha;
	static inline function set_alpha(v:Float) return instance.alpha = v;

	/**
	 * The line thickness to use when drawing lines. Defaults to a single pixel wide.
	 */
	public static var lineThickness(get, set):Float;
	static inline function get_lineThickness() return instance.lineThickness;
	static inline function set_lineThickness(v:Float) return instance.lineThickness = v;

	/**
	 * Convenience function to set both color and alpha at the same time.
	 */
	public static inline function setColor(color:Color = 0xFFFFFF, alpha:Float = 1)
	{
		Draw.color = color;
		Draw.alpha = alpha;
	}

	/**
	 * Draws a straight line.
	 * @param	x1			Starting x position.
	 * @param	y1			Starting y position.
	 * @param	x2			Ending x position.
	 * @param	y2			Ending y position.
	 */
	public static function line(x1:Float, y1:Float, x2:Float, y2:Float)
	{
		instance.line(x1, y1, x2, y2);
	}

	/**
	 * Draws a triangulated line polyline to the screen. This must be a closed loop of concave lines
	 * @param	points		An array of floats containing the points of the polyline. The array is ordered in x, y format and must have an even number of values.
	 */
	public static function polyline(points:Array<Float>, miterJoint:Bool = false)
	{
		instance.polyline(points, miterJoint);
	}

	/**
	 * Draws a rectangle outline. Lines are drawn inside the width and height.
	 * @param	x			X position of the rectangle.
	 * @param	y			Y position of the rectangle.
	 * @param	width		Width of the rectangle.
	 * @param	height		Height of the rectangle.
	 * @since	2.5.2
	 */
	public static function rect(x:Float, y:Float, width:Float, height:Float)
	{
		instance.rect(x, y, width, height);
	}

	/**
	 * Draws a filled rectangle.
	 * @param	x			X position of the rectangle.
	 * @param	y			Y position of the rectangle.
	 * @param	width		Width of the rectangle.
	 * @param	height		Height of the rectangle.
	 * @since	4.0.0
	 */
	public static function rectFilled(x:Float, y:Float, width:Float, height:Float)
	{
		instance.rectFilled(x, y, width, height);
	}

	/**
	 * Draws a circle to the screen.
	 * @param	x			X position of the circle's center.
	 * @param	y			Y position of the circle's center.
	 * @param	radius		Radius of the circle.
	 * @param	segments	Increasing will smooth the circle but takes longer to render. Must be a value greater than zero.
	 * @param	scaleX		Scales the circle horizontally.
	 * @param	scaleY		Scales the circle vertically.
	 */
	public static inline function circle(x:Float, y:Float, radius:Float, segments:Int = 25, scaleX:Float = 1, scaleY:Float = 1)
	{
		instance.circle(x, y, radius, segments, scaleX, scaleY);
	}

	/**
	 * Draws a circle to the screen.
	 * @param	x			X position of the circle's center.
	 * @param	y			Y position of the circle's center.
	 * @param	radius		Radius of the circle.
	 * @param	segments	Increasing will smooth the circle but takes longer to render. Must be a value greater than zero.
	 * @param	scaleX		Scales the circle horizontally.
	 * @param	scaleY		Scales the circle vertically.
	 */
	public static function circleFilled(x:Float, y:Float, radius:Float, segments:Int = 25, scaleX:Float = 1, scaleY:Float = 1)
	{
		instance.circleFilled(x, y, radius, segments, scaleX, scaleY);
	}

	/**
	 * Draws a circle to the screen.
	 * @param	x			X position of the circle's center.
	 * @param	y			Y position of the circle's center.
	 * @param	radius		Radius of the circle.
	 * @param	start		The starting angle in radians.
	 * @param	angle		The arc size in radians.
	 * @param	segments	Increasing will smooth the circle but takes longer to render. Must be a value greater than zero.
	 */
	public static function arc(x:Float, y:Float, radius:Float, start:Float, angle:Float, segments:Int = 25)
	{
		instance.arc(x, y, radius, start, angle, segments);
	}

	/**
	 * Draws a quadratic curve.
	 * @param	x1			X start.
	 * @param	y1			Y start.
	 * @param	x2			X control point, used to determine the curve.
	 * @param	y2			Y control point, used to determine the curve.
	 * @param	x3			X finish.
	 * @param	y3			Y finish.
	 * @param	segments	Increasing will smooth the curve but takes longer to render. Must be a value greater than zero.
	 */
	public static function curve(x1:Int, y1:Int, x2:Int, y2:Int, x3:Int, y3:Int, segments:Int = 25)
	{
		instance.curve(x1, y1, x2, y2, x3, y3, segments);
	}
}
