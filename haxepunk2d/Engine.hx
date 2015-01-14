package haxepunk2d;

/**
 * Manage all the game, your main class need to extends it.
 *
 * Example:
 * ```
 * class Main extends haxepunk2d.Engine
 * {
 * 		public function override begin ()
 * 		{
 * 			scene = new MyScene();
 * 		}
 *
 * 		public static function new () { new Main(); }
 * }
 * ```
 */
class Engine
{
	/**
	 * Initialise the game, omitted configuration variables will use the default value.
	 *
	 * Default values: { width: 800, height: 600, frameRate: 60, fixedFrameRate: false, backgroundColor: 0x333333, fullscreen: false, smoothing: true }.
	 */
	public function new (?config : { width:Int, height:Int, frameRate:Int, fixedFrameRate:Bool, backgroundColor: Color, fullscreen:Bool, smoothing: false });

	/** The width of the game. */
	public static var width : Int;

	/** The height of the game. */
	public static var height : Int;

	/** Half the width of the game. */
	public static var halfWidth(default, null) : Float;

	/** Half the height of the game. */
	public static var halfHeight(default, null) : Float;

	/** The center of the game. */
	public static var center(default, null) : Point;

	/** The scale factor of the game. */
	public static var scale : Scale;

	/** Whether screen smoothing should be used or not. True by default. */
	public static var smoothing : Bool = true;

	/** Whether all positions will be rounded to the nearest integer when rendering, for a crisper image. False by default. */
	public static var pixelSnapping : Bool = false;

	/** The filters applied to the entire game. */
	public static var filters : Array<Filter>;

	/** The game window. */
	public static var window : Window;

	/** The background color of the game. */
	public static var backgroundColor : Color;

	/** If the game has focus. */
	public static var hasFocus(default, null) : Bool;

	// Fixed frame rate
	/** If fixed frame rate is used. */
	public static var isFixedFrameRate : Bool;

	/** Cap on the elapsed time (default at 30 FPS). Raise this to allow for lower framerates (eg. 1 / 10). */
	public static var maxElasped : Float;

	/** The maximum amount of frames that can be skipped in fixed framerate mode. */
	public static var maxFrameSkip : Int;

	/** The amount of milliseconds between ticks in fixed framerate mode. */
	public static var tickRate : Int;

	/** If the game should stop updating/rendering. */
	public static var paused : Bool;

	/** If the game should pause/resume automatically when focus is lost/re-gained. True by default.*/
	public static var autoPause : Bool = true;

	/** The currently active Scene object. When you set this, the Scene is flagged to switch, but won't actually do so until the end of the current frame. */
	public static var scene : SceneList;

	/**
	 * Cause the game to shake for a specified length of time.
	 */
	public static function shake(magnitude:Int, duration:Float):Void;

	/**
	 * Stop the game from shaking immediately.
	 */
	public static function stopShake():Void;

	/**
	 * Captures the current game view as an Image object.
	 */
	public static function capture () : Image;

	/**
	 * Reset the game, put back all variables to their default values, recall begin.
	 * If [quit] is true will call `quit` before reseting.
	 */
	public static function reset (?quit:Bool=true) : Void;

	/**
	 * Stop the game.
	 */
	public static function quit () : Void;

	// To override
	/**
	 * Override this, called when game gains focus.
	 * If `autoPause` is true, by default it is, then `pause` will be set to true after this function returns;
	 */
	public function focusGained () : Void;

	/**
	 * Override this, called when game loses focus.
	 * If `autoPause` is true, by default it is, then `pause` will be set to false after this function returns;
	 */
	public function focusLost () : Void;

	/**
	 * Override this, called when the Engine is ready for you.
	 */
	public function begin () : Void; // previously init

	/**
	 * Override this, called when the window was resized.
	 */
	public function resized (oldSize:Size, newSize:Size) : Void;

	/**
	 * Override this, called when game is quitting.
	 */
	public function end () : Void;

	/**
	 * Override this, called in the main game loop.
	 */
	public function update () : Void;
}
