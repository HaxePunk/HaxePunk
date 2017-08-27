package haxepunk.tweens.motion;

import haxepunk.utils.Ease.EaseFunction;

/**
 * Determines motion along a line, from one point to another.
 */
class LinearMotion extends Motion
{
	/**
	 * Length of the current line of movement.
	 */
	public var distance(default, null):Float = 0;

	/**
	 * Starts moving along a line.
	 * @param	fromX		X start.
	 * @param	fromY		Y start.
	 * @param	toX			X finish.
	 * @param	toY			Y finish.
	 * @param	duration	Duration of the movement.
	 * @param	ease		Optional easer function.
	 */
	public function setMotion(fromX:Float, fromY:Float, toX:Float, toY:Float, duration:Float, ?ease:EaseFunction)
	{
		set(fromX, fromY, toX, toY);
		_target = duration;
		_ease = ease;
		start();
	}

	/**
	 * Starts moving along a line at the speed.
	 * @param	fromX		X start.
	 * @param	fromY		Y start.
	 * @param	toX			X finish.
	 * @param	toY			Y finish.
	 * @param	speed		Speed of the movement (units per second).
	 * @param	ease		Optional easer function.
	 */
	public function setMotionSpeed(fromX:Float, fromY:Float, toX:Float, toY:Float, speed:Float, ?ease:EaseFunction)
	{
		set(fromX, fromY, toX, toY);
		_target = distance / speed;
		_ease = ease;
		start();
	}

	/** @private Updates the Tween. */
	@:dox(hide)
	override function updateInternal()
	{
		x = _fromX + _moveX * _t;
		y = _fromY + _moveY * _t;
	}

	inline function set(fromX:Float, fromY:Float, toX:Float, toY:Float):Void
	{
		x = _fromX = fromX;
		y = _fromY = fromY;
		_moveX = toX - fromX;
		_moveY = toY - fromY;
		distance = Math.sqrt(_moveX * _moveX + _moveY * _moveY);
	}

	// Line information.
	var _fromX:Float = 0;
	var _fromY:Float = 0;
	var _moveX:Float = 0;
	var _moveY:Float = 0;
}
