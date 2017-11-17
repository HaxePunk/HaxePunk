package haxepunk.math;

class Rectangle
{
	public var left:Float;
	public var right:Float;
	public var top:Float;
	public var bottom:Float;

	public var x(get, set):Float;
	inline function get_x():Float return left;
	inline function set_x(value:Float):Float return left = value;

	public var y(get, set):Float;
	inline function get_y():Float return top;
	inline function set_y(value:Float):Float return top = value;

	public var width(get, set):Float;
	inline function get_width():Float return right - left;
	inline function set_width(value:Float):Float
	{
		right = left + value;
		return value;
	}

	public var height(get, set):Float;
	inline function get_height():Float return bottom - top;
	inline function set_height(value:Float):Float
	{
		bottom = top + value;
		return value;
	}

	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0)
	{
		setTo(x, y, width, height);
	}

	public function setTo(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0)
	{
		left = x;
		top = y;
		this.width = width;
		this.height = height;
	}

	public function clone():Rectangle
	{
		return new Rectangle(x, y, width, height);
	}

	public function isEmpty():Bool
	{
		return width == 0 && height == 0;
	}

	public function intersects(other:Rectangle):Bool
	{
		return left <= other.right &&
			other.left <= right &&
			top <= other.bottom &&
			other.top <= bottom;
	}

	public function intersection(other:Rectangle):Rectangle
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
			return new Rectangle();
		}
	}
}
