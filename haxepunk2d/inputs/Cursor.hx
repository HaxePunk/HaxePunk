package haxepunk2d.inputs;

/**
 * Used to control and customize the mouse cursor.
 */
class Cursor
{
	/** If the mouse cursor is visible. */
	public var visible : Bool;

	/**
	 * Hides the mouse cursor.
	 */
	public function hide():Void;

	/**
	 * Shows the mouse cursor.
	 */
	public function show():Void;

	/** Custom graphic for the cursor. If null will use the normal arrow cursor. */
	public var graphic : Graphic;

	/** Optional mask to either restrict cursor movement or for entities to react to the cursor position. */
	public var mask : Mask;

	/** If the mouse cursor is locked in place. */
	public var isLocked : Bool;

	/**
	 * Locks the mouse cursor.
	 */
	public function lock():Void;

	/**
	 * Unlocks the mouse cursor.
	 */
	public function unlock():Void;

	/** If the cursor respond to collision. */
	var collidable : Bool;

	/** The groups the cursor belongs to, used to limit collision. */
	var groups : Array<String>;
}
