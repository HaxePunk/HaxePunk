package haxepunk.backend.dummy;

class App implements haxepunk.App
{
	public var fullscreen(get, set):Bool;
	inline function get_fullscreen():Bool return false;
	inline function set_fullscreen(value:Bool):Bool return value;

	public function new() {}

	public function init() {}

	public function getTimeMillis():Float return 0;

	public function multiTouchSupported():Bool return false;

	public function getMouseX():Float return 0;
	public function getMouseY():Float return 0;
}
