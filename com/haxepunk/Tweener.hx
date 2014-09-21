package com.haxepunk;

import com.haxepunk.Tween;

/**
 * Abstract class used to add the ability to add tweens.
 */
class Tweener
{
	public var active:Bool;
	public var autoClear:Bool;

	@:allow(com.haxepunk)
	private function new()
	{
		active = true;
		autoClear = false;
	}

	@:dox(hide)
	public function update()
	{

	}

	/**
	 * Add the tween to the tween list.
	 *
	 * @param	t		The tween to add.
	 * @param	start	If the tween should start immediately.
	 *
	 * @return	The added tween.
	 */
	public function addTween(t:Tween, start:Bool = false):Tween
	{
		var ft:FriendTween = t;

		if (ft._parent != null)
			throw "Cannot add a Tween object more than once.";

		ft._parent = this;
		ft._next = _tween;
		var friendTween:FriendTween = _tween;

		if (_tween != null)
			friendTween._prev = t;

		_tween = t;

		if (start)
			_tween.start();
		else
			_tween.active = false;

		return t;
	}

	/**
	 * Remove the tween from the tween list.
	 *
	 * @param	t		The tween to remove.
	 *
	 * @return	The removed tween.
	 */
	public function removeTween(t:Tween):Tween
	{
		var ft:FriendTween = t;
		if (ft._parent != this)
			throw "Core object does not contain Tween.";

		if (ft._next != null)
			ft._next._prev = ft._prev;

		if (ft._prev != null)
		{
			ft._prev._next = ft._next;
		}
		else
		{
			_tween = (ft._next == null) ? null : cast(ft._next, Tween);
		}
		ft._next = ft._prev = null;
		ft._parent = null;
		t.active = false;
		return t;
	}

	/**
	 * Remove all tweens from the tween list.
	 */
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

	/**
	 * Update all contained tweens.
	 */
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

	/** If there is at least a tween. */
	public var hasTween(get, never):Bool;
	private function get_hasTween():Bool { return (_tween != null); }

	private var _tween:Tween;
}
