package haxepunk2d.masks;

/**
 * A mask in the shape of a polygon.
 */
class Polygon extends Mask
{
	/**
	 * Creates a regular polygon (edges of same length) with
	 * [sides] edges of radius [radius].
	 * Ommited config values will use the defaults from `defaultConfig`.
	 */
	public static function createRegularPolygon(sides:Int, radius:Float, ?config:MaskConfig):Polygon;

	/** The points representing the polygon. */
	public var points : Array<Point>;

	/**
	 * Creates a polygon from an array of points.
	 * Ommited config values will use the defaults from `defaultConfig`.
	 */
	public function new(points:Array<Point>, ?config:MaskConfig);
}
