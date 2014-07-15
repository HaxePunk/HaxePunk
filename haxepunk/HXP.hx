package haxepunk;

import lime.ui.Window;
import haxepunk.input.Input;
import haxepunk.graphics.SpriteBatch;

class HXP
{
	public static var window:Window;
	public static var spriteBatch:SpriteBatch;

	@:allow(haxepunk.scene.Scene)
	public static var frameRate(default, null):Float = 0;
}
