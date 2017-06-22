package haxepunk.utils;

import haxepunk.utils.BlendMode;
import haxepunk.Entity;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.graphics.text.Text;
import haxepunk.graphics.hardware.DrawCommand;
import haxepunk.graphics.shader.ColorShader;
import haxepunk.graphics.shader.Shader;
import haxepunk.math.Vector2;
import haxepunk.utils.Color;

class DrawContext
{
	/**
	 * The Scene to draw to. If null, will draw to the current active scene.
	 */
	public var scene:Scene;

	/**
	 * The blending mode used by Draw functions. This will not
	 * apply to Draw.line(), but will apply to Draw.linePlus().
	 */
	public var blend:BlendMode;

	/**
	 * The shader used by Draw functions. This will default to
	 * a color shader if not set.
	 */
	public var shader:Shader;

	/**
	 * Whether shapes should be drawn with antialiasing.
	 */
	public var smooth:Bool = true;

	/**
	 * The red, green, and blue values in a single integer value.
	 */
	public var color:Color = 0xFFFFFF;

	/**
	 * The alpha value to draw. Ranges between 0-1 where 0 is completely transparent and 1 is opaque.
	 */
	public var alpha:Float = 1;

	/**
	 * The line thickness to use when drawing lines. Defaults to a single pixel wide.
	 */
	public var lineThickness:Float = 1;

	public function new(lineThickness:Float = 1, color:Color = Color.White, alpha:Float = 1)
	{
		this.lineThickness = lineThickness;
		this.color = color;
		this.alpha = alpha;
	}

	/**
	 * Convenience function to set both color and alpha at the same time.
	 */
	public inline function setColor(color:Color = 0xFFFFFF, alpha:Float = 1)
	{
		this.color = color;
		this.alpha = alpha;
	}

	/**
	 * Draws a straight line.
	 * @param	x1			Starting x position.
	 * @param	y1			Starting y position.
	 * @param	x2			Ending x position.
	 * @param	y2			Ending y position.
	 */
	public function line(x1:Float, y1:Float, x2:Float, y2:Float)
	{
		// create perpendicular delta vector
		var a = new Vector2(x1, y1);
		var b = new Vector2(x2 - a.x, y2 - a.y);
		b.normalize(lineThickness / 2);
		b.perpendicular();

		begin();
		drawQuad(
			x1 + b.x, y1 + b.y,
			x1 - b.x, y1 - b.y,
			x2 - b.x, y2 - b.y,
			x2 + b.x, y2 + b.y
		);
	}

	/**
	 * Draws a triangulated line polyline to the screen. This must be a closed loop of concave lines
	 * @param	points		An array of floats containing the points of the polyline. The array is ordered in x, y format and must have an even number of values.
	 */
	public function polyline(points:Array<Float>, miterJoint:Bool = false)
	{
		if (points.length < 4 || (points.length % 2) == 1)
		{
			throw "Invalid number of values. Expected an even number greater than 4.";
		}

		var halfThick = lineThickness / 2;
		var last = Std.int(points.length / 2);
		var a        = new Vector2(),
			b        = new Vector2(),
			pos      = new Vector2(points[0], points[1]), // current
			prev     = new Vector2(pos.x - points[2], pos.y - points[3]), // direction
			next     = new Vector2(prev.x, prev.y),
			inner    = new Vector2(),
			outer    = new Vector2(),
			nextPrev = new Vector2();
		begin();

		a.set(pos.x, pos.y);
		b.set(pos.x, pos.y);

		// calculate first cap
		next.perpendicular();
		next.normalize(halfThick);
		a.add(next);
		b.subtract(next);

		prev.normalize(1); // unit length

		var over180:Bool, angle:Float, index:Int;

		for (i in 1...last-1)
		{
			index = i * 2;

			pos.x = points[index];
			pos.y = points[index+1];

			// vector v (difference between current and next)
			next.x = pos.x - points[index + 2];
			next.y = pos.y - points[index + 3];

			next.normalize(1); // unit length
			nextPrev.copyFrom(next); // we clobber the "next" value so it needs to be saved

			over180 = prev.zcross(next) > 0;
			// calculate half angle from two vectors
			// normally this would require knowing the vector lengths but because
			// they both should be unit vectors we can ignore dividing by length
			angle = Math.acos(prev.dot(next)) / 2;

			inner.copyFrom(prev);
			inner.add(next);
			inner.perpendicular();
			if (over180)
			{
				inner.inverse();
			}
			inner.normalize(halfThick / Math.cos(angle));
			if (miterJoint)
			{
				outer.copyFrom(pos);
				outer.subtract(inner);
			}
			inner.add(pos);

			// calculate joint points
			prev.perpendicular();
			prev.normalize(halfThick);

			next.perpendicular();
			next.normalize(halfThick);

			if (!over180)
			{
				prev.inverse();
				next.inverse();
			}

			prev.add(pos);
			next.add(pos);

			// draw line connection
			if (over180)
			{
				drawTriangle(a, b, prev);
			}
			else
			{
				drawTriangle(a, b, inner);
			}
			drawTriangle(b, prev, inner);
			// draw bevel joint
			drawTriangle(next, prev, inner);
			if (miterJoint)
			{
				drawTriangle(next, prev, outer);
			}

			if (over180)
			{
				a.copyFrom(next);
				b.copyFrom(inner);
			}
			else
			{
				a.copyFrom(inner);
				b.copyFrom(next);
			}

			prev.copyFrom(nextPrev);
		}

		// end cap
		next.x = points[points.length - 2];
		next.y = points[points.length - 1];
		pos.subtract(next);
		pos.perpendicular();
		pos.normalize(halfThick);
		prev.copyFrom(next);
		prev.add(pos);
		next.subtract(pos);

		// draw final line
		drawTriangle(a, b, prev);
		drawTriangle(b, prev, next);
	}

	/**
	 * Draws a rectangle outline. Lines are drawn inside the width and height.
	 * @param	x			X position of the rectangle.
	 * @param	y			Y position of the rectangle.
	 * @param	width		Width of the rectangle.
	 * @param	height		Height of the rectangle.
	 * @since	2.5.2
	 */
	public function rect(x:Float, y:Float, width:Float, height:Float)
	{
		var ht = lineThickness / 2;
		var x2 = x + width,
			y2 = y + height;
		line(x - ht, y , x2 + ht, y ); // top
		line(x - ht, y2, x2 + ht, y2); // bottom
		line(x , y + ht, x , y2 - ht); // left
		line(x2, y + ht, x2, y2 - ht); // right
	}

	/**
	 * Draws a filled rectangle.
	 * @param	x			X position of the rectangle.
	 * @param	y			Y position of the rectangle.
	 * @param	width		Width of the rectangle.
	 * @param	height		Height of the rectangle.
	 * @since	4.0.0
	 */
	public function rectFilled(x:Float, y:Float, width:Float, height:Float)
	{
		begin();
		drawQuad(
			x, y,
			x + width, y,
			x + width, y + height,
			x, y + height
		);
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
	public inline function circle(x:Float, y:Float, radius:Float, segments:Int = 25, scaleX:Float = 1, scaleY:Float = 1)
	{
		var radians = 2 * Math.PI / segments;
		var halfThick = lineThickness / 2;
		var innerRadius = radius - halfThick;
		var outerRadius = radius + halfThick;
		var inner = new Vector2(),
			outer = new Vector2(),
			lastOuter = new Vector2(),
			lastInner = new Vector2();

		begin();

		for (segment in 0...segments+1)
		{
			var theta = segment * radians;
			var sin = Math.sin(theta);
			var cos = Math.cos(theta);
			inner.set(x + sin * innerRadius * scaleX, y + cos * innerRadius * scaleY);
			outer.set(x + sin * outerRadius * scaleX, y + cos * outerRadius * scaleY);

			if (segment != 0)
			{
				drawTriangle(lastInner, lastOuter, outer);
				drawTriangle(lastInner, outer, inner);
			}

			lastOuter.copyFrom(outer);
			lastInner.copyFrom(inner);
		}
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
	public function circleFilled(x:Float, y:Float, radius:Float, segments:Int = 25, scaleX:Float = 1, scaleY:Float = 1)
	{
		var radians = (2 * Math.PI) / segments;
		var x1 = x,
			y1 = y + radius;
		begin();
		for (segment in 1...segments+1)
		{
			var theta = segment * radians;
			var x2 = x + (Math.sin(theta) * radius) * scaleX;
			var y2 = y + (Math.cos(theta) * radius) * scaleY;
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
	public function arc(x:Float, y:Float, radius:Float, start:Float, angle:Float, segments:Int = 25)
	{
		var radians = angle / segments;
		var points = [];
		for (segment in 0...segments+1)
		{
			var theta = segment * radians + start;
			points.push(x + (Math.sin(theta) * radius));
			points.push(y + (Math.cos(theta) * radius));
		}
		polyline(points, true);
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
	public function curve(x1:Int, y1:Int, x2:Int, y2:Int, x3:Int, y3:Int, segments:Int = 25)
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
	@:access(haxepunk.graphics.hardware.SceneRenderer)
	inline function begin()
	{
		if (shader == null) shader = new ColorShader();
		var scene = (this.scene == null) ? (HXP.renderingScene == null ? HXP.scene : HXP.renderingScene) : this.scene;
		command = scene.renderer.batch.getDrawCommand(null, shader, smooth, blend, null);
	}

	inline function drawTriangle(v1:Vector2, v2:Vector2, v3:Vector2):Void
	{
		command.addTriangle(v1.x, v1.y, 0, 0, v2.x, v2.y, 0, 0, v3.x, v3.y, 0, 0, color, alpha);
	}

	/** @private Helper function to add a quad to the buffer */
	inline function drawQuad(x1, y1, x2, y2, x3, y3, x4, y4)
	{
		command.addTriangle(x1, y1, 0, 0, x2, y2, 0, 0, x3, y3, 0, 0, color, alpha);
		command.addTriangle(x1, y1, 0, 0, x3, y3, 0, 0, x4, y4, 0, 0, color, alpha);
	}

	// Drawing information.
	var command:DrawCommand;
}
