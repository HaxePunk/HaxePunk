package haxepunk2d.masks;

/**
 * A mask in the shape of a box.
 */
class Box extends Mask
{
	/**
	 * Create the smallest Box ecompassing the graphic [g].
	 */
	public static function fromGraphic(g:Graphic):Box;

	/** The size of the box mask. */
	var size:Size;

	/**
	 * Create a new box mask [width] by [height].
	 * Ommited config values will use the defaults from `defaultConfig`.
	 */
	public function new(width:Int, height:Int, ?config:MaskConfig);
}
