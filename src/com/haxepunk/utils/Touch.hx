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

	public var sceneX(getSceneX, never):Float;
	private inline function getSceneX():Float { return x + HXP.camera.x; }

	public var sceneY(getSceneY, never):Float;
	private inline function getSceneY():Float { return y + HXP.camera.y; }

	public var pressed(getPressed, never):Bool;
	private inline function getPressed():Bool { return time == 0; }

	public function update()
	{
		time += HXP.elapsed;
	}
}