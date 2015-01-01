package haxepunk2d.masks;

/**
 * The opposite of a Box mask.
 */
class Outside extends Mask
{
	/**
	 * Create the smallest Outside ecompassing the graphic [g].
	 */
	public static function fromGraphic(g:Graphic):Outside;

	/** The width of the outside mask. */
	var width : Float;

	/** The height of the outside mask. */
	var height : Float;

	/** Half the width of the outside mask. */
	var halfWidth(default, never) : Float;

	/** Half the height of the outside mask. */
	var halfHeight(default, never) : Float;

	/**
	 * Create a new outside mask [width] by [height].
	 * Ommited config values will use the default values: { offset: (0,0), anchor: (0,0), angle: 0, active: true }.
	 */
	public function new(width:Int, height:Int, ?config:{ offset:Point, anchor:Point, angle:Angle, active:Bool });
}
