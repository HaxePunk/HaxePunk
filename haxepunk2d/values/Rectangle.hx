package haxepunk2d.utils;

/**
 *
 */
class Rectangle
{
	/**  */
	var x : Float;

	/**  */
	var y : Float;

	/**  */
	var width : Float;

	/**  */
	var height : Float;

	/**
	 *
	 */
	static function distance (r1:Rectangle, r2:Rectangle) : Float;

	/**
	 *
	 */
	static function distanceTo (e:Either<...>) : Float;

	/**
	 *
	 */
	static function distanceSquared (r1:Rectangle, r2:Rectangle) : Float;

	/**
	 *
	 */
	static function distanceToSquared (e:Either<...>) : Float;
}
