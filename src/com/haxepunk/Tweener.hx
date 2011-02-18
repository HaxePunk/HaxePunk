package com.haxepunk;

class Tweener
{
	public var active:Bool;
	public var autoClear:Bool;
	
	public function new()
	{
		active = true;
		autoClear = false;
	}
	
	public function update()
	{
		
	}
	
	public function addTween(t:Tween, start:Bool = false):Tween
	{
		if (t._parent != null) throw "Cannot add a Tween object more than once.";
		t._parent = this;
		t._next = _tween;
		if (_tween != null) _tween._prev = t;
		_tween = t;
		if (start) _tween.start();
		return t;
	}
	
	public function removeTween(t:Tween):Tween
	{
		if (t._parent != this) throw "Core object does not contain Tween.";
		if (t._next != null) t._next._prev = t._prev;
		if (t._prev != null) t._prev._next = t._next;
		else _tween = t._next;
		t._next = t._prev = null;
		t._parent = null;
		t.active = false;
		return t;
	}
	
	public function clearTweens()
	{
		var t:Tween = _tween;
		var n:Tween;
		while (t != null)
		{
			n = t._next;
			removeTween(t);
			t = n;
		}
	}
	
	public function updateTweens()
	{
		var t:Tween = _tween;
		while (t != null)
		{
			if (t.active)
			{
				t.update();
				if (t._finish) t.finish();
			}
			t = t._next;
		}
	}
	
	private var _tween:Tween;
}