package haxepunk.graphics;

import haxepunk.HXP;
import haxepunk.utils.Color;

/**
 * Used by the Emitter class to track an existing Particle.
 */
@:dox(hide)
@:allow(haxepunk.graphics.Emitter)
@:access(haxepunk.graphics.ParticleType)
class Particle
{
	public function x(td:Float):Float
	{
		return _x + _ox + _moveX * (_type._backwards ? 1 - td : td);
	}
	public function y(td:Float):Float
	{
		return _y + _oy + _moveY * (_type._backwards ? 1 - td : td) + Math.pow(td * _gravity, 2);
	}

	public function angle(td:Float):Float
	{
		return _startAngle + _spanAngle * td;
	}

	public function color(td:Float):UInt
	{
		var r = _type._red + _type._redRange * td,
			g = _type._green + _type._greenRange * td,
			b = _type._blue + _type._blueRange * td;
		return Color.getColorRGB(Std.int(r * 0xff), Std.int(g * 0xff), Std.int(b * 0xff));
	}

	public function alpha(td:Float):Float
	{
		return _type._alpha + _type._alphaRange * td;
	}

	public function scale(td:Float):Float
	{
		return _type._scale + _type._scaleRange * td;
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
