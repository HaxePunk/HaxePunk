package haxepunk.math;

abstract Degrees(Float) from Float
{
	public static var CIRCLE:Degrees = 360;

	@:from public static function fromFloat(v:Float):Degrees
	{
		return v;
	}

	@:from public static function fromRadians(v:Radians):Degrees
	{
		return (v:Float) * -180 / Math.PI;
	}

	public static inline function sin(v:Degrees):Float
	{
		return Math.sin(Radians.fromDegrees(v));
	}

	public static inline function cos(v:Degrees):Float
	{
		return Math.cos(Radians.fromDegrees(v));
	}

	public static inline function tan(v:Degrees):Float
	{
		return Math.tan(Radians.fromDegrees(v));
	}

	@:to public function toString():String return '$this deg';
	@:to public function toRadians():Radians return Radians.fromDegrees(cast this);
	@:allow(haxepunk.math.Radians) @:to function toFloat():Float return this;

	public inline function abs():Degrees return Math.abs(this);

	@:op(-A) static function neg(a:Degrees):Degrees;
	@:op(A * B) static function mul(a:Degrees, b:Degrees):Degrees;
	@:op(A / B) static function div(a:Degrees, b:Degrees):Degrees;
	@:op(A + B) static function add(a:Degrees, b:Degrees):Degrees;
	@:op(A - B) static function sub(a:Degrees, b:Degrees):Degrees;
	@:op(A == B) static function eq(a:Degrees, b:Degrees):Bool;
	@:op(A < B) static function lt(a:Degrees, b:Degrees):Bool;
	@:op(A > B) static function gt(a:Degrees, b:Degrees):Bool;
	@:op(A <= B) static function lte(a:Degrees, b:Degrees):Bool;
	@:op(A >= B) static function gte(a:Degrees, b:Degrees):Bool;
	@:op(A % B) static function mod(a:Degrees, b:Degrees):Degrees;

	@:commutative @:op(A * B) static function mul(a:Degrees, b:Float):Degrees;
	@:op(A / B) static function div(a:Degrees, b:Float):Degrees;
	@:op(A / B) static function div2(a:Float, b:Degrees):Degrees;
	@:commutative @:op(A + B) static function add(a:Degrees, b:Float):Degrees;
	@:op(A - B) static function sub(a:Degrees, b:Float):Degrees;
	@:op(A - B) static function sub2(a:Float, b:Degrees):Degrees;
	@:commutative @:op(A == B) static function eq(a:Degrees, b:Float):Bool;
	@:op(A < B) static function lt(a:Degrees, b:Float):Bool;
	@:op(A < B) static function lt2(a:Float, b:Degrees):Bool;
	@:op(A > B) static function gt(a:Degrees, b:Float):Bool;
	@:op(A > B) static function gt2(a:Float, b:Degrees):Bool;
	@:op(A <= B) static function lte(a:Degrees, b:Float):Bool;
	@:op(A <= B) static function lte2(a:Float, b:Degrees):Bool;
	@:op(A >= B) static function gte(a:Degrees, b:Float):Bool;
	@:op(A >= B) static function gte2(a:Float, b:Degrees):Bool;
}
