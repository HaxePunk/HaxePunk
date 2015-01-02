package haxepunk2d.shapes;

/**
 * Represent a box shape, can be used to create images or masks.
 */
class Box implements Shape<masks.Box>
{
	/** The width of the box. */
	public var width:Int;

	/** The height of the box. */
	public var height:Int;

	/**
	 * Create a box shape.
	 */
	public function new(width:Int, height:Int);

	/**
	 * Create an image of the box shape.
	 * Equivalent to `Image.fromShape(this)`.
	 */
	public function toImage(?config:ImageConfig):Image;

	/**
	 * Create a box mask from the shape.
	 * Equivalent to `masks.Box.fromShape(this)`.
	 */
	public function toMask(?config:MaskConfig):masks.Box;
}
