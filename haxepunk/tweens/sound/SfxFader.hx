package haxepunk.tweens.sound;

import haxepunk.Sfx;
import haxepunk.Tween;
import haxepunk.utils.Ease.EaseFunction;

/**
 * Sound effect fader.
 */
class SfxFader extends Tween
{
	/**
	 * Constructor.
	 * @param	sfx			The Sfx object to alter.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(sfx:Sfx, ?type:TweenType)
	{
		super(0, type);
		_sfx = sfx;
	}

	/**
	 * Fades the Sfx to the target volume.
	 * @param	volume		The volume to fade to.
	 * @param	duration	Duration of the fade.
	 * @param	ease		Optional easer function.
	 */
	public function fadeTo(volume:Float, duration:Float, ?ease:EaseFunction)
	{
		if (volume < 0) volume = 0;
		_start = _sfx.volume;
		_range = volume - _start;
		_target = duration;
		_ease = ease;
		start();
	}

	/**
	 * Fades out the Sfx, while also playing and fading in a replacement Sfx.
	 * @param	play		The Sfx to play and fade in.
	 * @param	loop		If the new Sfx should loop.
	 * @param	duration	Duration of the crossfade.
	 * @param	volume		The volume to fade in the new Sfx to.
	 * @param	ease		Optional easer function.
	 */
	public function crossFade(play:Sfx, loop:Bool, duration:Float, volume:Float = 1, ?ease:EaseFunction)
	{
		_crossSfx = play;
		_crossRange = volume;
		_start = _sfx.volume;
		_range = -_start;
		_target = duration;
		_ease = ease;
		if (loop) _crossSfx.loop(0);
		else _crossSfx.play(0);
		start();
	}

	/** @private Updates the Tween. */
	@:dox(hide)
	override function _update()
	{
		if (_sfx != null) _sfx.volume = _start + _range * _t;
		if (_crossSfx != null) _crossSfx.volume = _crossRange * _t;
	}

	/** @private When the tween completes. */
	override function finish()
	{
		super.finish();
		if (_crossSfx != null)
		{
			if (_sfx != null) _sfx.stop();
			_sfx = _crossSfx;
			_crossSfx = null;
		}
	}

	/**
	 * The current Sfx this object is effecting.
	 */
	public var sfx(get, null):Sfx;
	function get_sfx():Sfx return _sfx;

	// Fader information.
	var _sfx:Sfx;
	var _start:Float;
	var _range:Float;
	var _crossSfx:Sfx;
	var _crossRange:Float;
	var _complete:Dynamic -> Void;
}
