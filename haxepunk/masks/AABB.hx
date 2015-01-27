package haxepunk.masks;

import haxepunk.math.Vector3;

class AABB implements Mask
{

	/**
	 * Minimum point of the AABB
	 */
	public var min:Vector3;

	/**
	 * Maximum point of the AABB
	 */
	public var max:Vector3;

	/**
	 * X Offset.
	 */
	public var x(get, set):Float;
	private inline function get_x():Float { return min.x; }
	private inline function set_x(value:Float):Float {
		max.x = value + width;
		return min.x = value;
	}

	/**
	 * Y Offset.
	 */
	public var y(get, set):Float;
	private inline function get_y():Float { return min.y; }
	private inline function set_y(value:Float):Float {
		max.y = value + height;
		return min.y = value;
	}

	/**
	 * Z Offset.
	 */
	public var z(get, set):Float;
	private inline function get_z():Float { return min.z; }
	private inline function set_z(value:Float):Float {
		max.z = value + depth;
		return min.z = value;
	}

	/**
	 * Width of the AABB
	 */
	public var width(get, set):Float;
	private inline function get_width():Float { return Math.abs(max.x - min.x); }
	private inline function set_width(value:Float):Float { max.x = min.x + value; return width; }

	/**
	 * Height of the AABB
	 */
	public var height(get, set):Float;
	private inline function get_height():Float { return Math.abs(max.y - min.y); }
	private inline function set_height(value:Float):Float { max.y = min.y + value; return height; }

	/**
	 * Depth of the AABB
	 */
	public var depth(get, set):Float;
	private inline function get_depth():Float { return Math.abs(max.z - min.z); }
	private inline function set_depth(value:Float):Float { max.z = min.z + value; return depth; }

	/**
	 * The leftmost position of the AABB.
	 */
	public var left(get, never):Float;
	private inline function get_left():Float { return min.x; }

	/**
	 * The rightmost position of the AABB.
	 */
	public var right(get, never):Float;
	private inline function get_right():Float { return max.x; }

	/**
	 * The topmost position of the AABB.
	 */
	public var top(get, never):Float;
	private inline function get_top():Float { return min.y; }

	/**
	 * The bottommost position of the AABB.
	 */
	public var bottom(get, never):Float;
	private inline function get_bottom():Float { return max.y; }

	/**
	 * The frontmost position of the AABB.
	 */
	public var front(get, never):Float;
	private inline function get_front():Float { return min.z; }

	/**
	 * The backmost position of the AABB.
	 */
	public var back(get, never):Float;
	private inline function get_back():Float { return max.z; }

	/**
	 * The center position of the AABB. (WARNING: recalculates value every time this is used)
	 */
	public var center(get, never):Vector3;
	private function get_center():Vector3
	{
		_center.x = width * 0.5 + min.x;
		_center.y = height * 0.5 + min.y;
		_center.z = depth * 0.5 + min.z;
		return _center;
	}

	public function new(?min:Vector3, ?max:Vector3)
	{
		this.min = (min == null ? new Vector3() : min);
		this.max = (max == null ? new Vector3() : max);
		_center = new Vector3();
	}

	public function intersects(other:Mask):Bool
	{
		if (Std.is(other, AABB)) return intersectsAABB(cast other);
		return false;
	}

	public function collide(other:Mask):Vector3
	{
		if (Std.is(other, AABB)) return collideAABB(cast other);
		return Vector3.ZERO;
	}

	public function intersectsPoint(vec:Vector3):Bool
	{
		return vec.x >= min.x && vec.x <= max.x &&
			vec.y >= min.y && vec.y <= max.y &&
			vec.z >= min.z && vec.z <= max.z;
	}

	public function intersectsAABB(other:AABB):Bool
	{
		return max.x >= other.min.x && min.x <= other.max.x &&
			max.y >= other.min.y && min.y <= other.max.y &&
			max.z >= other.min.z && min.z <= other.max.z;
	}

	public function collideAABB(other:AABB):Vector3
	{
		var result = new Vector3();

		var left = other.min.x - max.x;
		var right = other.max.x - min.x;
		var top = other.min.y - max.y;
		var bottom = other.max.y - min.y;
		var front = other.min.z - max.z;
		var back = other.max.z - min.z;

		if (left >= 0 || right <= 0 || top >= 0 || bottom <= 0 || front >= 0 || back <= 0)
		{
			return null;
		}

		result.x = (Math.abs(left) < right) ? left : right;
		result.y = (Math.abs(top) < bottom) ? top : bottom;
		result.z = (Math.abs(front) < back) ? front : back;

		return result;
	}

	private var _center:Vector3;

}
