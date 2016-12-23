package haxepunk.tweens.misc;

import haxepunk.HXP;
import haxepunk.Tween;
import haxepunk.utils.Ease;

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
	public function new(?complete:Dynamic -> Void, type:TweenType) 
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
	public function tween(fromAngle:Float, toAngle:Float, duration:Float, ease:Float -> Float = null)
	{
		_start = angle = fromAngle;
		var d:Float = toAngle - angle,
			a:Float = Math.abs(d);
		if (a > 181) _range = (360 - a) * (d > 0 ? -1 : 1);
		else if (a < 179) _range = d;
		else _range = HXP.choose([180, -180]);
		_target = duration;
		_ease = ease;
		start();
	}
	
	/** @private Updates the Tween. */
	@:dox(hide)
	override public function update() 
	{
		super.update();
		angle = (_start + _range * _t) % 360;
		if (angle < 0) angle += 360;
	}
	
	// Tween information.
	private var _start:Float;
	private var _range:Float;
}
