package haxepunk2d.shapes;

/**
 * Represent an ellipse shape, can be used to create images or masks.
 */
class Ellipse implements Shape<masks.Ellipse>
{
	/** The radius of the ellipse on the x axis. */
	public var xRadius : Int;

	/** The radius of the ellipse on the y axis. */
	public var yRadius : Int;

	/**
	 * Create an ellipse shape.
	 */
	public function new(xRadius:Int, yRadius:Int);

	/**
	 * Create an image of the ellipse shape.
	 * Equivalent to `Image.fromShape(this)`.
	 */
	public function toImage(?config:ImageConfig):Image;

	/**
	 * Create an ellipse mask from the shape.
	 * Equivalent to `masks.Ellipse.fromShape(this)`.
	 */
	public function toMask(?config:MaskConfig):masks.Ellipse;
}
