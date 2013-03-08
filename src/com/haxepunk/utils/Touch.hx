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

	public var worldX(getWorldX, never):Float;
	private inline function getWorldX():Float { return x + HXP.camera.x; }

	public var worldY(getWorldY, never):Float;
	private inline function getWorldY():Float { return y + HXP.camera.y; }

	public var pressed(getPressed, never):Bool;
	private inline function getPressed():Bool { return time == 0; }

	public function update()
	{
		time += HXP.elapsed;
	}
}