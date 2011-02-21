package com.haxepunk;

import com.haxepunk.utils.Ease;

enum TweenType
{
	Persist;
	Looping;
	OneShot;
}

typedef CompleteCallback = Void -> Void;

class Tween
{
	public var active:Bool;
	public var complete:CompleteCallback;
	
	public function new(duration:Float, type:TweenType, complete:CompleteCallback = null, ease:EaseFunction = null)
	{
		_target = duration;
		_type = type;
		this.complete = complete;
		_ease = ease;
		_t = 0;
	}
	
	public function update()
	{
		_time += 1;
		_t = _time / _target;
		if (_ease != null && _t > 0 && _t < 1) _t = _ease(_t);
		if (_time >= _target)
		{
			_t = 1;
			_finish = true;
		}
	}
	
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
	
	public function finish()
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
	
	private var _type:TweenType;
	private var _ease:EaseFunction;
	private var _t:Float;
	
	private var _time:Float;
	private var _target:Float;
	
	public var _finish:Bool;
	public var _parent:Tweener;
	public var _prev:Tween;
	public var _next:Tween;
}