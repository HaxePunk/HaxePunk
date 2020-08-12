package haxepunk.tweens.misc;

import haxepunk.HXP;
import haxepunk.Tween;
import haxepunk.math.Degrees;
import haxepunk.utils.Ease.EaseFunction;

/**
 * Tweens from one angle to another.
 */
class AngleTween extends Tween
{
	/**
	 * The current value.
	 */
	public var angle:Degrees = 0;

	/**
	 * Constructor.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(?type:TweenType)
	{
		super(0, type);
	}

	/**
	 * Tweens the value from one angle to another. Rotates on the shortest angle.
	 * @param	fromAngle		Start angle.
	 * @param	toAngle			End angle.
	 * @param	duration		Duration of the tween.
	 * @param	ease			Optional easer function.
	 */
	public function tween(fromAngle:Degrees, toAngle:Degrees, duration:Float, ?ease:EaseFunction)
	{
		_start = angle = fromAngle;
		var d:Degrees = toAngle - angle,
			a:Degrees = d.abs();
		if (a > 181) _range = (360 - a) * (d > 0 ? -1 : 1);
		else if (a < 179) _range = d;
		else _range = HXP.choose([180, -180]);
		_target = duration;
		_ease = ease;
		start();
	}

	/** @private Updates the Tween. */
	@:dox(hide)
	override function updateInternal()
	{
		angle = (_start + _range * _t) % 360;
		if (angle < 0) angle += 360;
	}

	// Tween information.
	var _start:Degrees;
	var _range:Degrees;
}
