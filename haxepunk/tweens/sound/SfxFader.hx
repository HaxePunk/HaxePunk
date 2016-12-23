﻿package haxepunk.tweens.sound;

import haxepunk.Sfx;
import haxepunk.Tween;
import haxepunk.utils.Ease;

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
	public function new(sfx:Sfx, ?complete:Dynamic -> Void, ?type:TweenType)
	{
		super(0, type, complete);
		_sfx = sfx;
	}

	/**
	 * Fades the Sfx to the target volume.
	 * @param	volume		The volume to fade to.
	 * @param	duration	Duration of the fade.
	 * @param	ease		Optional easer function.
	 */
	public function fadeTo(volume:Float, duration:Float, ease:Float -> Float = null)
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
	public function crossFade(play:Sfx, loop:Bool, duration:Float, volume:Float = 1, ease:Float -> Float = null)
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
	override public function update()
	{
		super.update();
		if (_sfx != null) _sfx.volume = _start + _range * _t;
		if (_crossSfx != null) _crossSfx.volume = _crossRange * _t;
	}

	/** @private When the tween completes. */
	override private function finish()
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
	private function get_sfx():Sfx return _sfx; 

	// Fader information.
	private var _sfx:Sfx;
	private var _start:Float;
	private var _range:Float;
	private var _crossSfx:Sfx;
	private var _crossRange:Float;
	private var _complete:Dynamic -> Void;
}
