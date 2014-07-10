package haxepunk;

import lime.ui.Window;
import haxepunk.input.Input;

class HXP
{
	public static var window:Window;

	@:allow(haxepunk.scene.Scene)
	public static var frameRate(default, null):Float;
}
