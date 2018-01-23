package haxepunk;

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
	 * The mouse position relative to the app window starting at zero in the upper left
	 */
	public function getMouseX():Float;

	/**
	 * The mouse position relative to the app window starting at zero in the upper left
	 */
	public function getMouseY():Float;
}
