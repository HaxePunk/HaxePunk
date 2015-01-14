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

	/** The width of the box mask. */
	var width : Float;

	/** The height of the box mask. */
	var height : Float;

	/** Half the width of the box mask. */
	var halfWidth(default, null) : Float;

	/** Half the height of the box mask. */
	var halfHeight(default, null) : Float;

	/**
	 * Create a new box mask [width] by [height].
	 * Ommited config values will use the defaults from `defaultConfig`.
	 */
	public function new(width:Int, height:Int, ?config:MaskConfig);
}
