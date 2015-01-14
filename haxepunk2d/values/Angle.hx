package haxepunk2d.utils;

/**
 *
 */
class Angle
{
	/** Convert a radian value into a degree value. */
	static var RAD2DEG(default, null) : Float;

	/** Convert a degree value into a radian value. */
	static var DEG2RAD(default, null) : Float;

	/**
	 * Finds the angle (in degrees) from point [p1] to point [p2].
	 */
	static function angle (p1:Point, p2:Point);

	/**
	 * Get difference between the angle [a1] and [a2].
	 */
	static function angleDifference (a1:Angle, a2:Angle) : Angle; // maybe overload the '-' operator?
}
