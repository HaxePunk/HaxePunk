package haxepunk.tweens.motion;

import haxepunk.Tween.TweenType;
import haxepunk.HXP;
import haxepunk.utils.Ease.EaseFunction;
import flash.geom.Point;

/**
 * Determines motion along a quadratic curve.
 */
class QuadMotion extends Motion
{
	/**
	 * Constructor.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(type:TweenType)
	{
		_distance = -1;
		_fromX = _fromY = _toX = _toY = 0;
		_controlX = _controlY = 0;
		super(0, type, null);
	}

	/**
	 * Starts moving along the curve.
	 * @param	fromX		X start.
	 * @param	fromY		Y start.
	 * @param	controlX	X control, used to determine the curve.
	 * @param	controlY	Y control, used to determine the curve.
	 * @param	toX			X finish.
	 * @param	toY			Y finish.
	 * @param	duration	Duration of the movement.
	 * @param	ease		Optional easer function.
	 */
	public function setMotion(fromX:Float, fromY:Float, controlX:Float, controlY:Float, toX:Float, toY:Float, duration:Float, ?ease:EaseFunction)
	{
		_distance = -1;
		x = _fromX = fromX;
		y = _fromY = fromY;
		_controlX = controlX;
		_controlY = controlY;
		_toX = toX;
		_toY = toY;
		_target = duration;
		_ease = ease;
		start();
	}

	/**
	 * Starts moving along the curve at the speed.
	 * @param	fromX		X start.
	 * @param	fromY		Y start.
	 * @param	controlX	X control, used to determine the curve.
	 * @param	controlY	Y control, used to determine the curve.
	 * @param	toX			X finish.
	 * @param	toY			Y finish.
	 * @param	speed		Speed of the movement.
	 * @param	ease		Optional easer function.
	 */
	public function setMotionSpeed(fromX:Float, fromY:Float, controlX:Float, controlY:Float, toX:Float, toY:Float, speed:Float, ?ease:EaseFunction)
	{
		_distance = -1;
		x = _fromX = fromX;
		y = _fromY = fromY;
		_controlX = controlX;
		_controlY = controlY;
		_toX = toX;
		_toY = toY;
		_target = distance / speed;
		_ease = ease;
		start();
	}

	/** @private Updates the Tween. */
	@:dox(hide)
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		x = _fromX * (1 - _t) * (1 - _t) + _controlX * 2 * (1 - _t) * _t + _toX * _t * _t;
		y = _fromY * (1 - _t) * (1 - _t) + _controlY * 2 * (1 - _t) * _t + _toY * _t * _t;
	}

	/**
	 * The distance of the entire curve.
	 */
	public var distance(get, null):Float;
	function get_distance():Float
	{
		if (_distance >= 0) return _distance;
		var a:Point = HXP.point,
			b:Point = HXP.point2;
		a.x = x - 2 * _controlX + _toX;
		a.y = y - 2 * _controlY + _toY;
		b.x = 2 * _controlX - 2 * x;
		b.y = 2 * _controlY - 2 * y;
		var a1:Float = 4 * (a.x * a.x + a.y * a.y),
			b1:Float = 4 * (a.x * b.x + a.y * b.y),
			c1:Float = b.x * b.x + b.y * b.y,
			abc:Float = 2 * Math.sqrt(a1 + b1 + c1),
			a2:Float = Math.sqrt(a1),
			a32:Float = 2 * a1 * a2,
			c2:Float = 2 * Math.sqrt(c1),
			ba:Float = b1 / a2;
		return (a32 * abc + a2 * b1 * (abc - c2) + (4 * c1 * a1 - b1 * b1) * Math.log((2 * a2 + ba + abc) / (ba + c2))) / (4 * a32);
	}

	// Curve information.
	var _distance:Float;
	var _fromX:Float;
	var _fromY:Float;
	var _toX:Float;
	var _toY:Float;
	var _controlX:Float;
	var _controlY:Float;
}
