package haxepunk2d.shapes;

/**
 * Represent a circle shape, can be used to create images or masks.
 */
class Circle implements Shape<masks.Circle>
{
	/** The radius of the circle. */
	public var radius:Int;

	/**
	 * Create a circle shape.
	 */
	public function new(radius:Int);

	/**
	 * Create an image of the circle shape.
	 * Equivalent to `Image.fromShape(this)`.
	 */
	public function toImage(?config:ImageConfig):Image;

	/**
	 * Create a circle mask from the shape.
	 * Equivalent to `masks.Circle.fromShape(this)`.
	 */
	public function toMask(?config:MaskConfig):masks.Circle;
}
