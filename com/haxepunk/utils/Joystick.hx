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
	/**
	 * A map of buttons and their states
	 */
#if haxe3
	public var buttons:Map<Int,JoyButtonState>;
#else
	public var buttons:IntHash<JoyButtonState>;
#end
	/**
	 * Each axis contained in an array.
	 */
	public var axis(null, default):Array<Float>;
	/**
	 * A Point containing the joystick's hat value.
	 */
	public var hat:Point;
	/**
	 * A Point containing the joystick's ball value.
	 */
	public var ball:Point;

	/**
	 * Determines the joystick's deadZone. Anything under this value will be considered 0 to prevent jitter.
	 */
	public static inline var deadZone:Float = 0.15;

	/**
	 * Creates and initializes a new Joystick.
	 */
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

	/**
	 * Updates the joystick's state.
	 */
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

	/**
	 * If the joystick button was pressed this frame.
	 * @param  button The button index to check.
	 */
	public function pressed(button:Int):Bool
	{
		if (buttons.exists(button))
		{
			return buttons.get(button) == BUTTON_PRESSED;
		}
		return false;
	}

	/**
	 * If the joystick button is held down.
	 * @param  button The button index to check.
	 */
	public function check(button:Int):Bool
	{
		if (buttons.exists(button))
		{
			return buttons.get(button) != BUTTON_OFF;
		}
		return false;
	}

	/**
	 * Returns the axis value (from 0 to 1)
	 * @param  a The axis index to retrieve starting at 0
	 */
	public inline function getAxis(a:Int):Float
	{
		if (a < 0 || a >= axis.length) return 0;
		else return (Math.abs(axis[a]) < deadZone) ? 0 : axis[a];
	}

	/**
	 * If the joystick is currently connected.
	 */
	public var connected(get_connected, set_connected):Bool;
	private function get_connected():Bool { return _timeout > 0; }
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
#if windows
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
	public static var LEFT_ANALOGUE_X:Int = 0;
	public static var LEFT_ANALOGUE_Y:Int = 1;
	public static var RIGHT_ANALOGUE_X:Int = 4;
	public static var RIGHT_ANALOGUE_Y:Int = 3;

	/**
	* Keep in mind that if TRIGGER axis returns value > 0 then LT is being pressed, and if it's < 0 then RT is being pressed
	*/
	public static var TRIGGER:Int = 2;
#elseif mac
	public static var A_BUTTON:Int = 11;
	public static var B_BUTTON:Int = 12;
	public static var X_BUTTON:Int = 13;
	public static var Y_BUTTON:Int = 14;
	public static var LB_BUTTON:Int = 8;
	public static var RB_BUTTON:Int = 9;
	public static var BACK_BUTTON:Int = 5;
	public static var START_BUTTON:Int = 4;
	public static var LEFT_ANALOGUE_BUTTON:Int = 6;
	public static var RIGHT_ANALOGUE_BUTTON:Int = 7;
	public static var LEFT_ANALOGUE_X:Int = 0;
	public static var LEFT_ANALOGUE_Y:Int = 1;
	public static var RIGHT_ANALOGUE_X:Int = 2;
	public static var RIGHT_ANALOGUE_Y:Int = 3;
	public static var DPAD_UP:Int = 0;
	public static var DPAD_DOWN:Int = 1;
	public static var DPAD_LEFT:Int = 2;
	public static var DPAD_RIGHT:Int = 3;

	//public static var TRIGGER:Int = 3;
#end
}
