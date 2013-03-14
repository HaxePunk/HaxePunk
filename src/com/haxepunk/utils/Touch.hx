package com.haxepunk.utils;

import com.haxepunk.HXP;

class Touch
{
	public var id(default, null):Int;
	public var x:Float;
	public var y:Float;
	private var time(default, null):Float;

	public function new(x:Float, y:Float, id:Int)
	{
		this.x = x;
		this.y = y;
		this.id = id;
		this.time = 0;
	}

	public var sceneX(get_sceneX, never):Float;
	private inline function get_sceneX():Float { return x + HXP.camera.x; }

	public var sceneY(get_sceneY, never):Float;
	private inline function get_sceneY():Float { return y + HXP.camera.y; }

	public var pressed(get_pressed, never):Bool;
	private inline function get_pressed():Bool { return time == 0; }

	public function update()
	{
		time += HXP.elapsed;
	}
}
