package haxepunk.utils;

import flash.display.BlendMode;
import haxepunk.Entity;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.graphics.Text;
import haxepunk.graphics.atlas.DrawCommand;
import haxepunk.graphics.shaders.ColorShader;
import haxepunk.graphics.shaders.Shader;
import haxepunk.utils.Color;

/**
 * Static class with access to miscellanious drawing functions.
 * These functions are not meant to replace Graphic components
 * for Entities, but rather to help with testing and debugging.
 * The primitives are drawn in screen space and do not utilize
 * camera movement unless passed as x/y values.
 */
class Draw
{
	/**
	 * The blending mode used by Draw functions. This will not
	 * apply to Draw.line(), but will apply to Draw.linePlus().
	 */
	public static var blend:BlendMode;

	/**
	 * The shader used by Draw functions. This will default to
	 * a color shader if not set.
	 */
	public static var shader:Shader;

	/**
	 * The red, green, and blue values in a single integer value.
	 */
	public static var color:Color = 0xFFFFFF;

	/**
	 * The alpha value to draw. Ranges between 0-1 where 0 is completely transparent and 1 is opaque.
	 */
	public static var alpha:Float = 1;

	/**
	 * The line thickness to use when drawing lines. Defaults to a single pixel wide.
	 */
	public static var thickness:Float = 1;

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
		// create perpendicular delta vector
		var dx:Float = -(x2 - x1);
		var dy:Float = y2 - y1;
		var length = Math.sqrt(dx * dx + dy * dy);
		if (length == 0) return;
		// normalize line and set delta to half thickness
		var ht = thickness / 2;
		var tx = dx;
		dx = (dy / length) * ht;
		dy = (tx / length) * ht;

		begin();
		drawQuad(
			x1 + dx, y1 + dy,
			x1 - dx, y1 - dy,
			x2 - dx, y2 - dy,
			x2 + dx, y2 + dy,
			color.red, color.green, color.blue, alpha
		);
	}

	/**
	 * Draws a triangulated line polygon to the screen. This must be a closed loop of concave lines
	 * @param	points		An array of floats containing the points of the polygon. The array is ordered in x, y format and must have an even number of values.
	 */
	public static function polygon(points:Array<Float>)
	{
		if (points.length < 4 || (points.length % 2) == 1)
		{
			throw "Invalid number of points. Expected an even number greater than 4.";
		}

		var red = color.red,
			green = color.green,
			blue = color.blue;

		var ht = thickness / 2;
		var vec = [];
		for (i in 0...Std.int(points.length / 2))
		{
			var index = i * 2;

			var x = points[index];
			var y = points[index+1];

			// vector u (difference between last and current)
			var u1 = x - wrap(points, index - 2);
			var u2 = y - wrap(points, index - 1);

			// vector v (difference between current and next)
			var v1 = x - wrap(points, index + 2);
			var v2 = y - wrap(points, index + 3);

			// delta vector (adding u and v)
			var dx = u1 + v1;
			var dy = u2 + v2;

			var length = Math.sqrt(dx * dx + dy * dy);
			if (length == 0) length = 1; // don't divide by zero!
			// normalize line and set delta to half thickness
			dx = (dx / length) * ht;
			dy = (dy / length) * ht;
			vec.push([x + dx, y + dy, x - dx, y - dy]);
		}

		begin();
		var x1 = vec[0][0], y1 = vec[0][1],
			x2 = vec[0][2], y2 = vec[0][3];
		for (i in 1...vec.length)
		{
			var x3 = vec[i][0], y3 = vec[i][1],
				x4 = vec[i][2], y4 = vec[i][3];
			if (y4 < y3 || x4 < x3) // HACK! preventing twist in some cases??
			{
				drawQuad(
					x1, y1, x2, y2,
					x4, y4, x3, y3,
					red, green, blue, alpha
				);
			}
			else
			{
				drawQuad(
					x1, y1, x2, y2,
					x3, y3, x4, y4,
					red, green, blue, alpha
				);
			}
			x1 = x3; y1 = y3;
			x2 = x4; y2 = y4;
		}

		drawQuad(
			x1, y1,
			x2, y2,
			vec[0][2], vec[0][3],
			vec[0][0], vec[0][1],
			red, green, blue, alpha
		);
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
		var x2 = x + width,
			y2 = y + height;
		polygon([x, y, x2, y, x2, y2, x, y2]);
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
		begin();
		drawQuad(
			x, y,
			x + width, y,
			x + width, y + height,
			x, y + height,
			color.red, color.green, color.blue, alpha
		);
	}

	/**
	 * Draws a circle to the screen.
	 * @param	x			X position of the circle's center.
	 * @param	y			Y position of the circle's center.
	 * @param	radius		Radius of the circle.
	 * @param	segments	Increasing will smooth the circle but takes longer to render. Must be a value greater than zero.
	 */
	public static function circle(x:Float, y:Float, radius:Float, segments:Int = 25)
	{
		var radians = (2 * Math.PI) / segments;
		var points = [];
		for (segment in 0...segments)
		{
			var theta = (segment + 1) * radians;
			points.push(x + (Math.sin(theta) * radius));
			points.push(y + (Math.cos(theta) * radius));
		}
		polygon(points);
	}

	/**
	 * Draws a circle to the screen.
	 * @param	x			X position of the circle's center.
	 * @param	y			Y position of the circle's center.
	 * @param	radius		Radius of the circle.
	 * @param	segments	Increasing will smooth the circle but takes longer to render. Must be a value greater than zero.
	 */
	public static function circleFilled(x:Float, y:Float, radius:Float, segments:Int = 25)
	{
		var radians = (2 * Math.PI) / segments;
		var r = color.red,
			g = color.green,
			b = color.blue;
		var x1 = x,
			y1 = y + radius;
		begin();
		for (segment in 1...segments+1)
		{
			var theta = segment * radians;
			var x2 = x + (Math.sin(theta) * radius);
			var y2 = y + (Math.cos(theta) * radius);
			command.addTriangle(x, y, 0, 0, x1, y1, 0, 0, x2, y2, 0, 0, r, g, b, alpha);
			x1 = x2; y1 = y2;
		}
	}

	/**
	 * Draws a quadratic curve.
	 * @param	x1		X start.
	 * @param	y1		Y start.
	 * @param	x2		X control point, used to determine the curve.
	 * @param	y2		Y control point, used to determine the curve.
	 * @param	x3		X finish.
	 * @param	y3		Y finish.
	 */
	public static function curve(x1:Int, y1:Int, x2:Int, y2:Int, x3:Int, y3:Int)
	{
		throw "Not implemented yet";
	}

	/** @private Helper function to grab a DrawCommand object from the current scene */
	@:access(haxepunk.graphics.atlas.SceneSprite)
	static inline function begin()
	{
		if (shader == null) shader = new ColorShader();
		command = HXP.scene.sprite.batch.getDrawCommand(null, shader, false, blend, null);
	}

	/** @private Helper function to add a quad to the buffer */
	static function drawQuad(x1, y1, x2, y2, x3, y3, x4, y4, r, g, b, a)
	{
		command.addTriangle(x1, y1, 0, 0, x2, y2, 0, 0, x3, y3, 0, 0, r, g, b, a);
		command.addTriangle(x1, y1, 0, 0, x3, y3, 0, 0, x4, y4, 0, 0, r, g, b, a);
	}

	/** @private Helper function that wraps an index around the list limits */
	static inline function wrap<T>(list:Array<T>, index:Int):T
	{
		return list[index < 0 ? list.length + index : index % list.length];
	}

	// Drawing information.
	static var command:DrawCommand;
}
