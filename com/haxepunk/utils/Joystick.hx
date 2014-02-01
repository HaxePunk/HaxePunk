package com.haxepunk.utils;

import flash.geom.Point;
import com.haxepunk.HXP;

enum JoyButtonState
{
	BUTTON_ON;
	BUTTON_OFF;
	BUTTON_PRESSED;
	BUTTON_RELEASED;
}

class Joystick
{
	/**
	 * A map of buttons and their states
	 */
	public var buttons:Map<Int,JoyButtonState>;	
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
		buttons = new Map<Int,JoyButtonState>();
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
			switch (buttons.get(button)) {
				case BUTTON_PRESSED: { buttons.set(button, BUTTON_ON); }
				case BUTTON_RELEASED: { buttons.set(button, BUTTON_OFF); }
				default: {}
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
	 * If the joystick button was released this frame.
	 * @param  button The button index to check.
	 */
	public function released(button:Int):Bool
	{
		if (buttons.exists(button))
		{
			return buttons.get(button) == BUTTON_RELEASED;
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
			var b = buttons.get(button);
			return b != BUTTON_OFF && b != BUTTON_RELEASED;
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

class OUYA_GAMEPAD
{
	public static inline var O_BUTTON:Int = 0; // 96
	public static inline var U_BUTTON:Int = 1; // 99
	public static inline var Y_BUTTON:Int = 2; // 100
	public static inline var A_BUTTON:Int = 3; // 97
	public static inline var LB_BUTTON:Int = 6; // 102
	public static inline var RB_BUTTON:Int = 7; // 103
	public static inline var BACK_BUTTON:Int = 5;
	public static inline var START_BUTTON:Int = 4;
	public static inline var LEFT_ANALOGUE_BUTTON:Int = 8; // 106
	public static inline var RIGHT_ANALOGUE_BUTTON:Int = 9; // 107
	public static inline var HOME_BUTTON:Int = 10; // 82
	public static inline var DPAD_UP:Int = 19;
	public static inline var DPAD_DOWN:Int = 20;
	public static inline var DPAD_LEFT:Int = 21;
	public static inline var DPAD_RIGHT:Int = 22;

	public static inline var LEFT_ANALOGUE_X:Int = 0;
	public static inline var LEFT_ANALOGUE_Y:Int = 1;
	public static inline var RIGHT_ANALOGUE_X:Int = 11;
	public static inline var RIGHT_ANALOGUE_Y:Int = 14;
	public static inline var LEFT_TRIGGER:Int = 17;
	public static inline var RIGHT_TRIGGER:Int = 18;
}

class XBOX_GAMEPAD
{
#if mac
	public static inline var A_BUTTON:Int = 11;
	public static inline var B_BUTTON:Int = 12;
	public static inline var X_BUTTON:Int = 13;
	public static inline var Y_BUTTON:Int = 14;
	public static inline var LB_BUTTON:Int = 8;
	public static inline var RB_BUTTON:Int = 9;
	public static inline var BACK_BUTTON:Int = 5;
	public static inline var START_BUTTON:Int = 4;
	public static inline var LEFT_ANALOGUE_BUTTON:Int = 6;
	public static inline var RIGHT_ANALOGUE_BUTTON:Int = 7;
	public static inline var LEFT_ANALOGUE_X:Int = 0;
	public static inline var LEFT_ANALOGUE_Y:Int = 1;
	public static inline var RIGHT_ANALOGUE_X:Int = 2;
	public static inline var RIGHT_ANALOGUE_Y:Int = 3;
	public static inline var DPAD_UP:Int = 0;
	public static inline var DPAD_DOWN:Int = 1;
	public static inline var DPAD_LEFT:Int = 2;
	public static inline var DPAD_RIGHT:Int = 3;

	//public static inline var TRIGGER:Int = 3;
#else // default windows mapping
	public static inline var A_BUTTON:Int = 0;
	public static inline var B_BUTTON:Int = 1;
	public static inline var X_BUTTON:Int = 2;
	public static inline var Y_BUTTON:Int = 3;
	public static inline var LB_BUTTON:Int = 4;
	public static inline var RB_BUTTON:Int = 5;
	public static inline var BACK_BUTTON:Int = 6;
	public static inline var START_BUTTON:Int = 7;
	public static inline var LEFT_ANALOGUE_BUTTON:Int = 8;
	public static inline var RIGHT_ANALOGUE_BUTTON:Int = 9;
	public static inline var LEFT_ANALOGUE_X:Int = 0;
	public static inline var LEFT_ANALOGUE_Y:Int = 1;
	public static inline var RIGHT_ANALOGUE_X:Int = 4;
	public static inline var RIGHT_ANALOGUE_Y:Int = 3;

	/**
	* Keep in mind that if TRIGGER axis returns value > 0 then LT is being pressed, and if it's < 0 then RT is being pressed
	*/
	public static inline var TRIGGER:Int = 2;
#end
}

class PS3_GAMEPAD
{
	public static inline var TRIANGLE_BUTTON:Int = 12;
	public static inline var CIRCLE_BUTTON:Int = 13;
	public static inline var X_BUTTON:Int = 14;
	public static inline var SQUARE_BUTTON:Int = 15;
	public static inline var L1_BUTTON:Int = 10;
	public static inline var R1_BUTTON:Int = 11;
	public static inline var L2_BUTTON:Int = 8;
	public static inline var R2_BUTTON:Int = 9;
	public static inline var SELECT_BUTTON:Int = 0;
	public static inline var START_BUTTON:Int = 3;
	public static inline var PS_BUTTON:Int = 16;
	public static inline var LEFT_ANALOGUE_BUTTON:Int = 1;
	public static inline var RIGHT_ANALOGUE_BUTTON:Int = 2;
	public static inline var DPAD_UP:Int = 4;
	public static inline var DPAD_DOWN:Int = 6;
	public static inline var DPAD_LEFT:Int = 7;
	public static inline var DPAD_RIGHT:Int = 5;

	public static inline var LEFT_ANALOGUE_X:Int = 0;
	public static inline var LEFT_ANALOGUE_Y:Int = 1;
	public static inline var TRIANGLE_BUTTON_PRESSURE:Int = 16;
	public static inline var CIRCLE_BUTTON_PRESSURE:Int = 17;
	public static inline var X_BUTTON_PRESSURE:Int = 18;
	public static inline var SQUARE_BUTTON_PRESSURE:Int = 19;
}
