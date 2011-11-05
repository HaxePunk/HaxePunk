package com.haxepunk.graphics;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * Used by the Emitter class to track an existing Particle.
 */
class Particle 
{
	/**
	 * Constructor.
	 */
	public function new() 
	{
	}
	
	// Particle information.
	public var _type:ParticleType;
	public var _time:Float;
	public var _duration:Float;
	
	// Motion information.
	public var _x:Float;
	public var _y:Float;
	public var _moveX:Float;
	public var _moveY:Float;
	
	// Gravity information.
	public var _gravity:Float;
	
	// List information.
	public var _prev:Particle;
	public var _next:Particle;
}