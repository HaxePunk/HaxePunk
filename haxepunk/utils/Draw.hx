package haxepunk.utils;

import flash.display.BlendMode;
import haxepunk.Entity;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.graphics.text.Text;
import haxepunk.graphics.hardware.DrawCommand;
import haxepunk.graphics.shader.ColorShader;
import haxepunk.graphics.shader.Shader;
import haxepunk.math.Vector2;
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
	public static var lineThickness:Float = 1;

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
		// a.set(x1, y1);
		// b.set(x2, y2);
		// b.subtract(a);
		// b.perpendicular();
		// b.normalize(lineThickness / 2);
		var dx:Float = -(x2 - x1);
		var dy:Float = y2 - y1;
		var length = Math.sqrt(dx * dx + dy * dy);
		if (length == 0) return;
		// normalize line and set delta to half thickness
		var ht = lineThickness / 2;
		var tx = dx;
		dx = (dy / length) * ht;
		dy = (tx / length) * ht;

		begin();
		drawQuad(
			x1 + dx, y1 + dy,
			x1 - dx, y1 - dy,
			x2 - dx, y2 - dy,
			x2 + dx, y2 + dy,
			color, alpha
		);
	}

	/**
	 * Draws a triangulated line polyline to the screen. This must be a closed loop of concave lines
	 * @param	points		An array of floats containing the points of the polyline. The array is ordered in x, y format and must have an even number of values.
	 */
	public static function polyline(points:Array<Float>, drawMiter:Bool = false)
	{
		if (points.length < 4 || (points.length % 2) == 1)
		{
			throw "Invalid number of values. Expected an even number greater than 4.";
		}

		var halfThick = lineThickness / 2;
		var vec = [];
		var last = Std.int(points.length / 2);
		var pos = new Vector2(points[0], points[1]), // current
			a = new Vector2(pos.x, pos.y),
			b = new Vector2(pos.x, pos.y),
			prev = new Vector2(points[0] - points[2], points[1] - points[3]), // direction
			next = new Vector2(prev.x, prev.y),
			inner = new Vector2(),
			outer = new Vector2(),
			v1 = new Vector2();
		begin();

		// a, b - contain last 2 points to render from
		// c - current point
		// u,v - direction vectors for last and next lines

		// calculate first end cap
		next.perpendicular();
		next.normalize(halfThick);
		a.add(next);
		b.subtract(next);

		var over180, angle, index;
		var alt:Vector2;
		var tmp = new Vector2();

		for (i in 1...last-1)
		{
			index = i * 2;

			pos.x = points[index];
			pos.y = points[index+1];

			// vector v (difference between current and next)
			next.x = pos.x - points[index + 2];
			next.y = pos.y - points[index + 3];

			over180 = prev.zcross(next) > 0;
			// calculate half angle from two vectors
			angle = Math.acos(prev.dot(next) / (prev.length * next.length)) / 2;

			inner.copyFrom(prev);
			inner.normalize(1);
			outer.copyFrom(next);
			outer.normalize(1);
			inner.add(outer);
			inner.perpendicular();
			if (over180)
			{
				inner.inverse();
			}
			inner.normalize(halfThick / Math.cos(angle));
			outer.copyFrom(inner); // save for miter joint
			inner.add(pos);

			// calculate joint points
			prev.perpendicular();
			prev.normalize(halfThick);

			v1.copyFrom(next);
			v1.perpendicular();
			v1.normalize(halfThick);

			if (!over180)
			{
				prev.inverse();
				v1.inverse();
			}

			prev.add(pos);
			v1.add(pos);

			// draw line connection
			alt = over180 ? prev : inner;
			command.addTriangle(a.x, a.y, 0, 0, b.x, b.y, 0, 0, alt.x, alt.y, 0, 0, color, alpha);
			command.addTriangle(b.x, b.y, 0, 0, prev.x, prev.y, 0, 0, inner.x, inner.y, 0, 0, color, alpha);
			// draw bevel joint
			command.addTriangle(v1.x, v1.y, 0, 0, prev.x, prev.y, 0, 0, inner.x, inner.y, 0, 0, color, alpha);
			if (drawMiter)
			{
				command.addTriangle(v1.x, v1.y, 0, 0, prev.x, prev.y, 0, 0, pos.x - outer.x, pos.y - outer.y, 0, 0, color, alpha);
			}

			if (over180)
			{
				a.copyFrom(v1);
				b.copyFrom(inner);
			}
			else
			{
				a.copyFrom(inner);
				b.copyFrom(v1);
			}

			prev.copyFrom(next);
		}

		// end cap
		prev.copyFrom(pos);
		next.x = points[points.length - 2];
		next.y = points[points.length - 1];
		pos.y = -(prev.x - next.x);
		pos.x = prev.y - next.y;
		pos.normalize(halfThick);
		prev.copyFrom(next);
		prev.subtract(pos);
		next.add(pos);

		// draw final line
		command.addTriangle(a.x, a.y, 0, 0, b.x, b.y, 0, 0, prev.x, prev.y, 0, 0, color, alpha);
		command.addTriangle(b.x, b.y, 0, 0, prev.x, prev.y, 0, 0, next.x, next.y, 0, 0, color, alpha);
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
		polyline([x, y, x2, y, x2, y2, x, y2]);
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
			color, alpha
		);
	}

	/**
	 * Draws a circle to the screen.
	 * @param	x			X position of the circle's center.
	 * @param	y			Y position of the circle's center.
	 * @param	radius		Radius of the circle.
	 * @param	segments	Increasing will smooth the circle but takes longer to render. Must be a value greater than zero.
	 */
	public static inline function circle(x:Float, y:Float, radius:Float, segments:Int = 25)
	{
		arc(x, y, radius, 0, 2 * Math.PI, segments);
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
		var x1 = x,
			y1 = y + radius;
		begin();
		for (segment in 1...segments+1)
		{
			var theta = segment * radians;
			var x2 = x + (Math.sin(theta) * radius);
			var y2 = y + (Math.cos(theta) * radius);
			command.addTriangle(x, y, 0, 0, x1, y1, 0, 0, x2, y2, 0, 0, color, alpha);
			x1 = x2; y1 = y2;
		}
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
		var radians = angle / segments;
		var points = [];
		for (segment in 0...segments)
		{
			var theta = segment * radians + start;
			points.push(x + (Math.sin(theta) * radius));
			points.push(y + (Math.cos(theta) * radius));
		}
		polyline(points);
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
		var points:Array<Float> = [];
		points.push(x1);
		points.push(y1);

		var deltaT:Float = 1 / segments;

		for (segment in 1...segments)
		{
			var t:Float = segment * deltaT;
			var x:Float = (1 - t) * (1 - t) * x1 + 2 * t * (1 - t) * x2 + t * t * x3;
			var y:Float = (1 - t) * (1 - t) * y1 + 2 * t * (1 - t) * y2 + t * t * y3;
			points.push(x);
			points.push(y);
		}

		points.push(x3);
		points.push(y3);

		polyline(points);
	}

	/** @private Helper function to grab a DrawCommand object from the current scene */
	@:access(haxepunk.graphics.hardware.SceneSprite)
	static inline function begin()
	{
		if (shader == null) shader = new ColorShader();
		command = HXP.scene.sprite.batch.getDrawCommand(null, shader, false, blend, null);
	}

	/** @private Helper function to add a quad to the buffer */
	static function drawQuad(x1, y1, x2, y2, x3, y3, x4, y4, color, a)
	{
		command.addTriangle(x1, y1, 0, 0, x2, y2, 0, 0, x3, y3, 0, 0, color, a);
		command.addTriangle(x1, y1, 0, 0, x3, y3, 0, 0, x4, y4, 0, 0, color, a);
	}

	// Drawing information.
	static var command:DrawCommand;
}
