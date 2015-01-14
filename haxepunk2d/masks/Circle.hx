package haxepunk2d.masks;

/**
 * A mask in the shape of a circle.
 */
class Circle extends Mask
{
	/**
	 * Create the smallest circle ecompassing the graphic [g].
	 */
	public static function fromGraphic(g:Graphic):Circle;

	/** The radius of the circle mask. */
	public var radius : Int;

	/** The diameter of the circle mask. */
	public var diameter(get, never) : Int;

	/**
	 * Create a new circle mask of radius [radius].
	 * Ommited config values will use the defaults from `defaultConfig`.
	 */
	public function new(radius:Int, ?config:MaskConfig);
}
