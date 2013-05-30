package com.haxepunk.math;

import flash.geom.Point;

class Vector extends Point
{

	public function new(x:Float=0, y:Float=0)
	{
		super(x, y);
	}

	/**
	 * Calculates the dotProduct between two points
	 */
	public inline function dot(p:Point):Float
	{
		return x * p.x + y * p.y;
	}

	public inline function cross():Vector
	{
		return new Vector(y, -x);
	}
}