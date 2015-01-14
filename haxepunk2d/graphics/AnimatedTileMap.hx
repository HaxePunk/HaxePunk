package haxepunk2d.graphics;

/**
 * An extention to TileMap where the tiles can be animated.
 */
class AnimatedTileMap extends TileMap
{
	/**
	 * Whether the tile [index] is animated.
	 */
	public function isAnimated(index:Int):Bool;

	/**
	 * Return the animation information associated with the tile [index].
	 * If the tile wasn't animated return null.
	 * Modifying the TileAnimation object won't change the animation,
	 * to update an animation use `setAnimation`.
	 */
	public function getAnimation(index:Int):TileAnimation;

	/**
	 * Modify the tile [index] to be animated.
	 * If the tile was already animated the previous animation will be overwritten.
	 */
	public function setAnimation(index:Int, frames:Either<Array<Int>, Array<Point>>, frameRate:Float) : Void;

	/**
	 * Sets the index sequence of the animated tile located at [colum]-[row].
	 */
	public function setTileAnimation(column:Int, row:Int, frames:Either<Array<Int>, Array<Point>>, frameRate:Float) : Void;

	/**
	 * Sets the index sequence of a collection of animated tiles located
	 * in the rectangle starting at [column]-[row] of size [width] by [height].
	 */
	public function setRectangleAnimation(column:Int, row:Int, width:Int, height:Int, frames:Either<Array<Int>, Array<Point>>, frameRate:Float) : Void;

	/**
	 * Sets the index sequence of a collection of animated tiles located
	 * in the outline of thickness [outlineThickness] of the rectangle
	 * starting at [column]-[row] of size [width] by [height].
	 */
	public function setRectangleOutlineAnimation(column:Int, row:Int, width:Int, height:Int, outlineThickness:Int, frames:Either<Array<Int>, Array<Point>>, frameRate:Float) : Void;
}

typedef TileAnimation = {
	frames:Array<Int>,
	frameRate:Float;
};
