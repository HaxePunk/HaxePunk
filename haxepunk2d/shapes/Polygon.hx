package haxepunk2d.shapes;

/**
 * Represent a polygon shape, can be used to create images or masks.
 */
class Polygon implements Shape<masks.Polygon>
{
	/**
	 * Creates a regular polygon (edges of same length) with
	 * [sides] edges of radius [radius].
	 */
	public static function createRegularPolygon(sides:Int, radius:Float, angle:Angle);

	/** The points representing the polygon. */
	public var points : Array<Point>;

	/**
	 * Create a polygon shape.
	 */
	public function new(points:Array<Point>);

	/**
	 * Create an image of the polygon shape.
	 * Equivalent to `Image.fromShape(this)`.
	 */
	public function toImage(?config:ImageConfig):Image;

	/**
	 * Create a polygon mask from the shape.
	 * Equivalent to `masks.Polygon.fromShape(this)`.
	 */
	public function toMask(?config:MaskConfig):masks.Polygon;
}
