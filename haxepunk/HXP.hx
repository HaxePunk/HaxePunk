package haxepunk;

import lime.ui.Window;
import haxepunk.scene.Scene;
import haxepunk.graphics.SpriteBatch;

class HXP
{
	public static var window:Window;

	// TODO: change this so it can't get out of sync with Engine
	@:allow(haxepunk.Engine)
	public static var scene(default, null):Scene;

	public static var spriteBatch:SpriteBatch;

	@:allow(haxepunk.scene.Scene)
	public static var frameRate(default, null):Float = 0;
}
