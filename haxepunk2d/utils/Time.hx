package haxepunk2d.utils;

/**
 *
 */
class Time
{
	/** Total time elasped in milisecond since the game started. */
	static var totalElapsed : Float;

	/** Total time elasped in milisecond since the last frame.*/
	static var elapsed : Float;

	/**
	 * Sets a time flag. Returns the time elapsed (in milliseconds) since the last time flag was set.
	 * A flag is automatically set when the game start.
	 */
	static function flag () : Float;
}
