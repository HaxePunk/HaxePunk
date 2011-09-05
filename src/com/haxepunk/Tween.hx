package com.haxepunk;

import com.haxepunk.tweens.TweenInfo;
import com.haxepunk.utils.Ease;

enum TweenType
{
	Persist;
	Looping;
	OneShot;
}

typedef CompleteCallback = Void -> Void;

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

class Tween
{
	public var active:Bool;
	public var complete:CompleteCallback;
	
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
		this.complete = complete;
		_ease = ease;
		_t = 0;
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
			return;
		}
		active = true;
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
		if (complete != null) complete();
	}
	
	public var percent(getPercent, setPercent):Float;
	private function getPercent():Float { return _time / _target; }
	private function setPercent(value:Float):Float { _time = _target * value; return _time; }
	
	public var scale(getScale, null):Float;
	private function getScale():Float { return _t; }
	
	/**
	 * Tweens the properties of an object.
	 * @param	object		Object to tween.
	 * @param	duration	Duration of the tween.
	 * @param	values		Properties to tween and their target values (eg. {x:100, y:200}).
	 * @param	complete	Optional completion callback function.
	 * @param	ease		Optional easer function.
	 */
	public static function to(object:Dynamic, duration:Float, values:Dynamic, ?complete:CompleteCallback, ?ease:EaseFunction)
	{
		var t:TweenInfo = TweenInfo.create(object, duration, values, complete, ease),
			i:Int = _tweens.length;
		while (i-- > 0)
		{
			if (_tweens[i] == null)
			{
				_tweens[i] = t;
				return;
			}
		}
		_tweens.push(t);
	}
	
	/**
	 * Clears any active static tweens called by Tween.to()
	 */
	public static function clear()
	{
		var tween:TweenInfo;
		for (tween in _tweens) tween.destroy();
		HXP.clear(_tweens);
	}
	
	/** @private Updates the static tweens */
	public static function updateStatic()
	{
		var e:Float, t:Float, i:String, tween:TweenInfo, j:Int = _tweens.length, f:CompleteCallback;
		while (j-- > 0)
		{
			tween = _tweens[j];
			if (tween != null)
			{
				tween.elapsed += HXP.elapsed;
				e = tween.elapsed / tween.duration;
				if (e >= 1) e = 1;
				t = tween.ease == null ? e : tween.ease(e);
				for (i in tween.start.keys()) Reflect.setField(tween.object, i, tween.start.get(i) + tween.range.get(i) * t);
				if (e == 1)
				{
					f = tween.complete;
					tween.destroy();
					_tweens[j] = null;
					if (f != null) f();
				}
			}
		}
	}
	
	private var _type:TweenType;
	private var _ease:EaseFunction;
	private var _t:Float;
	
	private var _time:Float;
	private var _target:Float;
	
	private var _finish:Bool;
	private var _parent:Tweener;
	private var _prev:FriendTween;
	private var _next:FriendTween;
	private static var _tweens:Array<TweenInfo> = new Array<TweenInfo>();
}