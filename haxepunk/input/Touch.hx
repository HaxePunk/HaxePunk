package haxepunk.input;

import haxepunk.HXP;

class Touch
{
	/**
	 * Touch id used for multiple touches
	 */
	public var id(default, null):Int;
	/**
	 * X-Axis coord in window
	 */
	public var x:Float;
	/**
	 * Y-Axis coord in window
	 */
	public var y:Float;
	/**
	 * Starting X position of touch
	 */
	public var startX:Float;
	/**
	 * Starting Y position of touch
	 */
	public var startY:Float;
	/**
	 * The time this touch has been held
	 */
	public var time(default, null):Float;

	/**
	 * Creates a new touch object
	 * @param  x  x-axis coord in window
	 * @param  y  y-axis coord in window
	 * @param  id touch id
	 */
	public function new(x:Float, y:Float, id:Int)
	{
		this.startX = this.x = x;
		this.startY = this.y = y;
		this.id = id;
		this.time = 0;
	}

	/**
	 * The touch x-axis coord in the scene.
	 */
	public var sceneX(get, never):Float;
	private inline function get_sceneX():Float return x + HXP.camera.x;

	/**
	 * The touch y-axis coord in the scene.
	 */
	public var sceneY(get, never):Float;
	private inline function get_sceneY():Float return y + HXP.camera.y;

	/**
	 * If the touch was pressed this frame.
	 */
	public var pressed(get, never):Bool;
	private inline function get_pressed():Bool return time == 0;

	/**
	 * Not implemented yet. Always return false.
	 */
	public var released:Bool = false;

	/**
	 * Updates the touch state.
	 */
	@:dox(hide)
	public function update()
	{
		time += HXP.elapsed;
	}
}
