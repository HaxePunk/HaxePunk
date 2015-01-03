package haxepunk2d.utils;

/**
 *
 */
class Time
{
	/** Total time elasped in miliseconds since the game started. */
	static var totalElapsed : Float;

	/** Total time elasped in miliseconds since the last frame. */
	static var elapsed : Float;
	
	/** The amount of update frames since the game started */
	
	/** The current time in miliseconds. */
	static var current:Float;
	
	/** The timescale applied to Time.elapsed. */
	static var scale:Float;

	/**
	 * Sets a time flag. Returns the time elapsed (in milliseconds) since the last time flag was set.
	 * A flag is automatically set when the game start.
	 */
	static function flag () : Float;
	
	/**
	 * Sets a named time flag.
	 */
	static function start(name:String):Void;
	
	/*
	 * Returns the time (in miliseconds) since the time flag [name] was set and removes it.
	 */
	static function stop(name:String):Float
	
	/*
	 * Returns the delta time (in miliseconds) of a previous measured interval using start() and stop().
	 */
	static function get(name:String):Float
}
