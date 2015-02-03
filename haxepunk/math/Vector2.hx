package haxepunk.math;

abstract Vector2 (Point3D)
{

	public static var ZERO:Vector2 = new Vector2(0, 0);

	public function new(x:Float=0, y:Float=0)
	{
		this = new Point3D(x, y, 0);
	}

	public var x(get, set):Float;
	private inline function get_x():Float return this.x;
	private inline function set_x(value:Float):Float return this.x = value;

	public var y(get, set):Float;
	private inline function get_y():Float return this.y;
	private inline function set_y(value:Float):Float return this.y = value;

	@:to
	public inline function toVector3():Vector3
	{
		return new Vector3(this.x, this.y, 0);
	}

	/**
	 * Length of the vector
	 */
	public var length(get, never):Float;
	private function get_length():Float
	{
		return Math.sqrt(x * x + y * y);
	}

	public function clone():Vector2
	{
		return new Vector2(x, y);
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
		}
	}

	public function negate():Void
	{
		x = -x;
		y = -y;
	}

	/**
	 * Distance between two vectors
	 * @param v Another vector to check distance
	 */
	public function distance(v:Vector2):Float
	{
		var dx = v.x - x;
		var dy = v.y - y;
		return Math.sqrt(dx * dx + dy * dy);
	}

	@:op(A += B) public static inline function add(a:Vector2, b:Vector2):Vector2
	{
		a.x += b.x;
		a.y += b.y;
		return a;
	}

	@:op(A + B) private static inline function _add(a:Vector2, b:Vector2):Vector2
	{
		return new Vector2(a.x + b.x, a.y + b.y);
	}

	@:op(A -= B) private static inline function subtract(a:Vector2, b:Vector2):Vector2
	{
		a.x -= b.x;
		a.y -= b.y;
		return a;
	}

	@:op(A - B) private static inline function _subtract(a:Vector2, b:Vector2):Vector2
	{
		return new Vector2(a.x - b.x, a.y - b.y);
	}

	@:commutative @:op(A * B) private static inline function _multiplyByScalar(a:Vector2, b:Float):Vector2
	{
		return new Vector2(a.x * b, a.y * b);
	}

	@:op(A *= B) private static inline function _multiplyEquals(a:Vector2, b:Float):Vector2
	{
		a.x *= b;
		a.y *= b;
		return a;
	}

	@:op(A *= B) private static inline function multiply(a:Vector2, b:Vector2):Vector2
	{
		a.x *= b.x;
		a.y *= b.y;
		return a;
	}

	@:op(A / B) private static inline function _divideByScalar(a:Vector2, b:Float):Vector2
	{
		b = 1 / b;
		return new Vector2(a.x * b, a.y * b);
	}

	@:op(A /= B) private static inline function _divideEquals(a:Vector2, b:Float):Vector2
	{
		b = 1 / b;
		a.x *= b;
		a.y *= b;
		return a;
	}

	@:op(A /= B) public static inline function divide(a:Vector2, b:Vector2):Vector2
	{
		a.x /= b.x;
		a.y /= b.y;
		return a;
	}

	@:op(A *= B) private static inline function _multiplyEqualsMatrix(v:Vector2, m:Matrix4):Vector2
	{
		v.x = m._11 * v.x + m._12 * v.y + m._13;
		v.y = m._21 * v.x + m._22 * v.y + m._23;
		return v;
	}

	@:op(A * B) private static inline function _multiplyMatrix(v:Vector2, m:Matrix4):Vector2
	{
		return new Vector2(
			m._11 * v.x + m._12 * v.y + m._13,
			m._21 * v.x + m._22 * v.y + m._23
		);
	}

	@:op(A * B) private static inline function _multiplyInverseMatrix(m:Matrix4, v:Vector2):Vector2
	{
		return new Vector2(
			m._11 * v.x + m._21 * v.y + m._31,
			m._12 * v.x + m._22 * v.y + m._32
		);
	}

	@:op(A * B) public static inline function dot(a:Vector2, b:Vector2):Float
	{
		return a.x * b.x + a.y * b.y;
	}

	@:op(A == B) private static inline function _equals(a:Vector2, b:Vector2):Bool
	{
		return (a == null ? b == null : (b != null && a.x == b.x && a.y == b.y));
	}

	@:op(A != B) private static inline function _notEquals(a:Vector2, b:Vector2):Bool
	{
		return !_equals(a, b);
	}

	@:op(-A) private static inline function _negativeVector(a:Vector2):Vector2
	{
		return new Vector2(-a.x, -a.y);
	}

}
