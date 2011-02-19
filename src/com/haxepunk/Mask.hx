package com.haxepunk;

import flash.utils.Dictionary;
import com.haxepunk.masks.Hitbox;
import com.haxepunk.masks.Masklist;

/**
 * Base class for Entity collision masks.
 */
class Mask 
{
	/**
	 * The parent Entity of this mask.
	 */
	public var parent:Entity;
	
	/**
	 * The parent Masklist of the mask.
	 */
	public var list:Masklist;
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		_class = Type.getClassName(Type.getClass(this));
		_check = new Hash<Dynamic->Bool>();
		_check.set(Type.getClassName(Mask), collideMask);
		_check.set(Type.getClassName(Masklist), collideMasklist);
	}
	
	/**
	 * Checks for collision with another Mask.
	 * @param	mask	The other Mask to check against.
	 * @return	If the Masks overlap.
	 */
	public function collide(mask:Mask):Bool
	{
		trace(_check);
		trace(mask._class);
		if (_check.get(mask._class) != null) return _check.get(mask._class)(mask);
		if (mask._check.get(_class) != null) return mask._check.get(_class)(this);
		return false;
	}
	
	/** @private Collide against an Entity. */
	private function collideMask(other:Mask):Bool
	{
		return parent.x - parent.originX + parent.width > other.parent.x - other.parent.originX
			&& parent.y - parent.originY + parent.height > other.parent.y - other.parent.originY
			&& parent.x - parent.originX < other.parent.x - other.parent.originX + other.parent.width
			&& parent.y - parent.originY < other.parent.y - other.parent.originY + other.parent.height;
	}
	
	/** @private Collide against a Masklist. */
	private function collideMasklist(other:Masklist):Bool
	{
		return other.collide(this);
	}
	
	/** @private Assigns the mask to the parent. */
	public function assignTo(parent:Entity)
	{
		this.parent = parent;
		if (parent != null) update();
	}
	
	/** Updates the parent's bounds for this mask. */
	public function update()
	{
		
	}
	
	// Mask information.
	private var _class:String;
	private var _check:Hash<Dynamic->Bool>;
}