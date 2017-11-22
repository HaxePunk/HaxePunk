package haxepunk;

import haxepunk.utils.Color;

#if lime

typedef App = haxepunk.backend.lime.App;

#elseif nme

typedef App = haxepunk.backend.nme.App;

#else

class App
{
	/**
	 * Toggles between windowed and fullscreen modes
	 */
	public var fullscreen:Bool;

	public function new(engine:Engine) {}

	public function init() {}

	public function getTimeMillis():Float return 0;

	public function setScreenColor(color:Color) {}

	public function multiTouchSupported():Bool return false;

	public function getImageData(name:String):ImageData return null;

	public var getMouseX():Float return 0;
	public var getMouseY():Float return 0;
}

#end
