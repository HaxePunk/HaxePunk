package haxepunk2d.utils;

/**
 *
 */
class ArrayUtils // to be used with "using"
{
	/**
	 * Returns the previous element in the array relative to the current element.
	 */
	static function previous<T> (array:Array<T>, current:T, loop:Bool = true):T;

	/**
	 * Returns the next element in the array relative to the current element.
	 */
	static function next<T> (array:Array<T>, current:T, loop:Bool = true):T;
}
