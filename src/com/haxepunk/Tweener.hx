package com.haxepunk;

import com.haxepunk.Tween;

typedef FriendTweener = {
	private var _tween:Tween;
}

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
		var ft:FriendTween = t;
		if (ft._parent != null) throw "Cannot add a Tween object more than once.";
		ft._parent = this;
		ft._next = _tween;
		var friendTween:FriendTween = _tween;
		if (_tween != null) friendTween._prev = t;
		_tween = t;
		if (start) _tween.start();
		return t;
	}
	
	public function removeTween(t:Tween):Tween
	{
		var ft:FriendTween = t;
		if (ft._parent != this) throw "Core object does not contain Tween.";
		if (ft._next != null) ft._next._prev = ft._prev;
		if (ft._prev != null) ft._prev._next = ft._next;
		else _tween = cast(ft._next, Tween);
		ft._next = ft._prev = null;
		ft._parent = null;
		t.active = false;
		return t;
	}
	
	public function clearTweens()
	{
		var t:Tween,
			ft:FriendTween= _tween;
		var fn:FriendTween;
		while (ft != null)
		{
			fn = ft._next;
			removeTween(cast(ft, Tween));
			ft = fn;
		}
	}
	
	public function updateTweens()
	{
		var t:Tween,
			ft:FriendTween = _tween;
		while (ft != null)
		{
			t = cast(ft, Tween);
			if (t.active)
			{
				t.update();
				if (ft._finish) ft.finish();
			}
			ft = ft._next;
		}
	}
	
	private var _tween:Tween;
}