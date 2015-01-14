package haxepunk2d;

typedef GraphicConfig = {
	@:optional smoothing : Bool,
	@:optional layer : Int,
	@:optional scrollX : Float,
	@:optional scrollY : Float,
	@:optional visible : Bool,
	@:optional filters : Array<Filter>,
	@:optional blendMode : BlendMode,
	@:optional active : Bool,
	@:optional offset : Point,
	@:optional anchor : Point,
	@:optional angle : Angle,
	@:optional alpha : Float,
	@:optional flippedHorizontally : Bool,
	@:optional flippedVertically : Bool,
	@:optional scale : Scale
};

enum ImageFormat
{
	BMP;
	JPG;
	PNG;
}

/**
 * Base class for the graphic types. Do not use this directly, instead use the classes in `haxepunk2d.graphics`.
 */
class Graphic
{
	/** Default values for newly created graphics when config options are ommited. */
	public static var defaultConfig : GraphicConfig;

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

	/** If this graphic should be smoothed. */
	public var smooth:Bool;

	/** Positon offset relative to the entity the graphic is attached to. */
	public var offset : Point;

	/** The anchor around which the graphic rotate. */
	public var anchor : Point;

	/** The angle of the graphic. */
	public var angle:Angle;

	/** Change the opacity of the graphic, a value from 0 to 1. */
	public var alpha : Float;

	/** If you want to draw the graphic horizontally (on the x-axis) flipped. */
	public var flippedX : Bool;

	/** If you want to draw the graphic vertically (on the y-axis) flipped. */
	public var flippedY : Bool;

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

	/**
	 * Save the graphic to the disk.
	 * Only available on target with filesystem access.
	 * If [format] isn't specified it will be inferred from the extension in [fileName].
	 */
	public function saveToDisk(fileName:String, ?format:ImageFormat):Void;
}
