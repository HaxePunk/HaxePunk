package com.haxepunk.math;

class Projection
{

	public var max:Float;
	public var min:Float;

	public function new():Void
	{
		max = min = 0;
	}

	public inline function overlaps(other:Projection):Bool
	{
		return min > other.max || max < other.min;
	}

	public inline function getOverlap(other:Projection):Float
	{
		return (max > other.max) ? max - other.min : other.max - min;
	}

}