package haxepunk.input.gamepads;

/**
 * Mapping to use a Xbox gamepad with `Gamepad`.
 */
class XboxGamepad
{
#if (mac || linux)
	/**
	 * Button IDs
	 */
	public static inline var A_BUTTON:Int = 0;
	public static inline var B_BUTTON:Int = 1;
	public static inline var X_BUTTON:Int = 2;
	public static inline var Y_BUTTON:Int = 3;
	public static inline var LB_BUTTON:Int = 4;
	public static inline var RB_BUTTON:Int = 5;
	public static inline var BACK_BUTTON:Int = 9;
	public static inline var START_BUTTON:Int = 8;
	public static inline var LEFT_ANALOGUE_BUTTON:Int = 6;
	public static inline var RIGHT_ANALOGUE_BUTTON:Int = 7;

	public static inline var XBOX_BUTTON:Int = 10;

	public static inline var DPAD_UP:Int = 11;
	public static inline var DPAD_DOWN:Int = 12;
	public static inline var DPAD_LEFT:Int = 13;
	public static inline var DPAD_RIGHT:Int = 14;

	/**
	 * Axis array indicies
	 */
	public static inline var LEFT_ANALOGUE_X:Int = 0;
	public static inline var LEFT_ANALOGUE_Y:Int = 1;
	public static inline var RIGHT_ANALOGUE_X:Int = 3;
	public static inline var RIGHT_ANALOGUE_Y:Int = 4;
	public static inline var LEFT_TRIGGER:Int = 2;
	public static inline var RIGHT_TRIGGER:Int = 5;
#elseif android // android
	/**
	 * Button IDs
	 */
	public static inline var A_BUTTON:Int = 0;
	public static inline var B_BUTTON:Int = 1;
	public static inline var X_BUTTON:Int = 3;
	public static inline var Y_BUTTON:Int = 4;
	public static inline var LB_BUTTON:Int = 6;
	public static inline var RB_BUTTON:Int = 7;
	public static inline var BACK_BUTTON:Int = 13;
	public static inline var START_BUTTON:Int = 12;
	public static inline var LEFT_ANALOGUE_BUTTON:Int = 10;
	public static inline var RIGHT_ANALOGUE_BUTTON:Int = 11;

	public static inline var DPAD_UP:Int = 0;
	public static inline var DPAD_DOWN:Int = 1;
	public static inline var DPAD_LEFT:Int = 2;
	public static inline var DPAD_RIGHT:Int = 3;

	/**
	 * Keep in mind that if TRIGGER axis returns value > 0 then LT is being pressed, and if it's < 0 then RT is being pressed
	 */
	public static inline var TRIGGER:Int = 2;
	/**
	 * Axis array indicies
	 */
	public static inline var LEFT_ANALOGUE_X:Int = 0;
	public static inline var LEFT_ANALOGUE_Y:Int = 1;
	public static inline var RIGHT_ANALOGUE_X:Int = 12;
	public static inline var RIGHT_ANALOGUE_Y:Int = 13;
	public static inline var LEFT_TRIGGER:Int = 4;
	public static inline var RIGHT_TRIGGER:Int = 5;
#else // windows
	/**
	 * Button IDs
	 */
	public static inline var A_BUTTON:Int = 0;
	public static inline var B_BUTTON:Int = 1;
	public static inline var X_BUTTON:Int = 2;
	public static inline var Y_BUTTON:Int = 3;
	public static inline var BACK_BUTTON:Int = 4;
	public static inline var START_BUTTON:Int = 6;
	public static inline var LEFT_ANALOGUE_BUTTON:Int = 7;
	public static inline var RIGHT_ANALOGUE_BUTTON:Int = 8;
	public static inline var LB_BUTTON:Int = 9;
	public static inline var RB_BUTTON:Int = 10;

	public static inline var XBOX_BUTTON:Int = 5;

	public static inline var DPAD_UP:Int = 11;
	public static inline var DPAD_DOWN:Int = 12;
	public static inline var DPAD_LEFT:Int = 13;
	public static inline var DPAD_RIGHT:Int = 14;

	/**
	 * Axis array indicies
	 */
	public static inline var LEFT_ANALOGUE_X:Int = 0;
	public static inline var LEFT_ANALOGUE_Y:Int = 1;
	public static inline var RIGHT_ANALOGUE_X:Int = 2;
	public static inline var RIGHT_ANALOGUE_Y:Int = 3;
	public static inline var LEFT_TRIGGER:Int = 4;
	public static inline var RIGHT_TRIGGER:Int = 5;
#end
}
