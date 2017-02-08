package haxepunk.utils;


/**
 * Various randomness-related utility functions.
 * @since	4.0.0
 */
class Random
{
	/**
	 * The random seed used by HXP's random functions.
	 */
	public static var randomSeed(get, set):Int;
	static inline function get_randomSeed() return _seed;
	static inline function set_randomSeed(value:Int):Int
	{
		_seed = Std.int(MathUtil.clamp(value, 1.0, MathUtil.INT_MAX_VALUE - 1));
		return _seed;
	}

	/**
	 * Randomizes the random seed using Flash's Math.random() function.
	 */
	public static inline function randomizeSeed()
	{
		randomSeed = Std.int(MathUtil.INT_MAX_VALUE * Math.random());
	}

	/**
	 * A pseudo-random Float produced using HXP's random seed, where 0 <= Float < 1.
	 */
	public static var random(get, null):Float;
	static inline function get_random():Float
	{
		_seed = Std.int((_seed * 16807.0) % MathUtil.INT_MAX_VALUE);
		return _seed / MathUtil.INT_MAX_VALUE;
	}

	/**
	 * Returns a pseudo-random Int.
	 * @param	amount		The returned Int will always be 0 <= Int < amount.
	 * @return	The Int.
	 */
	public static inline function randInt(amount:Int):Int
	{
		_seed = Std.int((_seed * 16807.0) % MathUtil.INT_MAX_VALUE);
		return Std.int((_seed / MathUtil.INT_MAX_VALUE) * amount);
	}

	// Pseudo-random number generation (the seed is set in Engine's contructor).
	static var _seed:Int = 0;
}
