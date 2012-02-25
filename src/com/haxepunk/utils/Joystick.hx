package com.haxepunk.utils;

import flash.geom.Point;

class Joystick
{
	public var buttons:Array<Bool>;
	public var axis:Point;
	public var hat:Point;
	public var ball:Point;
	public var connected:Bool;

	public function new()
	{
		buttons = new Array<Bool>();
		ball = new Point(0, 0);
		axis = new Point(0, 0);
		hat = new Point(0, 0);
		connected = false;
	}

}