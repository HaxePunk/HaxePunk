package com.haxepunk.tweens.misc;

import com.haxepunk.HXP;
import com.haxepunk.Tween;
import com.haxepunk.utils.Ease;

/**
 * Tweens from one angle to another.
 */
class AngleTween extends Tween
{
	/**
	 * The current value.
	 */
	public var angle:Float;
	
	/**
	 * Constructor.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(?complete:CompleteCallback, type:TweenType) 
	{
		angle = 0;
		super(0, type, complete);
	}
	
	/**
	 * Tweens the value from one angle to another.
	 * @param	fromAngle		Start angle.
	 * @param	toAngle			End angle.
	 * @param	duration		Duration of the tween.
	 * @param	ease			Optional easer function.
	 */
	public function tween(fromAngle:Float, toAngle:Float, duration:Float, ease:EaseFunction = null)
	{
		_start = angle = fromAngle;
		var d:Float = toAngle - angle,
			a:Float = Math.abs(d);
		if (a > Math.PI) _range = (Math.PI*2 - a) * (d > 0 ? -1 : 1);
		else if (a < Math.PI) _range = d;
		else _range = HXP.choose([Math.PI, -Math.PI]);

		_target = duration;
		_ease = ease;
		start();
	}
	
	/** @private Updates the Tween. */
	override public function update() 
	{
		super.update();
		angle = (_start + _range * _t) % Math.PI*2;
		if (angle < 0) angle += Math.PI*2;
	}
	
	// Tween information.
	private var _start:Float;
	private var _range:Float;
}
