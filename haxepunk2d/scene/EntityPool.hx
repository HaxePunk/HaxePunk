package haxepunk2d.scene;

/**
 *
 */
class EntityPool
{
	/** The scene the pool is associated with. */
	var scene(default, null) : Scene;

	/**
	 * Clears stored reycled Entities of the Class type.
	 */
	function clear<C:Entity> (type:Class<C>) : Int;

	/**
	 * Clears all stored recycled Entities.
	 */
	function clearAll () : Int;

	/**
	 * Returns a new Entity, or a stored recycled Entity if one exists.
	 */
	function create<C:Entity> (type:Class<C>, addToScene:Bool=true) : C;

	/**
	 * Removes the Entity from the Scene at the end of the frame and recycles it. The recycled Entity can then be fetched again by calling the create() function.
	 */
	function recycle<E:Entity> (e:E) : E;
}
