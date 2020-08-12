package haxepunk.math;

abstract Radians(Float) from Float to Float
{
	public static var CIRCLE:Radians = Math.PI * 2;

	@:from public static function fromDegrees(v:Degrees):Radians
	{
		return v.toFloat() * Math.PI / -180;
	}

	@:commutative @:op(A * B) static function multiply(a:Radians, b:Float):Float
	{
		return (a:Float) * b;
	}

	@:op(-A) static function neg(a:Radians):Radians;
	@:op(A * B) static function mul(a:Radians, b:Radians):Radians;
	@:op(A / B) static function div(a:Radians, b:Radians):Radians;
	@:op(A + B) static function add(a:Radians, b:Radians):Radians;
	@:op(A - B) static function sub(a:Radians, b:Radians):Radians;
	@:op(A == B) static function eq(a:Radians, b:Radians):Bool;
	@:op(A < B) static function lt(a:Radians, b:Radians):Bool;
	@:op(A > B) static function gt(a:Radians, b:Radians):Bool;
	@:op(A <= B) static function lte(a:Radians, b:Radians):Bool;
	@:op(A >= B) static function gte(a:Radians, b:Radians):Bool;
	@:op(A % B) static function mod(a:Radians, b:Radians):Degrees;

	@:op(-A) static function neg(a:Radians):Radians;
	@:commutative @:op(A * B) static function mul(a:Radians, b:Float):Radians;
	@:commutative @:op(A / B) static function div(a:Radians, b:Float):Radians;
	@:commutative @:op(A + B) static function add(a:Radians, b:Float):Radians;
	@:commutative @:op(A - B) static function sub(a:Radians, b:Float):Radians;
	@:commutative @:op(A == B) static function eq(a:Radians, b:Float):Bool;
	@:commutative @:op(A < B) static function eq(a:Radians, b:Float):Bool;
	@:commutative @:op(A > B) static function eq(a:Radians, b:Float):Bool;
	@:commutative @:op(A <= B) static function eq(a:Radians, b:Float):Bool;
	@:commutative @:op(A >= B) static function eq(a:Radians, b:Float):Bool;

	@:commutative @:op(A * B) static function mul(a:Radians, b:Degrees):Radians return a + fromDegrees(b);
	@:op(A / B) static function div(a:Radians, b:Degrees):Radians return a / fromDegrees(b);
	@:op(A / B) static function div2(a:Degrees, b:Radians):Radians return fromDegrees(a) / b;
	@:commutative @:op(A + B) static function add(a:Radians, b:Degrees):Radians;
	@:op(A - B) static function sub(a:Radians, b:Degrees):Radians return a - fromDegrees(b);
	@:op(A - B) static function sub2(a:Degrees, b:Radians):Radians return fromDegrees(a) - b;

	@:to public function toString():String return '${this / Math.PI}*PI';
	@:to public function toDegrees():Degrees return Degrees.fromRadians(this);
}
