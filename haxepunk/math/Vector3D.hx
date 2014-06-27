package haxepunk.math;

class Point3D
{
	public var x:Float;
	public var y:Float;
	public var z:Float;

	public function new(x:Float=0, y:Float=0, z:Float=0)
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
}

abstract Vector3D (Point3D)
{

	public static var ZERO:Vector3D = new Vector3D(0, 0, 0);

	public function new(x:Float=0, y:Float=0, z:Float=0)
	{
		this = new Point3D(x, y, z);
	}

	public var x(get, set):Float;
	private inline function get_x():Float return this.x;
	private inline function set_x(value:Float):Float return this.x = value;

	public var y(get, set):Float;
	private inline function get_y():Float return this.y;
	private inline function set_y(value:Float):Float return this.y = value;

	public var z(get, set):Float;
	private inline function get_z():Float return this.z;
	private inline function set_z(value:Float):Float return this.z = value;

	/**
	 * Length of the vector
	 */
	public var length(get, never):Float;
	private function get_length():Float
	{
		return Math.sqrt(x * x + y * y + z * z);
	}

	/**
	 * Normalizes the vector
	 */
	public function normalize():Void
	{
		var len = length;
		if (len > 0)
		{
			len = 1 / len;
			x *= len;
			y *= len;
			z *= len;
		}
	}

	/**
	 * Distance between two vectors
	 * @param v Another vector to check distance
	 */
	public function distance(v:Vector3D):Float
	{
		var dx = v.x - x;
		var dy = v.y - y;
		var dz = v.z - z;
		return Math.sqrt(dx * dx + dy * dy + dz * dz);
	}

	@:op(A + B) public static inline function add(a:Vector3D, b:Vector3D):Vector3D
	{
		return new Vector3D(a.x + b.x, a.y + b.y, a.z + b.z);
	}

	@:op(A += B) public static inline function addEquals(a:Vector3D, b:Vector3D):Vector3D
	{
		a.x += b.x;
		a.y += b.y;
		a.z += b.z;
		return a;
	}

	@:op(A - B) public static inline function subtract(a:Vector3D, b:Vector3D):Vector3D
	{
		return new Vector3D(a.x - b.x, a.y - b.y, a.z - b.z);
	}

	@:op(A -= B) public static inline function subtractEquals(a:Vector3D, b:Vector3D):Vector3D
	{
		a.x -= b.x;
		a.y -= b.y;
		a.z -= b.z;
		return a;
	}

	@:commutative @:op(A * B) public static inline function multiplyByScalar(a:Vector3D, b:Float):Vector3D
	{
		return new Vector3D(a.x * b, a.y * b, a.z * b);
	}

	@:op(A *= B) public static inline function multiplyEquals(a:Vector3D, b:Float):Vector3D
	{
		a.x *= b;
		a.y *= b;
		a.z *= b;
		return a;
	}

	@:op(A / B) public static inline function divideByScalar(a:Vector3D, b:Float):Vector3D
	{
		b = 1 / b;
		return new Vector3D(a.x * b, a.y * b, a.z * b);
	}

	@:op(A /= B) public static inline function divideEquals(a:Vector3D, b:Float):Vector3D
	{
		b = 1 / b;
		a.x *= b;
		a.y *= b;
		a.z *= b;
		return a;
	}

	@:op(A % B) public static inline function cross(a:Vector3D, b:Vector3D):Vector3D
	{
		return new Vector3D(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
	}

	@:op(A %= B) public static inline function crossEquals(a:Vector3D, b:Vector3D):Vector3D
	{
		var x = a.y * b.z - a.z * b.y;
		var y = a.z * b.x - a.x * b.z;
		var z = a.x * b.y - a.y * b.x;
		a.x = x;
		a.y = y;
		a.z = z;
		return a;
	}

	@:op(A * B) public static inline function dot(a:Vector3D, b:Vector3D):Float
	{
		return a.x * b.x + a.y * b.y + a.z * b.z;
	}

	@:op(A == B) public static inline function equals(a:Vector3D, b:Vector3D):Bool
	{
		return (a == null ? b == null : (b != null && a.x == b.x && a.y == b.y && a.z == b.z));
	}

	@:op(A != B) public static inline function notEquals(a:Vector3D, b:Vector3D):Bool
	{
		return !equals(a, b);
	}

	@:op(-A) public static inline function negate(a:Vector3D):Vector3D
	{
		return new Vector3D(-a.x, -a.y, -a.z);
	}

}
