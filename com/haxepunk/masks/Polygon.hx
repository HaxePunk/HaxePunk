package com.haxepunk.masks;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.Mask;
import com.haxepunk.masks.Circle;
import com.haxepunk.masks.Grid;
import com.haxepunk.masks.Hitbox;
import com.haxepunk.math.Projection;
import com.haxepunk.math.Vector;
import flash.display.Graphics;
import flash.geom.Point;

/**
 * Uses polygonal structure to check for collisions.
 */
class Polygon extends Hitbox
{
	/**
	 * The polygon rotates around this point when the angle is set.
	 */
	public var origin:Point;


	// Polygon bounding box.
	public var minX(default, null):Int = 0;
	public var minY(default, null):Int = 0;
	public var maxX(default, null):Int = 0;
	public var maxY(default, null):Int = 0;

	/**
	 * Constructor.
	 * @param	points		An array of coordinates that define the polygon (must have at least 3).
	 * @param	origin	 	Pivot point for rotations.
	 */
	public function new(points:Array<Vector>, ?origin:Point)
	{
		super();
		if (points.length < 3) throw "The polygon needs at least 3 sides.";
		_points = points;

		_fakeEntity = new Entity();
		_fakeTileHitbox = new Hitbox();

		_check.set(Type.getClassName(Mask), collideMask);
		_check.set(Type.getClassName(Hitbox), collideHitbox);
		_check.set(Type.getClassName(Grid), collideGrid);
		_check.set(Type.getClassName(Circle), collideCircle);
		_check.set(Type.getClassName(Polygon), collidePolygon);

		this.origin = origin != null ? origin : new Point();
		_angle = 0;

		updateAxes();
	}

	/**
	 * Checks for collisions with an Entity.
	 */
	override private function collideMask(other:Mask):Bool
	{
		var offset:Float,
			offsetX:Float = _parent.x + _x - other._parent.x,
			offsetY:Float = _parent.y + _y - other._parent.y;

		// project on the vertical axis of the hitbox/mask
		project(vertical, firstProj);
		other.project(vertical, secondProj);

		firstProj.min += offsetY;
		firstProj.max += offsetY;

		// if firstProj not overlaps secondProj
		if (!firstProj.overlaps(secondProj))
		{
			return false;
		}

		// project on the horizontal axis of the hitbox/mask
		project(horizontal, firstProj);
		other.project(horizontal, secondProj);

		firstProj.min += offsetX;
		firstProj.max += offsetX;

		// if firstProj not overlaps secondProj
		if (!firstProj.overlaps(secondProj))
		{
			return false;
		}

		// project hitbox/mask on polygon axes
		// for a collision to be present all projections must overlap
		for (a in _axes)
		{
			project(a, firstProj);
			other.project(a, secondProj);

			offset = offsetX * a.x + offsetY * a.y;
			firstProj.min += offset;
			firstProj.max += offset;

			// if firstProj not overlaps secondProj
			if (!firstProj.overlaps(secondProj))
			{
				return false;
			}
		}
		return true;
	}

	/**
	 * Checks for collisions with a Hitbox.
	 */
	override private function collideHitbox(hitbox:Hitbox):Bool
	{
		var offset:Float,
			offsetX:Float = _parent.x + _x - hitbox._parent.x,
			offsetY:Float = _parent.y + _y - hitbox._parent.y;

		// project on the vertical axis of the hitbox
		project(vertical, firstProj);
		hitbox.project(vertical, secondProj);

		firstProj.min += offsetY;
		firstProj.max += offsetY;

		// if firstProj not overlaps secondProj
		if (!firstProj.overlaps(secondProj))
		{
			return false;
		}

		// project on the horizontal axis of the hitbox
		project(horizontal, firstProj);
		hitbox.project(horizontal, secondProj);

		firstProj.min += offsetX;
		firstProj.max += offsetX;

		// if firstProj not overlaps secondProj
		if (!firstProj.overlaps(secondProj))
		{
			return false;
		}

		// project hitbox on polygon axes
		// for a collision to be present all projections must overlap
		for (a in _axes)
		{
			project(a, firstProj);
			hitbox.project(a, secondProj);

			offset = offsetX * a.x + offsetY * a.y;
			firstProj.min += offset;
			firstProj.max += offset;

			// if firstProj not overlaps secondProj
			if (!firstProj.overlaps(secondProj))
			{
				return false;
			}
		}
		return true;
	}

	/**
	 * Checks for collisions with a Grid.
	 * May be slow, added for completeness sake.
	 *
	 * Internally sets up an Hitbox out of each solid Grid tile and uses that for collision check.
	 */
	private function collideGrid(grid:Grid):Bool
	{
		var tileW:Int = grid.tileWidth;
		var tileH:Int = grid.tileHeight;
		var solidTile:Bool;

		_fakeEntity.width = tileW;
		_fakeEntity.height = tileH;
		_fakeEntity.x = _parent.x;
		_fakeEntity.y = _parent.y;
		_fakeEntity.originX = grid._parent.originX + grid._x;
		_fakeEntity.originY = grid._parent.originY + grid._y;

		_fakeTileHitbox._width = tileW;
		_fakeTileHitbox._height = tileH;
		_fakeTileHitbox.parent = _fakeEntity;

		for (r in 0...grid.rows)
		{
			for (c in 0...grid.columns)
			{
				_fakeEntity.x = grid._parent.x + grid._x + c * tileW;
				_fakeEntity.y = grid._parent.y + grid._y + r * tileH;
				solidTile = grid.getTile(c, r);

				if (solidTile && collideHitbox(_fakeTileHitbox)) return true;
			}
		}
		return false;
	}

	/**
	 * Checks for collision with a circle.
	 */
	private function collideCircle(circle:Circle):Bool
	{
		var edgesCrossed:Int = 0;
		var p1:Vector, p2:Vector;
		var i:Int, j:Int;
		var nPoints:Int = _points.length;
		var offsetX:Float = _parent.x + _x;
		var offsetY:Float = _parent.y + _y;


		// check if circle center is inside the polygon
		i = 0;
		j = nPoints - 1;
		while (i < nPoints)
		{
			p1 = _points[i];
			p2 = _points[j];

			var distFromCenter:Float = (p2.x - p1.x) * (circle._y + circle._parent.y - p1.y - offsetY) / (p2.y - p1.y) + p1.x + offsetX;

			if ((p1.y + offsetY > circle._y + circle._parent.y) != (p2.y + offsetY > circle._y + circle._parent.y)
				&& (circle._x + circle._parent.x < distFromCenter))
			{
				edgesCrossed++;
			}
			j = i;
			i++;
		}

		if (edgesCrossed & 1 > 0) return true;

		// check if minimum distance from circle center to each polygon side is less than radius
		var radiusSqr:Float = circle.radius * circle.radius;
		var cx:Float = circle._x + circle._parent.x;
		var cy:Float = circle._y + circle._parent.y;
		var minDistanceSqr:Float = 0;
		var closestX:Float;
		var closestY:Float;

		i = 0;
		j = nPoints - 1;
		while (i < nPoints)
		{
			p1 = _points[i];
			p2 = _points[j];

			var segmentLenSqr:Float = (p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y);

			// find projection of center onto line (extended segment)
			var t:Float = ((cx - p1.x - offsetX) * (p2.x - p1.x) + (cy - p1.y - offsetY) * (p2.y - p1.y)) / segmentLenSqr;

			if (t < 0)
			{
				closestX = p1.x;
				closestY = p1.y;
			}
			else if (t > 1)
			{
				closestX = p2.x;
				closestY = p2.y;
			}
			else
			{
				closestX = p1.x + t * (p2.x - p1.x);
				closestY = p1.y + t * (p2.y - p1.y);
			}
			closestX += offsetX;
			closestY += offsetY;

			minDistanceSqr = (cx - closestX) * (cx - closestX) + (cy - closestY) * (cy - closestY);

			if (minDistanceSqr <= radiusSqr) return true;

			j = i;
			i++;
		}

		return false;
	}

	/**
	 * Checks for collision with a polygon.
	 */
	private function collidePolygon(other:Polygon):Bool
	{
		var offset:Float;
		var offsetX:Float = _parent.x + _x - other._parent.x;
		var offsetY:Float = _parent.y + _y - other._parent.y;

		// project other on this polygon axes
		// for a collision to be present all projections must overlap
		for (a in _axes)
		{
			project(a, firstProj);
			other.project(a, secondProj);

			// shift the first info with the offset
			offset = offsetX * a.x + offsetY * a.y;
			firstProj.min += offset;
			firstProj.max += offset;

			// if firstProj not overlaps secondProj
			if (!firstProj.overlaps(secondProj))
			{
				return false;
			}
		}

		// project this polygon on other polygon axes
		// for a collision to be present all projections must overlap
		for (a in other._axes)
		{
			project(a, firstProj);
			other.project(a, secondProj);

			// shift the first info with the offset
			offset = offsetX * a.x + offsetY * a.y;
			firstProj.min += offset;
			firstProj.max += offset;

			// if firstProj not overlaps secondProj
			if (!firstProj.overlaps(secondProj))
			{
				return false;
			}
		}
		return true;
	}

	/** Projects this polygon points on axis and returns min and max values in projection object. */
	override public function project(axis:Vector, projection:Projection):Void
	{
		var p:Vector = _points[0];

		var min:Float = axis.dot(p),
			max:Float = min;

		for (i in 1..._points.length)
		{
			p = _points[i];
			var cur:Float = axis.dot(p);

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

	override public function debugDraw(graphics:Graphics, scaleX:Float, scaleY:Float):Void
	{
		var	offsetX:Float = _parent.x + _x - HXP.camera.x,
			offsetY:Float = _parent.y + _y - HXP.camera.y;

		graphics.beginFill(0x0000FF, .3);

		graphics.moveTo((points[_points.length - 1].x + offsetX) * scaleX , (_points[_points.length - 1].y + offsetY) * scaleY);
		for (i in 0..._points.length)
		{
			graphics.lineTo((_points[i].x + offsetX) * scaleX, (_points[i].y + offsetY) * scaleY);
		}

		graphics.endFill();

		// draw pivot
		graphics.drawCircle((offsetX + origin.x) * scaleX, (offsetY + origin.y) * scaleY, 2);
	}

	/**
	 * Rotation angle (in degrees) of the polygon (rotates around origin point).
	 */
	public var angle(get, set):Float;
	private inline function get_angle():Float { return _angle; }
	private function set_angle(value:Float):Float
	{
		if (value != _angle)
		{
			rotate(value - _angle);
			if (list != null || parent != null) update();
		}
		return value;
	}

	/**
	 * The points representing the polygon.
	 *
	 * If you need to set a point yourself instead of passing in a new Array<Point> you need to call update()
	 * to make sure the axes update as well.
	 */
	public var points(get, set):Array<Vector>;
	private inline function get_points():Array<Vector> { return _points; }
	private function set_points(value:Array<Vector>):Array<Vector>
	{
		if (_points != value)
		{
			_points = value;
			if (list != null || parent != null) updateAxes();
		}
		return value;
	}

	/** Updates the parent's bounds for this mask. */
	override public function update():Void
	{
		project(horizontal, firstProj); // width
		var projX:Int = Math.round(firstProj.min);
		_width = Math.round(firstProj.max - firstProj.min);
		project(vertical, secondProj); // height
		var projY:Int = Math.round(secondProj.min);
		_height = Math.round(secondProj.max - secondProj.min);

		minX = projX;
		minY = projY;
		maxX = Math.round(minX + _width);
		maxY = Math.round(minY + _height);
		
		if (list != null)
		{
			// update parent list
			list.update();
		}
		else if (parent != null)
		{
			_parent.originX = -_x - projX;
			_parent.originY = -_y - projY;
			_parent.width = _width;
			_parent.height = _height;
		}
	}

	/**
	 * Creates a regular polygon (edges of same length).
	 * @param	sides	The number of sides in the polygon.
	 * @param	radius	The distance that the vertices are at.
	 * @param	angle	How much the polygon is rotated (in degrees).
	 * @return	The polygon
	 */
	public static function createPolygon(sides:Int = 3, radius:Float = 100, angle:Float = 0):Polygon
	{
		if (sides < 3) throw "The polygon needs at least 3 sides.";

		// figure out the angle required for each step
		var rotationAngle:Float = (Math.PI * 2) / sides;

		// loop through and generate each point
		var points:Array<Vector> = new Array<Vector>();

		for (i in 0...sides)
		{
			var tempAngle:Float = Math.PI + i * rotationAngle;
			var p:Vector = new Vector();
			p.x = Math.cos(tempAngle) * radius + radius;
			p.y = Math.sin(tempAngle) * radius + radius;
			points.push(p);
		}

		// return the polygon
		var poly:Polygon = new Polygon(points);
		poly.origin.x = radius;
		poly.origin.y = radius;
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
		var p:Array<Vector> = new Array<Vector>();

		var i:Int = 0;
		while (i < points.length)
		{
			p.push(new Vector(points[i++], points[i++]));
		}
		return new Polygon(p);
	}

	private function rotate(angleDelta:Float):Void
	{
		_angle += angleDelta;

		angleDelta *= HXP.RAD;

		var p:Vector;

		for (i in 0..._points.length)
		{
			p = _points[i];
			var dx:Float = p.x - origin.x;
			var dy:Float = p.y - origin.y;

			var pointAngle:Float = Math.atan2(dy, dx);
			var length:Float = Math.sqrt(dx * dx + dy * dy);

			p.x = Math.cos(pointAngle + angleDelta) * length + origin.x;
			p.y = Math.sin(pointAngle + angleDelta) * length + origin.y;
		}

		for (a in _axes)
		{
			var axisAngle:Float = Math.atan2(a.y, a.x);

			a.x = Math.cos(axisAngle + angleDelta);
			a.y = Math.sin(axisAngle + angleDelta);
		}
	}

	private function generateAxes():Void
	{
		_axes = new Array<Vector>();
		_indicesToRemove = new Array<Int>();

		var temp:Float;
		var nPoints:Int = _points.length;
		var edge:Vector;
		var i:Int, j:Int;

		i = 0;
		j = nPoints - 1;
		while (i < nPoints)
		{
			edge = new Vector();
			edge.x = _points[i].x - _points[j].x;
			edge.y = _points[i].y - _points[j].y;

			// get the axis which is perpendicular to the edge
			temp = edge.y;
			edge.y = -edge.x;
			edge.x = temp;
			edge.normalize(1);

			_axes.push(edge);

			j = i;
			i++;
		}
	}

	private function removeDuplicateAxes():Void
	{
		var nAxes:Int = _axes.length;
		HXP.clear(_indicesToRemove);

		for (i in 0...nAxes)
		{
			for (j in 0...nAxes)
			{
				if (i == j || Math.max(i, j) >= nAxes) continue;

				// if the first vector is equal or similar to the second vector,
				// add it to the remove list. (for example, [1, 1] and [-1, -1]
				// represent the same axis)
				if ((_axes[i].x == _axes[j].x && _axes[i].y == _axes[j].y)
					|| ( -_axes[i].x == _axes[j].x && -_axes[i].y == _axes[j].y))	// first axis inverted
				{
					_indicesToRemove.push(j);
				}
			}
		}

		// remove duplicate axes
		var indexToRemove:Null<Int>;
		while ((indexToRemove = _indicesToRemove.pop()) != null) _axes.splice(indexToRemove, 1);
	}

	private function updateAxes():Void
	{
		generateAxes();
		removeDuplicateAxes();
		update();
	}

	// Hitbox information.
	private var _angle:Float;
	private var _points:Array<Vector>;
	private var _axes:Array<Vector>;

	private var _fakeEntity:Entity;				// used for Grid and Pixelmask collision
	private var _fakeTileHitbox:Hitbox;			// used for Grid collision

	private var _indicesToRemove:Array<Int>;	// used in removeDuplicateAxes()

	private static var firstProj = new Projection();
	private static var secondProj = new Projection();

	public static var vertical = new Vector(0, 1);
	public static var horizontal = new Vector(1, 0);
}
