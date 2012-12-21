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
	public var buttons:IntHash<JoyButtonState>;
	public var axis:Point;
	public var hat:Point;
	public var ball:Point;
	public var connected:Bool;

	public function new()
	{
		buttons = new IntHash<JoyButtonState>();
		ball = new Point(0, 0);
		axis = new Point(0, 0);
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