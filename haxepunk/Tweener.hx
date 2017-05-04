package haxepunk;

import haxepunk.Tween;

/**
 * Abstract class used to add the ability to add tweens.
 */
@:access(haxepunk.Tween)
class Tweener
{
	@:isVar public var active(get, set):Bool = true;
	function get_active() return active;
	function set_active(v:Bool) return active = v;

	public var autoClear:Bool = false;

	@:allow(haxepunk)
	function new() {}

	@:dox(hide)
	public function update() {}

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
		if (t._parent != null)
			throw "Cannot add a Tween object more than once.";

		t._parent = this;
		t._next = _tween;

		if (_tween != null)
			_tween._prev = t;

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
		if (t._parent != this)
			throw "Core object does not contain Tween.";

		if (t._next != null)
			t._next._prev = t._prev;

		if (t._prev != null)
		{
			t._prev._next = t._next;
		}
		else
		{
			_tween = (t._next == null) ? null : cast(t._next, Tween);
		}
		t._next = t._prev = null;
		t._parent = null;
		t.active = false;
		return t;
	}

	/**
	 * Remove all tweens from the tween list.
	 */
	public function clearTweens()
	{
		var t:Tween,
			ft:Tween = _tween;
		while (ft != null)
		{
			removeTween(ft._next);
			ft = ft._next;
		}
	}

	/**
	 * Update all contained tweens.
	 */
	public function updateTweens(elapsed:Float)
	{
		var t:Tween,
			ft:Tween = _tween;
		while (ft != null)
		{
			t = cast(ft, Tween);
			if (t.active)
			{
				t.update(elapsed);
				if (ft._finish) ft.finish();
			}
			ft = ft._next;
		}
	}

	/** If there is at least a tween. */
	public var hasTween(get, never):Bool;
	function get_hasTween():Bool return (_tween != null);

	var _tween:Tween;
}
