package haxepunk2d;

typedef GraphicConfig = {
	smoothing : Bool,
	layer : Int,
	scrollX : Float,
	scrollY : Float,
	visible : Bool,
	filters : Array<Filter>,
	blendMode : BlendMode,
	active : Bool,
	offset : Point,
	anchor : Point,
	angle : Angle,
	alpha : Float,
	flippedHorizontally : Bool,
	flippedVertically : Bool,
	scale : Scale
};

/**
 * Base class for the graphic types. Do not use this directly, instead use the classes in `haxepunk2d.graphics`.
 */
class Graphic
{
	/** Default `smoothing` value for newly created graphics. */
	public static var smooth : Bool.

	/** The layer on which to draw this graphic. */
	public var layer : Int;

	/** X scrollfactor, effects how much the camera offsets the drawn graphic. Can be used for parallax effect, eg. Set to 0 to follow the camera, 0.5 to move at half-speed of the camera, or 1 (default) to stay still. */
	public var scrollX : Float;

	/** Y scrollfactor, effects how much the camera offsets the drawn graphic. Can be used for parallax effect, eg. Set to 0 to follow the camera, 0.5 to move at half-speed of the camera, or 1 (default) to stay still. */
	public var scrollY : Float;

	/** If the graphic should render. */
	public var visible : Bool;

	/** The filters applied to the entire graphic. */
	public var filters : Array<Filter>;

	/** The graphic's blend mode. */
	public var blendMode : BlendMode;

	/** If the graphic should update. */
	public var active : Bool;

	/**
	 * Pause updating this graphic.
	 */
	public function pause():Void;

	/**
	 * Resume update this graphic.
	 */
	public function resume():Void;

	/** If this graphic should be smoothed. Use `smooth` as default value when a graphic is created. */
	public var smoothing:Bool;

	/** Positon offset relative to the entity the graphic is attached to. */
	public var offset : Point;

	/** The anchor around which the graphic rotate. */
	public var anchor : Point;

	/** The angle of the graphic. */
	public var angle:Angle;

	/** Change the opacity of the graphic, a value from 0 to 1. */
	public var alpha : Float;

	/** If you want to draw the graphic horizontally flipped. */
	public var flippedHorizontally : Bool;

	/** If you want to draw the graphic vertically flipped. */
	public var flippedVertically : Bool;

	/** Scale of the graphic. */
	public var scale : Scale;

	/** The width of the graphic. */
	public var width : Float;

	/** The height of the graphic. */
	public var height : Float;

	/** Half the width of the graphic. */
	public var halfWidth(default, never) : Float;

	/** Half the height of the graphic. */
	public var halfHeight(default, never) : Float;

	/**
	 * Rotates the graphic by a certain angle.
	 */
	public function rotateBy (angle:Angle) : Void;
}
