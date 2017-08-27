package haxepunk.tweens.sound;

import haxepunk.HXP;
import haxepunk.Tween;
import haxepunk.utils.Ease.EaseFunction;

/**
 * Global volume fader.
 */
class Fader extends Tween
{
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
	 * Fades FP.volume to the target volume.
	 * @param	volume		The volume to fade to.
	 * @param	duration	Duration of the fade.
	 * @param	ease		Optional easer function.
	 */
	public function fadeTo(volume:Float, duration:Float, ?ease:EaseFunction)
	{
		if (volume < 0) volume = 0;
		_start = HXP.volume;
		_range = volume - _start;
		_target = duration;
		_ease = ease;
		start();
	}

	/** @private Updates the Tween. */
	@:dox(hide)
	override function updateInternal()
	{
		HXP.volume = _start + _range * _t;
	}

	// Fader information.
	var _start:Float;
	var _range:Float;
}
