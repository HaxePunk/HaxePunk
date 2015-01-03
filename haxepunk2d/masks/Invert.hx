package haxepunk2d.masks;

/**
 * The opposite of a mask: the inside doesn't collide but the outside does.
 */
@:generic
class Invert<T:Mask> extends T
{
	override function collide...(...) : Bool
	{
		return !super.collide(...);
	}
}
