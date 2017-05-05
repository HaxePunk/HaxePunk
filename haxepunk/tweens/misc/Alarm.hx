package haxepunk.tweens.misc;

import haxepunk.Tween;

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
	public function new(duration:Float, ?type:TweenType)
	{
		super(duration, type, null);
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
	function get_elapsed():Float return _time;

	/**
	 * Current alarm duration.
	 */
	public var duration(get, never):Float;
	function get_duration():Float return _target;

	/**
	 * Time remaining on the alarm.
	 */
	public var remaining(get, never):Float;
	function get_remaining():Float return _target - _time;
}
