package haxepunk2d.utils;

/**
 *
 */
class Color
{
	public static var BLACK(default, never) = 0x000000;

	public static var WHITE(default, never) = 0xFFFFFF;

	/**
	 *
	 */
	static function lerp (from:Color, to:Color, t:Float) : Color;

	/** */
	var red : Int;

	/** */
	var green : Int;

	/** */
	var blue : Int;

	/** */
	var hue : Int;

	/** */
	var saturation : Int;

	/** */
	var value : Int;

	function darken();
	function lighten();
}
