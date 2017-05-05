package haxepunk.tweens.misc;

import haxepunk.Tween;
import haxepunk.utils.Ease.EaseFunction;

/**
 * Tweens a numeric value.
 */
class NumTween extends Tween
{
	/**
	 * The current value.
	 */
	public var value:Float = 0;

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
	 * Tweens the value from one value to another.
	 * @param	fromValue		Start value.
	 * @param	toValue			End value.
	 * @param	duration		Duration of the tween.
	 * @param	ease			Optional easer function.
	 */
	public function tween(fromValue:Float, toValue:Float, duration:Float, ?ease:EaseFunction)
	{
		_start = value = fromValue;
		_range = toValue - value;
		_target = duration;
		_ease = ease;
		start();
	}

	/** @private Updates the Tween. */
	@:dox(hide)
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		value = _start + _range * _t;
	}

	// Tween information.
	var _start:Float;
	var _range:Float;
}
