package collision;

import collision.Hitbox;
import logic.Unit;

typedef MaskCallback = Dynamic -> Bool;

/**
 * Base class for Entity collision masks.
 */
class Mask 
{
	/**
	 * The parent Entity of this mask.
	 */
	public var parent:ICollidable;
	
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		_class = Type.getClassName(Type.getClass(this));
		_check = new Hash<MaskCallback>();
		//_check.set(Type.getClassName(Mask), collideMask);
	}
	
	/**
	 * Checks for collision with another Mask.
	 * @param	mask	The other Mask to check against.
	 * @return	If the Masks overlap.
	 */
	public function collide(mask:Mask):Bool
	{
		var cbFunc:MaskCallback = _check.get(mask._class);
		if (cbFunc != null) return cbFunc(mask);
		
		cbFunc = mask._check.get(_class);
		if (cbFunc != null) return cbFunc(this);
		
		return false;
	}
	
	/** @private Collide against an Entity.
	private function collideMask(other:Mask):Bool
	{
		return parent.x - parent.originX + parent.width > other.parent.x - other.parent.originX
			&& parent.y - parent.originY + parent.height > other.parent.y - other.parent.originY
			&& parent.x - parent.originX < other.parent.x - other.parent.originX + other.parent.width
			&& parent.y - parent.originY < other.parent.y - other.parent.originY + other.parent.height;
	} */
	
	
	/** @private Assigns the mask to the parent. */
	public function assignTo(parent:ICollidable)
	{
		this.parent = parent;
		if (parent != null) update();
	}
	
	#if debug
	/**
	 * Override this
	 */
	public function debugDraw():Void 
	{
		
	}
	#end
	
	/** Updates the parent's bounds for this mask. */
	public function update()
	{
		
	}
	
	// Mask information.
	private var _class:String;
	private var _check:Hash<MaskCallback>;
}