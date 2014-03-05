package com.haxepunk.math;

import flash.geom.Point;

abstract Vector(Point)
{
	public inline function new(x:Float=0, y:Float=0) { this = new Point(x, y); }

	@:to public function toPoint():Point { return this; }
	@:from static public function fromPoint(point:Point):Vector
	{
		return new Vector(point.x, point.y);
	}

	public var x(get,set):Float;
	private inline function get_x():Float { return this.x; }
	private inline function set_x(value:Float):Float { return this.x = value; }

	public var y(get,set):Float;
	private inline function get_y():Float { return this.y; }
	private inline function set_y(value:Float):Float { return this.y = value; }

	public inline function dot(b:Vector):Float
	{
		return x * b.x + y * b.y;
	}

	public inline function cross(b:Vector):Float
	{
		return x * b.x - y * b.y;
	}

	public inline function invert():Void
	{
		x = -x;
		y = -y;
	}

	public inline function rotate(angle:Float):Vector
	{
		var sin:Float = Math.sin(angle),
			cos:Float = Math.cos(angle);
		return new Vector(x * cos - y * sin, x * sin + y * cos);
	}

	public function normalize(size:Float=1):Void
	{
		var len = length;
		if (len == 0)
		{
			x = y = 0;
		}
		else
		{
			x = x / len * size;
			y = y / len * size;
		}
	}

	public var squareLength(get,never):Float;
	private inline function get_squareLength():Float
	{
		return x * x + y * y;
	}

	public var length(get,never):Float;
	private inline function get_length():Float
	{
		return Math.sqrt(squareLength);
	}

	public var angle(get,never):Float;
	private inline function get_angle():Float
	{
		return Math.atan2(y, x);
	}

	public var unit(get,never):Vector;
	public inline function get_unit():Vector
	{
		var len = length;
		return new Vector(x / len, y / len);
	}

	@:op(A + B) static public function add(a:Vector, b:Vector):Vector
	{
		return new Vector(a.x + b.x, a.y + b.y);
	}

	@:op(A - B) static public function sub(a:Vector, b:Vector):Vector
	{
		return new Vector(a.x - b.x, a.y - b.y);
	}

	@:commutative @:op(A * B) static public function scalar_mult(a:Vector, b:Float):Vector
	{
		return new Vector(a.x * b, a.y * b);
	}

	@:op(A / B) static public function scalar_divide(a:Vector, b:Float):Vector
	{
		return new Vector(a.x / b, a.y / b);
	}
}
