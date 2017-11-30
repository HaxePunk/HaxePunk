package haxepunk;

import haxepunk.graphics.Image;
import haxepunk.graphics.atlas.Atlas;
import haxepunk.screen.ScaleMode;
import haxepunk.utils.Color;

/**
 * Container for the main screen buffer. Can be used to transform the screen.
 * To be used through `HXP.screen`.
 */
class Screen
{
	/**
	 * Controls how the game scale changes when the window is resized.
	 */
	public var scaleMode:ScaleMode = new ScaleMode();

	/**
	 * Constructor.
	 */
	@:allow(haxepunk)
	function new() {}

	/**
	 * Resizes the screen.
	 */
	@:dox(hide)
	@:allow(haxepunk.HXP)
	function resize(width:Int, height:Int)
	{
		var oldWidth:Int = HXP.width,
			oldHeight:Int = HXP.height;

		scaleMode.resize(width, height);

		width = HXP.width = Std.int(HXP.screen.width / HXP.screen.scaleX);
		height = HXP.height = Std.int(HXP.screen.height / HXP.screen.scaleY);
	}

	/**
	 * Refresh color of the screen.
	 */
	public var color:Color = Color.Black;

	/**
	 * X offset of the screen.
	 */
	public var x:Int = 0;

	/**
	 * Y offset of the screen.
	 */
	public var y:Int = 0;

	/**
	 * Width of the screen.
	 */
	@:allow(haxepunk.screen)
	public var width(default, null):Int = 0;

	/**
	 * Height of the screen.
	 */
	@:allow(haxepunk.screen)
	public var height(default, null):Int = 0;

	/**
	 * X scale of the screen.
	 */
	public var scaleX(default, set):Float = 1;
	function set_scaleX(value:Float):Float
	{
		scaleX = value;
		HXP.needsResize = true;
		return scaleX;
	}

	/**
	 * Y scale of the screen.
	 */
	public var scaleY(default, set):Float = 1;
	function set_scaleY(value:Float):Float
	{
		scaleY = value;
		HXP.needsResize = true;
		return scaleY;
	}

	/**
	 * Whether screen smoothing should be used or not.
	 */
	public var smoothing(get, set):Bool;
	function get_smoothing():Bool
	{
		return Atlas.smooth;
	}
	function set_smoothing(value:Bool):Bool
	{
		return Atlas.smooth = value;
	}

	/**
	 * X position of the mouse on the screen.
	 */
	public var mouseX(get, null):Int;
	inline function get_mouseX():Int return Std.int((HXP.app.getMouseX() - x) / scaleX);

	/**
	 * Y position of the mouse on the screen.
	 */
	public var mouseY(get, null):Int;
	inline function get_mouseY():Int return Std.int((HXP.app.getMouseY() - y) / scaleY);

	/**
	 * Captures the current screen as an Image object.
	 * @return	A new Image object.
	 */
	public function capture():Image
	{
		throw "Screen.capture not currently supported";
	}
}
