package haxepunk2d;

/**
 * The DebugConsole allow you to debug your game:
 * show log, view masks, toogle layers and shows frame informations.
 */
class DebugConsole
{
	/** If the debug console was activated. */
	public static var active(default, null):Bool;

	/** The current mode of the debug console. */
	public static var mode : DebugConsoleMode = Close;

	/**
	 * Add a line, [content], to the console.
	 * No effect if the console wasn't activated with `activate`.
	 */
	public static function log(content:Dynamic):Void;

	/**
	 * Activate the debug console.
	 * No effect if the console is already activated.
	 */
	public static function activate():Void;
}

/**
 * List of possible modes for the `DebugConsole`.
 */
enum DebugConsoleMode
{
	/** Minimal view. This is the default value when activating the `DebugConsole`. */
	Close;

	/** Normal view, the game is running. */
	Open;

	/** Show all the log. */
	Log;

	/** Same as the Open mode but the game is paused. */
	Pause;
}
