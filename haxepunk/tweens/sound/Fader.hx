package haxepunk.tweens.sound;

import haxepunk.HXP;
import haxepunk.Tween;
import haxepunk.utils.Ease;

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
	public function new(?complete:Dynamic -> Void, ?type:TweenType)
	{
		super(0, type, complete);
	}

	/**
	 * Fades FP.volume to the target volume.
	 * @param	volume		The volume to fade to.
	 * @param	duration	Duration of the fade.
	 * @param	ease		Optional easer function.
	 */
	public function fadeTo(volume:Float, duration:Float, ease:Float -> Float = null)
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
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		HXP.volume = _start + _range * _t;
	}

	// Fader information.
	var _start:Float;
	var _range:Float;
}
