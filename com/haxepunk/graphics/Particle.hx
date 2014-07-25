package com.haxepunk.graphics;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * Used by the `Emitter` class to track an existing Particle.
 */
@:dox(hide)
@:allow(com.haxepunk.graphics.Emitter)
class Particle
{
	/**
	 * Constructor.
	 */
	private function new()
	{
		_time = 0;
		_duration = 0;
		_x = _y = 0;
		_moveX = _moveY = 0;
		_gravity = 0;
	}

	// Particle information.
	private var _type:ParticleType;
	private var _time:Float;
	private var _duration:Float;

	// Motion information.
	private var _x:Float;
	private var _y:Float;
	private var _moveX:Float;
	private var _moveY:Float;

	// Gravity information.
	private var _gravity:Float;

	// List information.
	private var _prev:Particle;
	private var _next:Particle;
}
