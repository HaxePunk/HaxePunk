package com.haxepunk.utils;

import com.haxepunk.HXP;

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
		this.x = x;
		this.y = y;
		this.id = id;
		this.time = 0;
	}

	/**
	 * The touch x-axis coord in the scene.
	 */
	public var sceneX(get, never):Float;
	private inline function get_sceneX():Float { return x + HXP.camera.x; }

	/**
	 * The touch y-axis coord in the scene.
	 */
	public var sceneY(get, never):Float;
	private inline function get_sceneY():Float { return y + HXP.camera.y; }

	/**
	 * If the touch was pressed this frame.
	 */
	public var pressed(get, never):Bool;
	private inline function get_pressed():Bool { return time == 0; }

	/**
	 * Updates the touch state.
	 */
	public function update()
	{
		time += HXP.elapsed;
	}
}
