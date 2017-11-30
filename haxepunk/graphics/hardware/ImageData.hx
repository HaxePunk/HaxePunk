package haxepunk.graphics.hardware;

import haxepunk.utils.Color;

interface ImageData
{
	/**
	 * Read-only width of the image in pixels
	 */
	public var width(default, null):Int;

	/**
	 * Read-only height of the image in pixels
	 */
	public var height(default, null):Int;

	/**
	 * Gets the pixel color value as an integer
	 */
	public function getPixel(x:Int, y:Int):Int;

	/**
	 * Removes a color from the image
	 */
	public function removeColor(color:Color):Void;

	/**
	 * Fills the entire image using a single color
	 */
	public function clearColor(color:Color):Void;

	/**
	 * Draw a circle to the image data
	 */
	public function drawCircle(x:Float, y:Float, radius:Float):Void;

	/**
	 * Discards the image data
	 */
	public function dispose():Void;
}
