package haxepunk.input.gamepads;
 
class OuyaGamepad
{
#if android	// android mapping
	public static inline var O_BUTTON:Int = 0; // 96
	public static inline var U_BUTTON:Int = 1; // 99
	public static inline var Y_BUTTON:Int = 2; // 100
	public static inline var A_BUTTON:Int = 3; // 97
	public static inline var LB_BUTTON:Int = 4; // 102
	public static inline var RB_BUTTON:Int = 5; // 103
	public static inline var BACK_BUTTON:Int = -1;
	public static inline var START_BUTTON:Int = -1;
	public static inline var LEFT_ANALOGUE_BUTTON:Int = 6; // 106
	public static inline var RIGHT_ANALOGUE_BUTTON:Int = 7; // 107
	public static inline var LEFT_TRIGGER_BUTTON:Int = 14;
	public static inline var RIGHT_TRIGGER_BUTTON:Int = 10;
	public static inline var DPAD_UP:Int = 8;
	public static inline var DPAD_DOWN:Int = 9;
	public static inline var DPAD_LEFT:Int = 13;
	public static inline var DPAD_RIGHT:Int = 12;
	public static inline var HOME_BUTTON:Int = 11; // 82


	// axis
	public static inline var LEFT_ANALOGUE_X:Int = 0;
	public static inline var LEFT_ANALOGUE_Y:Int = 1;
	public static inline var RIGHT_ANALOGUE_X:Int = 12;
	public static inline var RIGHT_ANALOGUE_Y:Int = 13;
	public static inline var LEFT_TRIGGER:Int = 2;
	public static inline var RIGHT_TRIGGER:Int = 5;
#else	// desktop mapping
	public static inline var O_BUTTON:Int = 0;
	public static inline var U_BUTTON:Int = 1;
	public static inline var Y_BUTTON:Int = 2;
	public static inline var A_BUTTON:Int = 3;
	public static inline var LB_BUTTON:Int = 4;
	public static inline var RB_BUTTON:Int = 5;
	public static inline var BACK_BUTTON:Int = 20; // no back button!
	public static inline var START_BUTTON:Int = 20; // no start button!
	public static inline var LEFT_ANALOGUE_BUTTON:Int = 6;
	public static inline var RIGHT_ANALOGUE_BUTTON:Int = 7;
	public static inline var LEFT_TRIGGER_BUTTON:Int = 12;
	public static inline var RIGHT_TRIGGER_BUTTON:Int = 13;
	public static inline var DPAD_UP:Int = 8;
	public static inline var DPAD_DOWN:Int = 9;
	public static inline var DPAD_LEFT:Int = 10;
	public static inline var DPAD_RIGHT:Int = 11;
	
	/**
	 * The Home button only works on the Ouya-console
	 */
	public static inline var HOME_BUTTON:Int = 16777234;

	public static inline var LEFT_ANALOGUE_X:Int = 0;
	public static inline var LEFT_ANALOGUE_Y:Int = 1;
	public static inline var RIGHT_ANALOGUE_X:Int = 5;
	public static inline var RIGHT_ANALOGUE_Y:Int = 4;
	public static inline var LEFT_TRIGGER:Int = 2;	// negative values before button trigger, positive values after
	public static inline var RIGHT_TRIGGER:Int = 3;	// negative values before button trigger, positive values after
#end
}
