package com.haxepunk.masks;

import com.haxepunk.HXP;
import com.haxepunk.Mask;
import com.haxepunk.math.Projection;
import com.haxepunk.math.Vector;
import flash.display.Graphics;
import flash.geom.Point;

class Polygon extends Hitbox
{
	/**
	 * The polygon rotates around this point when the angle is set.
	 */
	public var origin:Point;

	/**
	 * Constructor.
	 * @param	points   an array of coordinates that define the polygon (must have at least 3)
	 * @param	origin   origin point of the polygon
	 */
	public function new(points:Array<Point>, ?origin:Point)
	{
		super();
		_points = points;

		_check.set(Type.getClassName(Hitbox), collideHitbox);
		_check.set(Type.getClassName(Circle), collideCircle);
		_check.set(Type.getClassName(Polygon), collidePolygon);
		_check.set(Type.getClassName(Grid), collideGrid);

		this.origin = origin != null ? origin : new Point();
		_angle = 0;

		updateAxes();
	}

	private inline function generateAxes():Void
	{
		_axes = new Array<Vector>();
		var store:Float;
		var numberOfPoints:Int = _points.length - 1;
		for (i in 0...numberOfPoints)
		{
			var edge = new Vector();
			edge.x = _points[i].x - _points[i + 1].x;
			edge.y = _points[i].y - _points[i + 1].y;

			//Get the axis which is perpendicular to the edge
			store = edge.y;
			edge.y = -edge.x;
			edge.x = store;
			edge.normalize(1);

			_axes.push(edge);
		}
		var edge = new Vector();
		//Add the last edge
		edge.x = _points[numberOfPoints].x - _points[0].x;
		edge.y = _points[numberOfPoints].y - _points[0].y;
		store = edge.y;
		edge.y = -edge.x;
		edge.x = store;
		edge.normalize(1);

		_axes.push(edge);
	}

	private inline function removeDuplicateAxes():Void
	{
		for (ii in 0..._axes.length)
		{
			for (jj in 0..._axes.length)
			{
				if (ii == jj || Math.max(ii, jj) >= _axes.length) continue;
				// if the first vector is equal or similar to the second vector,
				// remove it from the list. (for example, [1, 1] and [-1, -1]
				// share the same relative path)
				if ((_axes[ii].x == _axes[jj].x && _axes[ii].y == _axes[jj].y)
					|| ( -_axes[ii].x == _axes[jj].x && -_axes[ii].y == _axes[jj].y))//First axis inverted
				{
					_axes.splice(jj, 1);
				}
			}
		}
	}

	/**
	 * May be very slow, mainly added for completeness sake
	 * Checks for collisions along the edges of the polygon
	 * @param	grid	Grid to check collision against
	 * @return	If collided
	 */
	public function collideGrid(grid:Grid):Bool
	{
		for (ii in 0..._points.length - 1)
		{
			var p1X = (parent.x + _points[ii].x) / grid.tileWidth;
			var p1Y = (parent.y + _points[ii].y) / grid.tileHeight;
			var p2X = (parent.x + _points[ii + 1].x) / grid.tileWidth;
			var p2Y = (parent.y +  _points[ii + 1].y) / grid.tileHeight;

			var k = (p2Y - p1Y) / (p2X - p1X);
			var m = p1Y - k * p1X;

			var min:Float;
			var max:Float;

			if (p2X > p1X) { min = p1X; max = p2X; }
			else { max = p1X; min = p2X; }

			var x = min;
			while (x < max)
			{
				var y = Std.int(k * x + m);
				if (grid.getTile(Std.int(x), y))
					return true;

				x++;
			}
		}
		//Check the last point -> first point
		var p1X = (parent.x + _points[_points.length - 1].x) / grid.tileWidth;
		var p1Y = (parent.y + _points[_points.length - 1].y) / grid.tileHeight;
		var p2X = (parent.x + _points[0].x) / grid.tileWidth;
		var p2Y = (parent.y +  _points[0].y) / grid.tileHeight;

		var k = (p2Y - p1Y) / (p2X - p1X);
		var m = p1Y - k * p1X;

		var min:Float;
		var max:Float;

		if (p2X > p1X) { min = p1X; max = p2X; }
		else { max = p1X; min = p2X; }

		var x = min;
		while (x < max)
		{
			var y = Std.int(k * x + m);
			if (grid.getTile(Std.int(x), y))
				return true;

			x++;
		}

		return false;
	}

	/**
	 * Checks for collision with a circle.
	 * @param	circle	Circle to check collision against
	 * @return	If collided
	 */
	public function collideCircle(circle:Circle):Bool
	{
		var offset:Float;

		//First find the point closest to the circle
		var distanceSquared:Float = HXP.NUMBER_MAX_VALUE;
		var closestPoint = null;
		for (p in _points)
		{
			var dx = parent.x + p.x - circle.parent.x - circle.radius;
			var dy = parent.y + p.y - circle.parent.y - circle.radius;
			var tempDistance = dx * dx + dy * dy;

			if (tempDistance < distanceSquared)
			{
				distanceSquared = tempDistance;
				closestPoint = p;
			}
		}

		var offsetX = parent.x - circle.parent.x - circle.radius;
		var offsetY = parent.y - circle.parent.y - circle.radius;

		//Get the vector between the closest point and the circle
		//and get the normal of it
		_axis.x = circle.parent.y - parent.y + closestPoint.y;
		_axis.y = parent.x + closestPoint.x - circle.parent.x;
		_axis.normalize(1);

		project(_axis, firstProj);
		circle.project(_axis, secondProj);

		offset = offsetX * _axis.x + offsetY * _axis.y;
		firstProj.min += offset;
		firstProj.max += offset;

		if (firstProj.overlaps(secondProj))
		{
			return false;
		}

		for (a in _axes)
		{
			project(a, firstProj);
			circle.project(a, secondProj);

			offset = offsetX * a.x + offsetY * a.y;
			firstProj.min += offset;
			firstProj.max += offset;

			if (firstProj.overlaps(secondProj))
			{
				return false;
			}
		}

		return true;
	}

	/**
	 * Checks for collisions with a hitbox
	 * @param	hitbox	Hitbox to check collision against
	 * @return	If collided
	 */
	public override function collideHitbox(hitbox:Hitbox):Bool
	{
		var offset:Float,
			offsetX:Float = parent.x - hitbox.parent.x,
			offsetY:Float = parent.y - hitbox.parent.y;

		project(vertical, firstProj);//Project on the horizontal axis of the hitbox
		hitbox.project(vertical, secondProj);

		firstProj.min += offsetY;
		firstProj.max += offsetY;

		if (firstProj.overlaps(secondProj))
		{
			return false;
		}

		project(horizontal, firstProj);//Project on the vertical axis of the hitbox
		hitbox.project(horizontal, secondProj);

		firstProj.min += offsetX;
		firstProj.max += offsetX;

		if (firstProj.overlaps(secondProj))
		{
			return false;
		}

		for (a in _axes)
		{
			project(a, firstProj);
			hitbox.project(a, secondProj);

			offset = offsetX * a.x + offsetY * a.y;
			firstProj.min += offset;
			firstProj.max += offset;

			if (firstProj.overlaps(secondProj))
			{
				return false;
			}
		}
		return true;
	}

	override private function collideMask(other:Mask):Bool
	{
		var offset:Float,
			offsetX:Float = parent.x - other.parent.x,
			offsetY:Float = parent.y - other.parent.y;

		project(vertical, firstProj); //Project on the horizontal axis of the hitbox
		other.project(vertical, secondProj);

		firstProj.min += offsetX;
		firstProj.max += offsetY;

		if (firstProj.overlaps(secondProj))
		{
			return false;
		}

		project(horizontal, firstProj); //Project on the vertical axis of the hitbox
		other.project(horizontal, secondProj);

		firstProj.min += offsetX;
		firstProj.max += offsetX;

		if (firstProj.overlaps(secondProj))
		{
			return false;
		}

		for (a in _axes)
		{
			project(a, firstProj);
			other.project(a, secondProj);

			var offset = offsetX * a.x + offsetY * a.y;
			firstProj.min += offset;
			firstProj.max += offset;

			if (firstProj.overlaps(secondProj))
			{
				return false;
			}
		}
		return true;
	}

	/**
	 * Checks for collision with a polygon.
	 * @param	other	Polygon to check collision against
	 * @return	If collided
	 */
	public function collidePolygon(other:Polygon):Bool
	{
		var offsetX = parent.x - other.parent.x;
		var offsetY = parent.y - other.parent.y;

		for (a in _axes)
		{
			project(a, firstProj);
			other.project(a, secondProj);

			//Shift the first info with the offset
			var offset = offsetX * a.x + offsetY * a.y;
			firstProj.min += offset;
			firstProj.max += offset;

			if (firstProj.overlaps(secondProj))
			{
				return false;
			}
		}

		for (a in other._axes)
		{
			project(a, firstProj);
			other.project(a, secondProj);

			//Shift the first info with the offset
			var offset = offsetX * a.x + offsetY * a.y;
			firstProj.min += offset;
			firstProj.max += offset;

			if (firstProj.overlaps(secondProj))
			{
				return false;
			}
		}
		return true;
	}

	public override function project(axis:Vector, projection:Projection):Void
	{
		var min:Float = axis.dot(_points[0]),
			max:Float = min;

		for (i in 1..._points.length)
		{
			var cur = axis.dot(_points[i]);

			if (cur < min)
			{
				min = cur;
			}
			else if (cur > max)
			{
				max = cur;
			}
		}
		projection.min = min;
		projection.max = max;
	}

	private function rotate(angle:Float):Void
	{
		angle *= HXP.RAD;

		for (p in _points)
		{
			var dx = p.x - origin.x;
			var dy = p.y - origin.y;

			var pointAngle = Math.atan2(dy, dx);
			var length = Math.sqrt(dx * dx + dy * dy);

			p.x = Math.cos(pointAngle + angle) * length + origin.x;
			p.y = Math.sin(pointAngle + angle) * length + origin.y;
		}
		for (ax in _axes)
		{

			var axisAngle = Math.atan2(ax.y, ax.x);

			ax.x = Math.cos(axisAngle + angle);
			ax.y = Math.sin(axisAngle + angle);
		}
		_angle += angle;
	}

#if debug
	override public function debugDraw(graphics:Graphics, scaleX:Float, scaleY:Float):Void
	{
		if (parent != null)
		{
			var	offsetX = parent.x - HXP.camera.x,
				offsetY = parent.y - HXP.camera.y;

			graphics.moveTo((points[_points.length - 1].x + offsetX) * scaleX , (_points[_points.length - 1].y + offsetY) * scaleY);
			for (ii in 0..._points.length)
			{
				graphics.lineTo((_points[ii].x + offsetX) * scaleX, (_points[ii].y + offsetY) * scaleY);
			}
		}
	}
#end

	/**
	 * Angle in degress that the polygon is rotated.
	 */
	public var angle(get_angle, set_angle):Float;
	private inline function get_angle():Float { return _angle; }
	private function set_angle(value:Float):Float
	{
		if (value == _angle) return value;
		rotate(_angle - value);
		if (list != null || parent != null) update();
		return _angle = value;
	}

	/**
	 * The points representing the polygon.
	 * If you need to set a point yourself instead of passing in a new Array<Point> you need to call update() to makes sure the axes update as well.
	 */
	public var points(get_points, set_points):Array<Point>;
	private inline function get_points():Array<Point> { return _points; }
	private function set_points(value:Array<Point>):Array<Point>
	{
		if (_points == value) return value;
		_points = value;

		if (list != null || parent != null) updateAxes();
		return _points;
	}

	/** Updates the parent's bounds for this mask. */
	override public function update()
	{
		project(horizontal, firstProj); //width
		_x = Math.ceil(firstProj.min);
		_width = Math.ceil(firstProj.max - firstProj.min);
		project(vertical, secondProj); //height
		_y = Math.ceil(secondProj.min);
		_height = Math.ceil(secondProj.max - secondProj.min);

		if (parent != null)
		{
			//update entity bounds
			parent.width = _width;
			parent.height = _height;

			//Since the collisioninfos haven't changed we can use them to calculate hitbox placement
			parent.originX = Std.int((_width - firstProj.max - firstProj.min)/2);
			parent.originY = Std.int((_height - secondProj.max - secondProj.min )/2);
		}

		// update parent list
		if (list != null) list.update();
	}

	public inline function updateAxes()
	{
		generateAxes();
		removeDuplicateAxes();
		update();
	}

	/**
	 * Creates a polygon with even sides
	 * @param	sides	The number of sides in the polygon
	 * @param	radius	The distance that the corners are at
	 * @param	angle	How much the polygon is rotated
	 * @return	The polygon
	 */
	public static function createPolygon(sides:Int = 3, radius:Float = 100, angle:Float = 0):Polygon
	{
		if (sides < 3) 
			throw "The polygon needs at least 3 sides";
		
		// create a return polygon
		// figure out the angles required
		var rotationAngle:Float = (Math.PI * 2) / sides;

		// loop through and generate each point
		var points = new Array<Point>();

		for (ii in 0...sides)
		{
			var tempAngle = ii * rotationAngle;
			var p = new Point();
			p.x = Math.cos(tempAngle) * radius;
			p.y = Math.sin(tempAngle) * radius;
			points.push(p);
		}
		// return the point
		var poly = new Polygon(points);
		poly.angle = angle;
		return poly;
	}

	/**
	 * Creates a polygon from an array were even numbers are x and odd are y
	 * @param	points	Array containing the polygon's points.
	 * 
	 * @return	The polygon
	 */
	public static function createFromArray(points:Array<Float>):Polygon
	{
		var p = new Array<Point>();

		var ii = 0;
		while (ii < points.length)
		{
			p.push(new Point(points[ii++], points[ii++]));
		}
		return new Polygon(p);
	}

	// Hitbox information.
	private var _angle:Float;
	private var _points:Array<Point>;
	private var _axes:Array<Vector>;

	private static var _axis = new Vector();
	private static var firstProj = new Projection();
	private static var secondProj = new Projection();

	public static var vertical = new Vector(0, 1);
	public static var horizontal = new Vector(1, 0);
}
