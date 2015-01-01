package haxepunk2d.utils;

/**
 *
 */
class Random
{
	/** The seed of the generator. Using the same seed will result in the same sequence of values. */
	public static var seed:Int;

	/**
	 * Returns a random integer.
	 */
	public static function randInt():Int;

	/**
	 * Returns a random float.
	 */
	public static function randFloat():Float;

	/**
	 * Return a random value between [min] and [max].
	 */
	public static function randRange<T>(min:T, max:T):T;

	/**
	 * Return a random point.
	 * Do NOT do `new Point(randInt(), randInt())`, this will result in a biased distribution of points.
	 */
	public static function randPoint():Point;

	/**
	 * Returns a random boolean.
	 * Probability of true equals [trueProba], of false 1 - [trueProba].
	 * By default [trueProba] equals 0.5.
	 */
	public static function randBool(trueProba:Float=0.5):Bool;

	/**
	 * Returns a random color.
	 */
	public static function randColor():Color;

	/**
	 * Choose a random element from the array with either a probability distribution [probaDistrib] or if omitted an equal probability.
	 */
	public static function choose<T> (values:Array<T>, ?probaDistrib:Array<Float>) : T;

	/**
	 * Shuffle the array. Returns a new copy and doesn't modify the array passed in argument.
	 */
	public static function shuffle<T> (array:Array<T>) : Array<T>;
}
