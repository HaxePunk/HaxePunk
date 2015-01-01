package haxepunk2d;

/**
 * Base class for the graphic types. Do not use this directly, instead use the classes in `haxepunk2d.graphics`.
 */
class Graphic
{
	/** Default `smoothing` value for newly created graphics. */
	static var smooth : Bool.

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

	/**
	 * Rotates the graphic by a certain angle.
	 */
	function rotateBy (angle:Angle) : Void;
}
