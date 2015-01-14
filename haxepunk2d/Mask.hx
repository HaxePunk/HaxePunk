package haxepunk2d;

typedef MaskConfig = {
	@:optional offset:Point,
	@:optional anchor:Point,
	@:optional angle:Angle,
	@:optional active:Bool
};

/**
 * Base class for the mask types. Do not use this directly, instead use the classes in `haxepunk2d.masks`.
 */
class Mask
{
	/** Default values for newly created masks when config options are ommited. */
	public static var defaultConfig : MaskConfig;

	/** The top left position of the mask. */
	public var topLeft(default, never) : Point;

	/** The top right position of the mask. */
	public var topRight(default, never) : Point;

	/** The center position of the mask. */
	public var center(default, never) : Point;

	/** The bottom left position of the mask. */
	public var bottomLeft(default, never) : Point;

	/** The bottom right position of the mask. */
	public var bottomRight(default, never) : Point;

	/** The topmost position of the mask.*/
	public var top(default, never) : Point;

	/** The leftmost position of the mask.*/
	public var left(default, never) : Point;

	/** The rightmost position of the mask.*/
	public var right(default, never) : Point;

	/** The bottommost position of the mask.*/
	public var bottom(default, never) : Point;

	/** Positon offset relative to the entity the mask is attached to.*/
	public var offset : Point;

	/** The anchor around which the mask rotate. */
	public var anchor : Point;

	/** The angle of the mask. */
	public var angle : Angle;
	/**
	 * Rotates the mask by a certain amount.
	 */
	public function rotateBy (angle:Angle) : Void;

	/** If the mask collides or not. */
	public var active : Bool;

	/** The bounding shape used to make a first fast collision check. The default value depends on the actual mask used. */
	public var boundingShape : BoundingShape;
}

enum BoundingShape
{
	Box;
	Circle;
}
