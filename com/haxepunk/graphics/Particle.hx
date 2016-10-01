package com.haxepunk.graphics;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.haxepunk.graphics.Emitter;
import com.haxepunk.graphics.ParticleType;


/**
 * Used by the Emitter class to track an existing Particle.
 */
@:allow(com.haxepunk.graphics.Emitter)
class Particle
{
	/**
	 * Constructor.
	 */
	public function new()
	{
		_time = _duration = _stopTime = 0;
		_x = _y = 0;
		_moveX = _moveY = 0;
		_gravity = 0;
		_angle = 0;
		_firstDraw = false;
		_ox = _oy = 0;
		_startAngle = _spanAngle = 0;
	}

	// Particle information.
	private var _type:ParticleType;
	private var _time:Float;
	private var _stopTime:Float;
	private var _duration:Float;

	// Motion information.
	private var _x:Float;
	private var _y:Float;
	private var _moveX:Float;
	private var _moveY:Float;
	private var _angle:Float;
	private var _firstDraw:Bool;
	private var _ox:Float;
	private var _oy:Float;
	private var _startAngle:Float;
	private var _spanAngle:Float;

	// Gravity information.
	private var _gravity:Float;

	// List information.
	private var _prev:Particle;
	private var _next:Particle;
}
