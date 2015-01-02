package haxepunk2d.masks;

/**
 * A mask in the shape of an ellipse.
 */
class Ellipse extends Mask
{
	/**
	 * Create an ellipse mask from an ellipse shape.
	 */
	public static function fromShape(ellipse:shapes.Ellipse):Ellipse;

	/** The radius of the ellipse mask on the x axis. */
	public var xRadius : Int;

	/** The radius of the ellipse mask on the y axis. */
	public var yRadius : Int;

	/** The diameter of the ellipse mask on the x axis. */
	public var xDiameter(get, never) : Int;

	/** The diameter of the ellipse mask on the y axis. */
	public var yDiameter(get, never) : Int;

	/**
	 * Create a new ellipse mask of radius [xRadius] on the
	 * x axis and [yRadius] on the y axis.
	 * Ommited config values will use the default values: { offset: (0,0), anchor: (0,0), angle: 0, active: true }.
	 */
	public function new(xRadius:Int, yRadius:Int, ?config:MaskConfig);

	/**
	 * Create an ellipse shape defined by this ellipse mask.
	 */
	public function toShape():shapes.Ellipse;
}
