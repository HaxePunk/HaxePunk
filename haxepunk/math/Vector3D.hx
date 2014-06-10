package haxepunk.math;

abstract Vector3D (lime.utils.Vector3D)
{

	public function new(x:Float=0, y:Float=0, z:Float=0, w:Float=0)
	{
		this = new lime.utils.Vector3D(x, y, z, w);
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

	public var w(get, set):Float;
	private inline function get_w():Float return this.w;
	private inline function set_w(value:Float):Float return this.w = value;

	@:op(A + B) public static inline function add(a:Vector3D, b:Vector3D):Vector3D
	{
		return new Vector3D(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w);
	}

	@:op(A - B) public static inline function subtract(a:Vector3D, b:Vector3D):Vector3D
	{
		return new Vector3D(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w);
	}

	@:commutative @:op(A * B) public static inline function multiplyByScalar(a:Vector3D, b:Float):Vector3D
	{
		return new Vector3D(a.x * b, a.y * b, a.z * b, a.w * b);
	}

	@:op(A / B) public static inline function divideByScalar(a:Vector3D, b:Float):Vector3D
	{
		return new Vector3D(a.x / b, a.y / b, a.z / b, a.w / b);
	}

	@:op(A % B) public static inline function cross(a:Vector3D, b:Vector3D):Vector3D
	{
		return new Vector3D(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x, 1);
	}

	@:op(A * B) public static inline function dot(a:Vector3D, b:Vector3D):Float
	{
		return a.x * b.x + a.y * b.y + a.z * b.z;
	}

	@:op(A == B) public static inline function equals(a:Vector3D, b:Vector3D):Bool
	{
		return a.x == b.x && a.y == b.y && a.z == b.z && a.w == b.w;
	}

	@:op(A != B) public static inline function notEquals(a:Vector3D, b:Vector3D):Bool
	{
		return !equals(a, b);
	}

	@:op(-A) public static inline function negate(a:Vector3D):Vector3D
	{
		return new Vector3D(-a.x, -a.y, -a.z, -a.w);
	}

}
