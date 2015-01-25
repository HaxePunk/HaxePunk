package haxepunk2d.masks;

/**
 * This object contains information about an occurred collision.
 */
class Collision
{
	/** The amount both masks overlap each other. */
	public var overlap:Float;
	
	/** A point which when applied to entityA will seperate both masks. */
	public var seperation:Point;
	
	/** The first entity involved in the collision. */
	public var entityA:Entity;
	/** The mask of the first entity involved in the collision. */
	public var maskA:Mask;
	
	/** The second entity involved in the collision. */
	public var entityB:Entity;
	/** The mask of the second entity involved in the collision. */
	public var maskB:Mask;
	
	/** Creates a new Collision object. */
	public function new();
}
