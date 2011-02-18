package com.haxepunk.masks;

import com.haxepunk.Mask;

/**
 * A Mask that can contain multiple Masks of one or various types.
 */
class Masklist extends Hitbox
{
	/**
	 * Constructor.
	 * @param	...mask		Masks to add to the list.
	 */
	public function new(mask) 
	{
		_masks = new Array<Mask>();
		_temp = new Array<Mask>();
		
		var m:Mask;
		for (m in mask) add(m);
	}
	
	/** @private Collide against a mask. */
	override public function collide(mask:Mask):Bool 
	{
		var m:Mask;
		for (m in _masks)
		{
			if (m.collide(mask)) return true;
		}
		return false;
	}
	
	/** @private Collide against a Masklist. */
	override private function collideMasklist(other:Masklist):Bool 
	{
		var a:Mask;
		var b:Mask;
		for (a in _masks)
		{
			for (b in other._masks)
			{
				if (a.collide(b)) return true;
			}
		}
		return true;
	}
	
	/**
	 * Adds a Mask to the list.
	 * @param	mask		The Mask to add.
	 * @return	The added Mask.
	 */
	public function add(mask:Mask):Mask
	{
		_masks[_count ++] = mask;
		mask.list = this;
		update();
		return mask;
	}
	
	/**
	 * Removes the Mask from the list.
	 * @param	mask		The Mask to remove.
	 * @return	The removed Mask.
	 */
	public function remove(mask:Mask):Mask
	{
		if (_masks.indexOf(mask) < 0) return mask;
		_temp.length = 0;
		var m:Mask;
		for (m in _masks)
		{
			if (m == mask)
			{
				mask.list = null;
				_count --;
				update();
			}
			else _temp[_temp.length] = m;
		}
		var temp:Array<Mask> = _masks;
		_masks = _temp;
		_temp = temp;
		return mask;
	}
	
	/**
	 * Removes the Mask at the index.
	 * @param	index		The Mask index.
	 */
	public function removeAt(index:Int = 0)
	{
		_temp.length = 0;
		var i:Int = _masks.length;
		index %= i;
		while (i --)
		{
			if (i == index)
			{
				_masks[index].list = null;
				_count --;
				update();
			}
			else _temp[_temp.length] = _masks[index];
		}
		var temp:Array<Mask> = _masks;
		_masks = _temp;
		_temp = temp;
	}
	
	/**
	 * Removes all Masks from the list.
	 */
	public function removeAll()
	{
		var m:Mask;
		for (m in _masks) m.list = null;
		_masks.length = _temp.length = _count = 0;
		update();
	}
	
	/**
	 * Gets a Mask from the list.
	 * @param	index		The Mask index.
	 * @return	The Mask at the index.
	 */
	public function getMask(index:Int = 0):Mask
	{
		return _masks[index % _masks.length];
	}
	
	/** @private Updates the parent's bounds for this mask. */
	override private function update() 
	{
		// find bounds of the contained masks
		var t:Int, l:Int, r:Int, b:Int, h:Hitbox, i:Int = _count;
		while (i --)
		{
			if ((h = cast(_masks[i], Hitbox)))
			{
				if (h._x < l) l = h._x;
				if (h._y < t) t = h._y;
				if (h._x + h._width > r) r = h._x + h._width;
				if (h._y + h._height > b) b = h._y + h._height;
			}
		}
		
		// update hitbox bounds
		_x = l;
		_y = t;
		_width = r - l;
		_height = b - t;
		super.update();
	}
	
	/**
	 * Amount of Masks in the list.
	 */
	public var count(getCount, null):Int;
	private function getCount():Int { return _count; }
	
	// List information.
	private var _masks:Array<Mask>;
	private var _temp:Array<Mask>;
	private var _count:Int;
}