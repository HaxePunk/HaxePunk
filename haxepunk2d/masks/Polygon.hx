package haxepunk2d.masks;

/**
 * A mask in the shape of a polygon.
 */
class Polygon extends Mask
{
	/**
	 * Creates a regular polygon (edges of same length) with
	 * [sides] edges of radius [radius].
	 * Ommited config values will use the default values: { offset: (0,0), anchor: (0,0), angle: 0, active: true }.
	 */
	public static function createRegularPolygon(sides:Int, radius:Float, ?config:{ offset:Point, anchor:Point, angle:Angle, active:Bool }):Polygon

	/**
	 * Create a polygon mask from a polygon shape.
	 */
	public static function fromShape(polygon:shapes.Polygon):Polygon;

	/** The points representing the polygon. */
	public var points : Array<Point>;

	/**
	 * Creates a polygon from an array of points.
	 */
	public function new(points:Array<Point>, ?config:MaskConfig);

	/**
	 * Create a polygon shape defined by this polygon mask.
	 */
	public function toShape():shapes.Polygon;
}
