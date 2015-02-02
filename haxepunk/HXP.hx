package haxepunk;

import lime.ui.Window;
import haxepunk.scene.Scene;
import haxepunk.graphics.SpriteBatch;
import haxepunk.graphics.Color;

class HXP
{
	public static var window:Window;

	// TODO: change this so it can't get out of sync with Engine
	@:allow(haxepunk.Engine)
	public static var scene(default, null):Scene;

	public static var spriteBatch:SpriteBatch;

	@:allow(haxepunk.scene.Scene)
	public static var frameRate(default, null):Float = 0;

	@:allow(haxepunk.Engine)
	public static var updateTime(default, null):Float = 0;
	@:allow(haxepunk.Engine)
	public static var renderTime(default, null):Float = 0;

	public static var entityColor:Color = new Color(1, 0, 0);
	public static var maskColor:Color = new Color(0, 1, 0);
	public static var selectColor:Color = new Color(0.9, 0.9, 0.9);
}
