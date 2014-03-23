package com.haxepunk;

import com.haxepunk.utils.Ease;
import com.haxepunk.tweens.TweenEvent;
import flash.events.EventDispatcher;

enum TweenType
{
	Persist;
	Looping;
	OneShot;
}

typedef CompleteCallback = Dynamic -> Void;

/**
 * Friend class for access to Tween private members
 */
typedef FriendTween = {
	private function finish():Void;

	private var _finish:Bool;
	private var _parent:Tweener;
	private var _prev:FriendTween;
	private var _next:FriendTween;
}

class Tween extends EventDispatcher
{
	public var active:Bool;

	/**
	 * Constructor. Specify basic information about the Tween.
	 * @param	duration		Duration of the tween (in seconds or frames).
	 * @param	type			Tween type, one of Tween.PERSIST (default), Tween.LOOPING, or Tween.ONESHOT.
	 * @param	complete		Optional callback for when the Tween completes.
	 * @param	ease			Optional easer function to apply to the Tweened value.
	 */
	public function new(duration:Float, ?type:TweenType, ?complete:CompleteCallback, ?ease:EaseFunction)
	{
		_target = duration;
		if (type == null) type = TweenType.Persist;
		_type = type;
		_ease = ease;
		_t = 0;
		_callback = complete;
		super();

		if (_callback != null)
		{
			addEventListener(TweenEvent.FINISH, _callback);
		}
	}

	/**
	 * Updates the Tween, called by World.
	 */
	public function update()
	{
		_time += HXP.fixed ? 1 : HXP.elapsed;
		_t = _time / _target;
		if (_ease != null && _t > 0 && _t < 1) _t = _ease(_t);
		if (_time >= _target)
		{
			_t = 1;
			_finish = true;
		}
		dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
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
			dispatchEvent(new TweenEvent(TweenEvent.FINISH));
		}
		else
		{
			active = true;
			dispatchEvent(new TweenEvent(TweenEvent.START));
		}
	}

	/** @private Called when the Tween completes. */
	private function finish()
	{
		switch(_type)
		{
			case Persist:
				_time = _target;
				active = false;
			case Looping:
				_time %= _target;
				_t = _time / _target;
				if (_ease != null && _t > 0 && _t < 1) _t = _ease(_t);
				start();
			case OneShot:
				_time = _target;
				active = false;
				_parent.removeTween(this);
		}
		_finish = false;
		dispatchEvent(new TweenEvent(TweenEvent.FINISH));
		
		if (_type == TweenType.OneShot && _callback != null)
		{
			removeEventListener(TweenEvent.FINISH, _callback);
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

	public var percent(get, set):Float;
	private function get_percent():Float { return _time / _target; }
	private function set_percent(value:Float):Float { _time = _target * value; return _time; }

	public var scale(get, null):Float;
	private function get_scale():Float { return _t; }

	private var _type:TweenType;
	private var _ease:EaseFunction;
	private var _t:Float;

	private var _time:Float;
	private var _target:Float;

	private var _callback:CompleteCallback;
	private var _finish:Bool;
	private var _parent:Tweener;
	private var _prev:FriendTween;
	private var _next:FriendTween;
}
