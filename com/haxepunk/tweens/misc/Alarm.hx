package com.haxepunk.tweens.misc;

import com.haxepunk.Tween;

/**
 * A simple alarm, useful for timed events, etc.
 */
class Alarm extends Tween
{
	/**
	 * Constructor.
	 * @param	duration	Duration of the alarm.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(duration:Float, ?complete:CompleteCallback, type:TweenType)
	{
		super(duration, type, complete, null);
	}

	/**
	 * Sets the alarm.
	 * @param	duration	Duration of the alarm.
	 */
	public function reset(duration:Float)
	{
		_target = duration;
		start();
	}

	/**
	 * How much time has passed since reset.
	 */
	public var elapsed(get, never):Float;
	private function get_elapsed():Float { return _time; }

	/**
	 * Current alarm duration.
	 */
	public var duration(get, never):Float;
	private function get_duration():Float { return _target; }

	/**
	 * Time remaining on the alarm.
	 */
	public var remaining(get, never):Float;
	private function get_remaining():Float { return _target - _time; }
}
