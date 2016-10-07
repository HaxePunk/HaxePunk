package com.haxepunk.graphics;

/**
 * Used by the Emitter class to track an existing Particle.
 */
@:allow(com.haxepunk.graphics.Emitter)
@:access(com.haxepunk.graphics.ParticleType)
class Particle
{
	public inline function x(td:Float):Float
	{
		return _x + _ox + _moveX * (_type._backwards ? 1 - td : td);
	}
	public inline function y(td:Float):Float
	{
		return _y + _oy + _moveY * (_type._backwards ? 1 - td : td) + Math.pow(td * _gravity, 2);
	}

	public function new() {}

	// Particle information.
	private var _type:ParticleType;
	private var _time:Float = 0;
	private var _stopTime:Float = 0;
	private var _duration:Float = 0;

	// Motion information.
	private var _x:Float = 0;
	private var _y:Float = 0;
	private var _moveX:Float = 0;
	private var _moveY:Float = 0;
	private var _angle:Float = 0;
	private var _firstDraw:Bool = false;
	private var _ox:Float = 0;
	private var _oy:Float = 0;
	private var _startAngle:Float = 0;
	private var _spanAngle:Float = 0;

	// Gravity information.
	private var _gravity:Float = 0;

	// List information.
	private var _prev:Particle;
	private var _next:Particle;
}
