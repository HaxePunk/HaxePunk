package com.haxepunk.math;

import flash.geom.Point;

class Vector extends Point
{
	/**
	 * Constructor.
	 * 
	 * @param	x	The x value of the vector.
	 * @param	y	The y value of the vector.
	 */
	public function new(x:Float=0, y:Float=0)
	{
		super(x, y);
	}

	/**
	 * Calculates the dotProduct between two points
	 * 
	 * @param	p	The other point
	 * 
	 * @return The dot product.
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
