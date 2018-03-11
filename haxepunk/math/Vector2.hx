package haxepunk.math;

@:structInit
class Vector2
{
	public var x:Float;
	public var y:Float;

	public inline function new(x:Float = 0, y:Float = 0)
	{
		this.x = x;
		this.y = y;
	}

	/**
	 * The length of this vector
	 **/
	public var length(get, set):Float;
	inline function get_length():Float return Math.sqrt(x * x + y * y);
	inline function set_length(value:Float)
	{
		normalize(value);
		return value;
	}

	/**
	 * Set the internal x, y values
	 **/
	public inline function setTo(x:Float, y:Float)
	{
		this.x = x;
		this.y = y;
	}

	/**
	 * Convert this vector to it's perpendicular counterpart
	 **/
	public inline function perpendicular()
	{
		setTo(-y, x);
	}

	/**
	 * Invert (negate) the vector contents
	 **/
	public inline function inverse():Void
	{
		x = -x;
		y = -y;
	}

	/**
	 * Copies the values from one vector into this one
	 * @param other  The vector to copy from
	 **/
	public inline function copyFrom(other:Vector2):Void
	{
		x = other.x;
		y = other.y;
	}

	/**
	 * Scale the vector by a single value
	 **/
	public inline function scale(scalar:Float):Void
	{
		x *= scalar;
		y *= scalar;
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

	/**
	 * Returns the distance between this and another point
	 * @param other  The other point to use for distance calculation
	 * @returns The distance between the two points
	 **/
	public inline function distance(other:Vector2):Float
	{
		var dx = this.x - other.x;
		var dy = this.y - other.y;
		return Math.sqrt(dx * dx + dy * dy);
	}

	/**
	 * Normalize the vector to a set length
	 * @param size  The length of the resulting vector. Default: unit length (1)
	 **/
	public inline function normalize(size:Float=1):Void
	{
		if (!(x == 0 && y == 0))
		{
			var normal = size / this.length;
			x *= normal;
			y *= normal;
		}
	}

	/**
	 * Rotate the vector around an angle
	 * @param angle  The angle, in radians to rotate around (clockwise)
	 **/
	public inline function rotate(angle:Float):Void
	{
		var sin = Math.sin(angle);
		var cos = Math.cos(angle);
		setTo(cos * x - sin * y, sin * x + cos * y);
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

	public inline function clone():Vector2
	{
		return new Vector2(x, y);
	}
}
