package haxepunk.math;

class Vector2
{
	public var x:Float;
	public var y:Float;

	public function new(x:Float = 0, y:Float = 0)
	{
		set(x, y);
	}

	public var length(get, never):Float;
	function get_length():Float
	{
		return Math.sqrt(x * x + y * y);
	}

	public inline function set(x:Float, y:Float)
	{
		this.x = x;
		this.y = y;
	}

	public function perpendicular()
	{
		var xx = x;
		x = -y;
		y = xx;
	}

	public inline function inverse():Void
	{
		x = -x;
		y = -y;
	}

	public inline function copyFrom(other:Vector2):Void
	{
		x = other.x;
		y = other.y;
	}

	public inline function add(other:Vector2):Void
	{
		x += other.x;
		y += other.y;
	}

	public inline function subtract(other:Vector2):Void
	{
		x -= other.x;
		y -= other.y;
	}

	public function distance(other:Vector2):Float
	{
		var dx = this.x - other.x;
		var dy = this.y - other.y;
		return Math.sqrt(dx * dx + dy * dy);
	}

	public function normalize(size:Float):Void
	{
		if (x == 0 && y == 0) return;

		var normal = size / this.length;
		x *= normal;
		y *= normal;
	}

	/**
	 * Can be used to determine if an angle between two vectors is acute or obtuse.
	 */
	public inline function dot(other:Vector2):Float
	{
		return (x * other.x) + (y * other.y);
	}

	/**
	 * This is the same as a 3D cross product but only returns the z value because x and y are 0.
	 * Can be used to determine if and angle between two vectors is greater than 180 degrees.
	 */
	public inline function zcross(other:Vector2):Float
	{
		return (x * other.y) - (y * other.x);
	}
}
