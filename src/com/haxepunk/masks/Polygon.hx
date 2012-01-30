package com.haxepunk.masks;
import com.haxepunk.Mask;
import flash.display.Graphics;
import flash.geom.Point;
import flash.Vector;
import flash.Vector;
/**
 * ...
 * @author 
 */


using Std;
 
class Polygon extends Mask
{
	/**
	 * Constructor.
	 * @param	radius		Radius of the circle.
	 * @param	x			X offset of the circle.
	 * @param	y			Y offset of the circle.
	 */
	public function new(points:Vector<Point>, x:Int = 0, y:Int = 0) 
	{
		super();
		_points = points;
		_x = x;
		_y = y;
		
		_check.set(Type.getClassName(Hitbox), collideHitbox);
		_check.set(Type.getClassName(Circle), collideCircle);
		_check.set(Type.getClassName(Polygon), collidePolygon);
		//_check.set(Type.getClassName(Grid), collideGrid);
		
		generateAxes();
		removeDuplicateAxes();
		
		projectOn(Hitbox.vertical, firstCollisionInfo);//height
		height = Std.int(firstCollisionInfo.max - firstCollisionInfo.min);
		projectOn(Hitbox.horizontal, secondCollisionInfo);//width
		width = Std.int(firstCollisionInfo.max - firstCollisionInfo.min);
	}
	
	private function generateAxes():Void 
	{
		_axes = new Vector<Point>();
		var store:Float;
		var numberOfPoints:Int = _points.length - 1;
		for (i in 0...numberOfPoints) 
		{
			var edge = new Point();
			edge.x = _points[i].x - _points[i + 1].x;
			edge.y = _points[i].y - _points[i + 1].y;
			
			//Get the axis which is perpendicular to the edge
			store = edge.y;
			edge.y = -edge.x;
			edge.x = store;
			edge.normalize(1);
			
			_axes.push(edge);
		}
		var edge = new Point();
		//Add the last edge
		edge.x = _points[numberOfPoints].x - _points[0].x;
		edge.y = _points[numberOfPoints].y - _points[0].y;
		store = edge.y;
		edge.y = -edge.x;
		edge.x = store;
		edge.normalize(1);
		
		_axes.push(edge);
	}
	
	private function removeDuplicateAxes():Void
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
	
	/*public function collideGrid(grid:Grid):Bool 
	{
		function collideSquare(x:Int, y:Int):Bool 
		{
			projectOn(Hitbox.vertical, firstCollisionInfo);
			grid.projectOn(Hitbox.vertical, secondCollisionInfo);
			
			if (firstCollisionInfo.min > secondCollisionInfo.max || firstCollisionInfo.max < secondCollisionInfo.min) 
			{
				return false;
			}
			
			projectOn(Hitbox.horizontal, firstCollisionInfo);
			grid.projectOn(Hitbox.horizontal, secondCollisionInfo);
			
			if (firstCollisionInfo.min > secondCollisionInfo.max || firstCollisionInfo.max < secondCollisionInfo.min) 
			{
				return false;
			}
			
			for (a in _axes) 
			{
				projectOn(a, firstCollisionInfo);
				grid.projectOn(a, secondCollisionInfo);
				
				if (firstCollisionInfo.min > secondCollisionInfo.max || firstCollisionInfo.max < secondCollisionInfo.min) 
				{
					return false;
				}
			}
			return true;
		}
		var startX = Std.int((x + parent.x) / grid.tileWidth);
		var startY = Std.int((y + parent.y) / grid.tileHeight );
		for (xx in startX...Std.int(startX + width / grid.tileWidth + 2))
		{
			for (yy in startY...Std.int(startY + height / grid.tileHeight + 2)) 
			{
				if (grid.getTile(xx, yy)) 
				{
					if (collideSquare(xx, yy)) return true;
				}
			}
		}
		return false;
	}*/
	
	public function collideCircle(circle:Circle):Bool
	{
		
		//First find the point closest to the circle
		var distanceSquared = 9999999999999;
		var closestPoint = null;
		for (p in _points) 
		{
			var dx = parent.x + p.x - circle.parent.x;
			var dy = parent.y + p.y - circle.parent.y;
			var tempDistance = dx * dx + dy * dy;
			
			if (tempDistance < distanceSquared) 
			{
				distanceSquared = tempDistance;
				closestPoint = p;
			}
		}
		
		var offsetX = parent.x - circle.parent.x;
		var offsetY = parent.y - circle.parent.y;
		
		//Get the vector between the closest point and the circle
		//and get the normal of it
		_axis.x = circle.parent.y - parent.y + closestPoint.y;
		_axis.y = parent.x + closestPoint.x - circle.parent.x;
		_axis.normalize(1);
		
		projectOn(_axis, firstCollisionInfo);
		circle.projectOn(_axis, secondCollisionInfo);
		
		var offset = offsetX * _axis.x + offsetY * _axis.y;
		firstCollisionInfo.min += offset;
		firstCollisionInfo.max += offset;
		
		if (firstCollisionInfo.min > secondCollisionInfo.max || firstCollisionInfo.max < secondCollisionInfo.min) 
		{
			return false;
		}
		
		for (a in _axes) 
		{
			projectOn(a, firstCollisionInfo);
			circle.projectOn(a, secondCollisionInfo);
			
			var offset = offsetX * a.x + offsetY * a.y;
			firstCollisionInfo.min += offset;
			firstCollisionInfo.max += offset;
			
			if (firstCollisionInfo.min > secondCollisionInfo.max || firstCollisionInfo.max < secondCollisionInfo.min) 
			{
				return false;
			}
		}
		
		return true;
	}
	
	public function collideHitbox(hitbox:Hitbox):Bool 
	{
		var offsetX = parent.x - hitbox.parent.x;
		var offsetY = parent.y - hitbox.parent.y;
		
		projectOn(Hitbox.vertical, firstCollisionInfo);//Project on the horizontal axis of the hitbox
		hitbox.projectOn(Hitbox.vertical, secondCollisionInfo);
		
		var offset = offsetX * Hitbox.vertical.x + offsetY * Hitbox.vertical.y;
		firstCollisionInfo.min += offset;
		firstCollisionInfo.max += offset;
		
		if (firstCollisionInfo.min > secondCollisionInfo.max || firstCollisionInfo.max < secondCollisionInfo.min) 
		{
			return false;
		}
		
		projectOn(Hitbox.horizontal, firstCollisionInfo);//Project on the vertical axis of the hitbox
		hitbox.projectOn(Hitbox.horizontal, secondCollisionInfo);
		
		var offset = offsetX * Hitbox.horizontal.x + offsetY * Hitbox.horizontal.y;
		firstCollisionInfo.min += offset;
		firstCollisionInfo.max += offset;
		
		if (firstCollisionInfo.min > secondCollisionInfo.max || firstCollisionInfo.max < secondCollisionInfo.min) 
		{
			return false;
		}
		
		for (a in _axes) 
		{
			projectOn(a, firstCollisionInfo);
			hitbox.projectOn(a, secondCollisionInfo);
			
			var offset = offsetX * a.x + offsetY * a.y;
			firstCollisionInfo.min += offset;
			firstCollisionInfo.max += offset;
			
			if (firstCollisionInfo.min > secondCollisionInfo.max || firstCollisionInfo.max < secondCollisionInfo.min) 
			{
				return false;
			}
		}
		return true;
	}
	

	
	public function collidePolygon(other:Polygon):Bool 
	{
		var offsetX = parent.x - other.parent.x;
		var offsetY = parent.y - other.parent.y;
		
		for (a in _axes) 
		{
			projectOn(a, firstCollisionInfo);
			other.projectOn(a, secondCollisionInfo);
			
			//Shift the first info with the offset
			var offset = offsetX * a.x + offsetY * a.y;
			firstCollisionInfo.min += offset;
			firstCollisionInfo.max += offset;
			
			if (firstCollisionInfo.min > secondCollisionInfo.max || firstCollisionInfo.max < secondCollisionInfo.min) 
			{
				trace("first false");
				return false;
			}
		}
		
		for (a in other._axes) 
		{
			projectOn(a, firstCollisionInfo);
			other.projectOn(a, secondCollisionInfo);
			
			//Shift the first info with the offset
			var offset = offsetX * a.x + offsetY * a.y;
			firstCollisionInfo.min += offset;
			firstCollisionInfo.max += offset;
			
			if (firstCollisionInfo.min > secondCollisionInfo.max || firstCollisionInfo.max < secondCollisionInfo.min) 
			{
				trace("2nd false");
				return false;
			}
		}
		trace(true);
		return true;
	}
	
	/**
	 * Project p1 on p2 returns the projected point (using _point)
	 * @param	p1
	 * @param	p2
	 */
	inline function dot(p1:Point, p2:Point):Float 
	{
		return p1.x * p2.x + p1.y * p2.y;
	}
	
	public inline function projectOn(axis:Point, collisionInfo:CollisionInfo):Void 
	{
		var max:Float = -111111111111;
		var min:Float = 11111111111111;
		
		for (vertex in _points) 
		{
			var cur = dot(vertex, axis);
			
			if (cur < min) 
			{
				min = cur;
			}
			if (cur > max) 
			{
				max = cur;
			}
		}
		collisionInfo.min = min;
		collisionInfo.max = max;
	}
	
	public function rotate(angle:Float = 0, relative:Bool = true):Void 
	{
		//if (relative) angle += Math.atan2(dy, dx) * -180 / Math.PI;
		
		angle *= Math.PI / -180;
		
		for (p in _points) 
		{
			var dx = p.x;
			var dy = p.y;
			
			var currentAngle = Math.atan2(dy, dx);
			var length = Math.sqrt(dx * dx + dy * dy);
			
			p.x = Math.cos(currentAngle + angle) * length;
			p.y = Math.sin(currentAngle + angle) * length;
		}
		_angle += angle;
	}
	
	#if debug
	override public function debugDraw(graphics:Graphics):Void 
	{
		com.haxepunk.utils.Draw.setTarget(com.haxepunk.HXP.buffer, com.haxepunk.HXP.camera);
		
		var len = _points.length - 1;
		if (parent != null) 
		{
			
			for (ii in 0...len) 
			{
				com.haxepunk.utils.Draw.line((_points[ii].x + parent.x).int(), _points[ii].y.int()+ parent.y.int(), _points[ii+1].x.int() + parent.x.int(), _points[ii+1].y.int()+ parent.y.int(), 0xFF0000);
			}
			com.haxepunk.utils.Draw.line((_points[len].x + parent.x).int(), _points[len].y.int()+ parent.y.int(), _points[0].x.int() + parent.x.int(), _points[0].y.int()+ parent.y.int(), 0xFF0000);
		}
		else 
		{
			for (ii in 0..._points.length - 1) 
			{
				com.haxepunk.utils.Draw.line((_points[ii].x + x).int(), _points[ii].y.int()+ y.int(), _points[ii+1].x.int() + x.int(), _points[ii+1].y.int()+ y.int(), 0xFF0000);
			}
			com.haxepunk.utils.Draw.line((_points[len].x + x).int(), _points[len].y.int()+ y.int(), _points[0].x.int() + x.int(), _points[0].y.int()+ y.int(), 0xFF0000);
		}
	}
	#end
	
	/**
	 * X offset.
	 */
	public var x(getX, setX):Int;
	private inline function getX():Int { return _x; }
	private inline function setX(value:Int):Int
	{
		if (_x == value) return value;
		_x = value;
		if (parent != null) update();
		return _x;
	}
	
	/**
	 * Y offset.
	 */
	public var y(getY, setY):Int;
	private inline function getY():Int { return _y; }
	private inline function setY(value:Int):Int
	{
		if (_y == value) return value;
		_y = value;
		if (parent != null) update();
		return _y;
	}
	
	/**
	 * Width.
	 */
	public var width(getWidth, setWidth):Int;
	inline private function getWidth():Int { return _width; }
	inline private function setWidth(value:Int):Int
	{
		if (_width == value) return value;
		_width = value;
		if (parent != null) update();
		return _width;
	}
	
	/**
	 * Height.
	 */
	public var height(getHeight, setHeight):Int;
	
	inline private function getHeight():Int { return _height; }
	inline private function setHeight(value:Int):Int
	{
		if (_height == value) return value;
		_height = value;
		if (parent != null) update();
		return _height;
	}
	
	
	public var angle(get_angle, set_angle):Float;
	inline private function get_angle():Float { return _angle; }
	
	inline private function set_angle(value:Float):Float 
	{
		if (value == _angle) return value;
		var diff = _angle - value;
		rotate(diff);
		
		return _angle = value;
	}
	
	
	/** Updates the parent's bounds for this mask. */
	override public function update() 
	{
		// update entity bounds
		//parent.originX = -_x;
		//parent.originY = -_y;
		//parent.width = _width;
		//parent.height = _height;
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
		if (sides < 3) throw "The polygon needs at least 3 sides";
		// create a return polygon 
		// figure out the angles required
		var rotationAngle:Float = (Math.PI * 2) / sides;
		
		// loop through and generate each point
		var points = new Vector<Point>();
		
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
		poly.rotate(angle);
		return poly;
	}
	
	/**
	 * Creates a polygon from an array were even numbers are x and odd are y
	 * @param	points
	 */
	public static function createFromArray(points:Array<Float>):Polygon 
	{
		var p = new Vector<Point>();
		
		var ii = 0;
		while (ii < points.length) 
		{
			p.push(new Point(points[ii++], points[ii++]));
		}
		return new Polygon(p);
	}
	
	
	// Hitbox information.
	private var _width:Int;
	private var _height:Int;
	private var _x:Int;
	private var _y:Int;
	private var _angle:Float;
	private var _points:Vector<Point>;
	private var _axes:Vector<Point>;
	
	private static var _axis = new Point();
	private static var firstCollisionInfo = new CollisionInfo();
	private static var secondCollisionInfo = new CollisionInfo();
}