package com.haxepunk.utils;

import flash.geom.Point;
import com.haxepunk.HXP;

enum JoyButtonState
{
	BUTTON_ON;
	BUTTON_OFF;
	BUTTON_PRESSED;
}

class Joystick
{
#if haxe3
	public var buttons:Map<Int,JoyButtonState>;
#else
	public var buttons:IntHash<JoyButtonState>;
#end
	public var axis(null, default):Array<Float>;
	public var hat:Point;
	public var ball:Point;
	public var connected(get_connected, set_connected):Bool;

	public static inline var deadZone:Float = 0.15; //joystick deadzone

	public function new()
	{
#if haxe3
		buttons = new Map<Int,JoyButtonState>();
#else
		buttons = new IntHash<JoyButtonState>();
#end
		ball = new Point(0, 0);
		axis = new Array<Float>();
		hat = new Point(0, 0);
		connected = false;
		_timeout = 0;
	}

	public function update()
	{
		_timeout -= HXP.elapsed;
		for (button in buttons.keys())
		{
			if (buttons.get(button) == BUTTON_PRESSED)
			{
				buttons.set(button, BUTTON_ON);
			}
		}
	}

	public function pressed(button:Int)
	{
		if (buttons.exists(button))
		{
			return buttons.get(button) == BUTTON_PRESSED;
		}
		return false;
	}

	public function check(button:Int)
	{
		if (buttons.exists(button))
		{
			return buttons.get(button) != BUTTON_OFF;
		}
		return false;
	}

	public inline function getAxis(a:Int):Float
	{
		if (a < 1 || a > axis.length) return 0;
		else return (Math.abs(axis[a-1]) < deadZone) ? 0 : axis[a-1];
	}

	private function get_connected():Bool
	{
		return _timeout > 0;
	}
	private function set_connected(value:Bool):Bool
	{
		if (value) _timeout = 3; // 3 seconds to timeout
		else _timeout = 0;
		return value;
	}

	private var _timeout:Float;

}

class XBOX_GAMEPAD
{
	public static var A_BUTTON:Int = 0;
	public static var B_BUTTON:Int = 1;
	public static var X_BUTTON:Int = 2;
	public static var Y_BUTTON:Int = 3;
	public static var LB_BUTTON:Int = 4;
	public static var RB_BUTTON:Int = 5;
	public static var BACK_BUTTON:Int = 6;
	public static var START_BUTTON:Int = 7;
	public static var LEFT_ANALOGUE_BUTTON:Int = 8;
	public static var RIGHT_ANALOGUE_BUTTON:Int = 9;
	public static var LEFT_ANALOGUE_X:Int = 1;
	public static var LEFT_ANALOGUE_Y:Int = 2;
	public static var RIGHT_ANALOGUE_X:Int = 5;
	public static var RIGHT_ANALOGUE_Y:Int = 4;

	/**
	* Keep in mind that if TRIGGER axis returns value > 0 then LT is being pressed, and if it's < 0 then RT is being pressed
	*/
	public static var TRIGGER:Int = 3;
}
