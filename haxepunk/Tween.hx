package haxepunk;

import haxepunk.ds.Maybe;
import haxepunk.Signal.Signal0;

/**
 * The type of the tween.
 */
enum TweenType
{
	/**
	 * Default type, the tween is still available after it ended and can
	 * be started again with the start() method.
	 */
	Persist;

	/** The tween will loop. */
	Looping;

	/** The tween will be removed after it ended. */
	OneShot;

	/** The tween will loop, alternating backwards and forwards */
	PingPong;
}

/**
 * <p>
 * Base class for tweening helpers.
 * A Tween is any object that interpolates something be<i>tween</i> two
 * values.  It does not have to be a linear path, for instance a circular
 * motion.
 * </p>
 * <p>
 * Do not use this directly, instead use the classes in haxepunk.tweens.*
 * </p>
 */
class Tween
{
	/** If the tween is active. */
	public var active:Bool = false;

	/** Whether tween is currently running forward. For TweenType.PingPong. */
	public var forward:Bool = true;

	/** Signal fires when tween starts */
	public var started = new Signal0();

	/** Signal fires when tween updates */
	public var updated = new Signal0();

	/** Signal fires when tween is completed */
	public var complete = new Signal0();

	/**
	 * Constructor. Specify basic information about the Tween.
	 * @param	duration		Duration of the tween (in seconds).
	 * @param	type			Tween type, one of Tween.PERSIST (default), Tween.LOOPING, or Tween.ONESHOT.
	 * @param	ease			Optional easer function to apply to the Tweened value.
	 */
	public function new(duration:Float, ?type:TweenType, ?ease:Float -> Float)
	{
		if (duration < 0)
		{
			throw "Tween duration must be positive!";
		}
		_target = duration;
		_type = type == null ? TweenType.Persist : type;
		_ease = ease;
		_t = 0;
	}

	/** @private Update function for override in subclasses */
	function _update() {}

	/**
	 * Updates the Tween, called by World.
	 */
	@:dox(hide)
	public function update(elapsed:Float)
	{
		var isFinished = false;
		if (active)
		{
			_time += elapsed;
			_t = percent;
			if (_t > 0 && _t < 1) _ease.may(function(f) _t = f(_t));
			if (_time >= _target)
			{
				_t = forward ? 1 : 0;
				isFinished = true;
			}
			_update();
			updated.invoke();
		}
		if (isFinished)
		{
			finish();
		}
	}

	/**
	 * Starts the Tween, or restarts it if it's currently running.
	 */
	public function start()
	{
		_time = 0;
		if (_target == 0)
		{
			active = false;
			complete.invoke();
		}
		else
		{
			active = true;
			started.invoke();
		}
	}

	/** @private Called when the Tween completes. */
	function finish()
	{
		switch (_type)
		{
			case Persist:
				_time = _target;
				active = false;
			case Looping, PingPong:
				if (_type == PingPong) forward = !forward;
				start();
			case OneShot:
				_time = _target;
				cancel();
		}
		complete.invoke();

		if (_type == TweenType.OneShot)
		{
			complete.clear();
		}
	}

	/**
	 * Immediately stops the Tween and removes it from its Tweener without calling the complete callback.
	 */
	public function cancel()
	{
		active = false;
		if (_parent != null)
		{
			_parent.removeTween(this);
		}
	}

	/** Progression of the tween, between 0 and 1. */
	public var percent(get, set):Float;
	function get_percent():Float return _target == 0 ? 0 : ((forward ? _time : (_target - _time)) / _target);
	function set_percent(value:Float):Float return _time = _target * value;

	public var scale(get, null):Float;
	function get_scale():Float return _t;

	var _type:TweenType;
	var _ease:Maybe<Float -> Float>;
	var _t:Float;

	var _time:Float = 0;
	var _target:Float;

	var _parent:Tweener;
	var _prev:Tween;
	var _next:Tween;
}
