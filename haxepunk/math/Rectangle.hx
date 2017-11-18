package haxepunk.math;

@:structInit
class Rectangle
{
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;

	/**
	 * The left-most x-axis value. Identical to x.
	 */
	public var left(get, set):Float;
	inline function get_left():Float return x;
	inline function set_left(value:Float):Float return x = value;

	/**
	 * The right-most x-axis value. When set it will push the x value, keeping the same width.
	 */
	public var right(get, set):Float;
	inline function get_right():Float return x + width;
	inline function set_right(value:Float):Float
	{
		x = value - width;
		return value;
	}

	/**
	 * The top-most y-axis value. Identical to y.
	 */
	public var top(get, set):Float;
	inline function get_top():Float return y;
	inline function set_top(value:Float):Float return y = value;

	/**
	 * The bottom-most y-axis value. When set it will push the y value, keeping the same height.
	 */
	public var bottom(get, set):Float;
	inline function get_bottom():Float return y + height;
	inline function set_bottom(value:Float):Float
	{
		y = value - height;
		return value;
	}

	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0)
	{
		setTo(x, y, width, height);
	}

	public function setTo(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0)
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	public function clone():Rectangle
	{
		return new Rectangle(x, y, width, height);
	}

	/**
	 * Checks if the rectangle width and height values are at or less than zero.
	 */
	public function isEmpty():Bool
	{
		return width <= 0 && height <= 0;
	}

	/**
	 * Checks if the rectangle intersects another rectangle.
	 */
	public function intersects(other:Rectangle):Bool
	{
		return left <= other.right &&
			other.left <= right &&
			top <= other.bottom &&
			other.top <= bottom;
	}

	/**
	 * If the rectangle intersects another rectangle, it returns an overlapping rectangle. Otherwise, it returns null.
	 */
	public function intersection(other:Rectangle):Null<Rectangle>
	{
		var left = Math.max(left, other.left);
		var right = Math.min(right, other.right);
		var top = Math.max(top, other.top);
		var bottom = Math.min(bottom, other.bottom);

		if (right >= left && bottom >= top)
		{
			return new Rectangle(left, top, right - left, bottom - y);
		}
		else
		{
			return null;
		}
	}
}
