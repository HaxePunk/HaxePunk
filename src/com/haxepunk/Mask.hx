package com.haxepunk;

import flash.utils.Dictionary;
//import flash.utils.getDefinitionByName;
//import flash.utils.getQualifiedClassName;
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
		_class = Class(getDefinitionByName(getQualifiedClassName(this)));
		_check = new Dictionary();
		_check[Mask] = collideMask;
		_check[Masklist] = collideMasklist;
	}
	
	/**
	 * Checks for collision with another Mask.
	 * @param	mask	The other Mask to check against.
	 * @return	If the Masks overlap.
	 */
	public function collide(mask:Mask):Bool
	{
		if (_check[mask._class] != null) return _check[mask._class](mask);
		if (mask._check[_class] != null) return mask._check[_class](this);
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
	private function assignTo(parent:Entity)
	{
		this.parent = parent;
		if (parent) update();
	}
	
	/** @private Updates the parent's bounds for this mask. */
	private function update()
	{
		
	}
	
	// Mask information.
	private var _class:Class;
	private var _check:Dictionary;
}