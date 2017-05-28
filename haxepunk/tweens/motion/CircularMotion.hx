package haxepunk.tweens.motion;

import haxepunk.utils.Ease.EaseFunction;
import haxepunk.utils.MathUtil;

/**
 * Determines a circular motion.
 */
class CircularMotion extends Motion
{
	/**
	 * The current position on the circle.
	 */
	public var angle(default, null):Float = 0;

	/**
	 * The circumference of the current circle motion.
	 */
	public var circumference(get, never):Float;
	function get_circumference():Float return _radius * _CIRC;

	/**
	 * Starts moving along a circle.
	 * @param	centerX		X position of the circle's center.
	 * @param	centerY		Y position of the circle's center.
	 * @param	radius		Radius of the circle.
	 * @param	angle		Starting position on the circle.
	 * @param	clockwise	If the motion is clockwise.
	 * @param	duration	Duration of the movement.
	 * @param	ease		Optional easer function.
	 */
	public function setMotion(centerX:Float, centerY:Float, radius:Float, angle:Float, clockwise:Bool, duration:Float, ?ease:EaseFunction)
	{
		_centerX = centerX;
		_centerY = centerY;
		_radius = radius;
		this.angle = _angleStart = angle * MathUtil.RAD;
		_angleFinish = _CIRC * (clockwise ? 1 : -1);
		_target = duration;
		_ease = ease;
		start();
	}

	/**
	 * Starts moving along a circle at the speed.
	 * @param	centerX		X position of the circle's center.
	 * @param	centerY		Y position of the circle's center.
	 * @param	radius		Radius of the circle.
	 * @param	angle		Starting position on the circle.
	 * @param	clockwise	If the motion is clockwise.
	 * @param	speed		Speed of the movement.
	 * @param	ease		Optional easer function.
	 */
	public function setMotionSpeed(centerX:Float, centerY:Float, radius:Float, angle:Float, clockwise:Bool, speed:Float, ?ease:EaseFunction)
	{
		_centerX = centerX;
		_centerY = centerY;
		_radius = radius;
		this.angle = _angleStart = angle * MathUtil.RAD;
		_angleFinish = _CIRC * (clockwise ? 1 : -1);
		_target = (_radius * _CIRC) / speed;
		_ease = ease;
		start();
	}

	/** @private Updates the Tween. */
	@:dox(hide)
	override function updateInternal()
	{
		angle = _angleStart + _angleFinish * _t;
		x = _centerX + Math.cos(angle) * _radius;
		y = _centerY + Math.sin(angle) * _radius;
	}

	// Circle information.
	var _centerX:Float = 0;
	var _centerY:Float = 0;
	var _radius:Float = 0;
	var _angleStart:Float = 0;
	var _angleFinish:Float = 0;

	static var _CIRC(get, never):Float;
	static inline function get__CIRC():Float return Math.PI * 2;
}
