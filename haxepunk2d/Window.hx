package haxepunk2d;

/**
 * The window in which the game runs.
 */
class Window
{
	/** The width of the window. */
	public var width : Int;

	/** The height of the window. */
	public var height : Int;

	/** Half the width of the window. */
	public var halfWidth(default, null) : Float;

	/** Half the height of the window. */
	public var halfHeight(default, null) : Float;

	/** The center of the window. */
	public var center(default, null) : Point;

	/** The window orientation. */
	public var orientation : Orientation;

	/** Wheter the window can change orientation or not. */
	public var canChangeOrientation : Bool;

	/** Scale mode used when the game size isn't equal to the window size. */
	public var scaleMode : ScaleMode = ExactFit;

	/** Position of the game inside the window when the game size isn't equal to the window size. */
	public var gamePosition : Position = CENTER_CENTER;

	/** The background color of the window, defaults is black. */
	public var backgroundColor : Color = BLACK;

	/** If the window is fullscreen. */
	public static var fullscreen : Bool;

	/** If the window can go into fullscreen. */ // Added it because it was on my list, but not sure when you can't go fullscreen
	public static var canFullscreen(default, null) : Bool;

	/**
	 * Resize the window.
	 * Do not work on flash and html5 targets.
	 */
	public static function resize (width:Int, height:Int) : Void;
}

enum ScaleMode
{
	Strecht;
	NoScale;
	ExactFit;
	NearestIntergerScale;
}

enum Orientation
{
	Landscape;
	Portait;
}

enum Position
{
	TOP_LEFT;
	TOP_CENTER;
	TOP_RIGHT;
	CENTER_LEFT;
	CENTER_CENTER;
	CENTER_RIGHT;
	BOTTOM_LEFT;
	BOTTOM_CENTER;
	BOTTOM_RIGHT;
}
