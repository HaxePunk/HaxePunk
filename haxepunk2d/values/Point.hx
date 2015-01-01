package haxepunk2d.utils;

/**
 * A point in 2D space.
 */
class Point
{
	/** x value of the point. */
	var x : Float;

	/** y value of the point. */
	var y : Float;

	/**
	 *
	 */
	public inline function new (x:Float, y:Float)
	{
		this.x = x;
		this.y = y;
	}

	/**
	 * Distance between point [p1] and point [p2].
	 */
	static function distance (p1:Point, p2:Point) : Float;

	/**
	 *
	 */
	static function distanceTo (e:Either<...>) : Float;

	/**
	 * Squared distance between point [p1] and point [p2].
	 * Faster than `distance`.
	 */
	static function distanceSquared (p1:Point, p2:Point) : Float;

	/**
	 *
	 */
	static function distanceToSquared (e:Either<...>) : Float;

	/**
	 * Create [numberOfPoints] in a rectange [width] by [height] following a blue noise distribution.
	 */
	static function blueNoise(width:Int, height:Int, numberOfPoints:Int):Array<Point>;

	/**
	 * Create [numberOfPoints] in a rectange [width] by [height] following a white noise distribution.
	 */
	static function whiteNoise(width:Int, height:Int, numberOfPoints:Int):Array<Point>;

	function tweenTo(e:Either<Point, Array<Point>>, duration:Float):Tween;

	function tweenInCircularMotion():Tween;
	function tweenInCubicMotion():Tween;
	function tweenInQuadMotion():Tween;
	function tweenInQuadPath():Tween;
}
