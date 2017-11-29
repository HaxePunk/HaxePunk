package haxepunk;

import haxepunk.graphics.hardware.ImageData;
import haxepunk.utils.Color;

interface App
{
	/**
	 * Toggles between windowed and fullscreen modes
	 */
	public var fullscreen(get, set):Bool;

	/**
	 * Initialize the app with an instance of Engine
	 */
	public function init():Void;

	/**
	 * Get the time value in milliseconds. This is an incremental value starting at zero when the app starts.
	 */
	public function getTimeMillis():Float;

	/**
	 * Returns true if multitouch is supported on this platform
	 */
	public function multiTouchSupported():Bool;

	/**
	 * Creates an ImageData instance
	 */
	public function createImageData(width:Int, height:Int, transparent:Bool, color:Color):ImageData;

	/**
	 * Retrieves a named ImageData if it exists in the app assets, otherwise it returns null
	 */
	public function getImageData(name:String):Null<ImageData>;

	/**
	 * The mouse position relative to the app window starting at zero in the upper left
	 */
	public function getMouseX():Float;

	/**
	 * The mouse position relative to the app window starting at zero in the upper left
	 */
	public function getMouseY():Float;
}
