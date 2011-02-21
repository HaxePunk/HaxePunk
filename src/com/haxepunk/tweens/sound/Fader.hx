package com.haxepunk.tweens.sound;

import com.haxepunk.HXP;
import com.haxepunk.Tween;
import com.haxepunk.utils.Ease;

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
	public function new(complete:CompleteCallback = null, type:TweenType) 
	{
		super(0, type, complete);
	}
	
	/**
	 * Fades FP.volume to the target volume.
	 * @param	volume		The volume to fade to.
	 * @param	duration	Duration of the fade.
	 * @param	ease		Optional easer function.
	 */
	public function fadeTo(volume:Float, duration:Float, ease:EaseFunction = null)
	{
		if (volume < 0) volume = 0;
		_start = HXP.volume;
		_range = volume - _start;
		_target = duration;
		_ease = ease;
		start();
	}
	
	/** @private Updates the Tween. */
	override public function update() 
	{
		super.update();
		HXP.volume = _start + _range * _t;
	}
	
	// Fader information.
	private var _start:Float;
	private var _range:Float;
}