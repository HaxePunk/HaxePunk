package haxepunk2d.inputs;

import haxepunk2d.inputs.Input;
import haxepunk2d.inputs.InputState;

import lime.ui.KeyEventManager;
import lime.ui.KeyCode;

/**
 * Get information on the keyboard input.
 */
class Keyboard
{
	/** If the user has a keyboard available. */
	public static var available(default, null) : Bool;

	/** Contains the string of the last keys pressed */
	public static var keyString(default, null):String = "";

	/** Holds the last key detected */
	public static var last(default, null):Key = Key.NONE;

	/**
	 * Returns the name of the key.
	 *
	 * @param key The key to name
	 * @return The name of [key]
	 */
	public static function nameOf(key:Key):String
	{
		var char:Int = cast key;

		if (char < 0)
		{
			return "";
		}
		if (char >= Key.A && char <= Key.Z)
		{
			return String.fromCharCode(char - Key.A + 65);
		}
		if (char >= Key.F1 && char <= Key.F12)
		{
			return "F" + Std.string(char - Key.F1 + 1);
		}
		if (char >= Key.NUMPAD_1 && char <= Key.NUMPAD_0)
		{
			return "NUMPAD " + Std.string((char - Key.NUMPAD_1 + 1)%10);
		}
		if (char >= Key.DIGIT_0 && char <= Key.DIGIT_9)
		{
			return Std.string(char - Key.DIGIT_0);
		}

		return switch (key)
		{
			case LEFT: "LEFT";
			case UP: "UP";
			case RIGHT: "RIGHT";
			case DOWN: "DOWN";

			case LEFT_SQUARE_BRACKET: "[";
			case RIGHT_SQUARE_BRACKET: "]";
			//~ case TILDE: "~";

			case ENTER: "ENTER";
			case CONTROL: "CONTROL";
			case SPACE: "SPACE";
			case SHIFT: "SHIFT";
			case BACKSPACE: "BACKSPACE";
			case CAPS_LOCK: "CAPS LOCK";
			case DELETE: "DELETE";
			case END: "END";
			case ESCAPE: "ESCAPE";
			case HOME: "HOME";
			case INSERT: "INSERT";
			case TAB: "TAB";
			case PAGE_DOWN: "PAGE DOWN";
			case PAGE_UP: "PAGE UP";

			case NUMPAD_ADD: "NUMPAD ADD";
			case NUMPAD_DECIMAL: "NUMPAD DECIMAL";
			case NUMPAD_DIVIDE: "NUMPAD DIVIDE";
			case NUMPAD_ENTER: "NUMPAD ENTER";
			case NUMPAD_MULTIPLY: "NUMPAD MULTIPLY";
			case NUMPAD_SUBTRACT: "NUMPAD SUBTRACT";

			default: "KEY " + char; // maybe something better?
		}
	}



	/**
	 * Setup the keyboard input support.
	 */
	@:allow(haxepunk.inputs.Input)
	private static function init():Void
	{
		// Register the events from lime
		KeyEventManager.onKeyDown.add(onKeyDown);
		KeyEventManager.onKeyUp.add(onKeyUp);
	}

	/**
	 * Return the value for a key.
	 *
	 * @param key The key to check
	 * @param v The value to get
	 * @return The value of [v] for [key]
	 */
	@:allow(haxepunk.inputs.Input)
	private static function value(key:Key, v:InputValue):Int
	{
		if (key <= -1) // Any
		{
			var result = 0;
			for (state in _states)
			{
				result += state.value(v);
			}
			return result;
		}
		else
		{
			return getInputState(cast key).value(v);
		}
	}

	/**
	 * Updates the keyboard state.
	 */
	@:allow(haxepunk.inputs.Input)
	private static function update():Void
	{
		// Was On last frame if was on the previous one and there is at least the same amount of Pressed than Released.
		// Or wasn't On last frame and Pressed > 0
		for (state in _states)
		{
			state.on = ( (state.on > 0 && state.pressed >= state.released) || (state.on == 0 && state.pressed > 0) ) ? 1 : 0;
			state.pressed = 0;
			state.released = 0;
		}
	}

	/**
	 * Lime onKeyDown event.
	 */
	private static function onKeyDown(keycode:Int, modifiers:Int):Void
	{
		getInputState(keycode).pressed += 1;
		last = cast keycode;
	}

	/**
	 * Lime onKeyUp event.
	 */
	private static function onKeyUp(keycode:Int, modifiers:Int):Void
	{
		getInputState(keycode).released += 1;
		last = cast keycode;
	}

	/**
	 * Gets a mouse state object from a button number.
	 */
	private static function getInputState(button:Int):InputState
	{
		var state:InputState;
		if (_states.exists(button))
		{
			state = _states.get(button);
		}
		else
		{
			state = new InputState();
			_states.set(button, state);
		}
		return state;
	}

	private static var _states:Map<Int, InputState> = new Map<Int, InputState>();

}



/**
 * The keyboard keys.
 */
@:enum
abstract Key(Int) to Int
{
	var NONE = -2;
	var ANY = -1;

	var LEFT = 0x40000050;
	var UP = 0x40000052;
	var RIGHT = 0x4000004F;
	var DOWN = 0x40000051;

	var ENTER = 0x0D;
	//~ var COMMAND = cast KeyCode.COMMAND;
	var CONTROL = 0x400000E0; // LEFT_CTRL
	var SPACE = 0x20;
	var SHIFT = 0x400000E1; // LEFT_SHIFT
	var BACKSPACE = 0x08;
	var CAPS_LOCK = 0x40000039;
	var DELETE = 0x7F;
	var END = 0x4000004D;
	var ESCAPE = 0x1B;
	var HOME = 0x4000004A;
	var INSERT = 0x40000049;
	var TAB = 0x09;
	var PAGE_DOWN = 0x4000004E;
	var PAGE_UP = 0x4000004B;
	var LEFT_SQUARE_BRACKET = 0x5B;
	var RIGHT_SQUARE_BRACKET = 0x5D;
	//~ var TILDE = 192;

	var A = 0x61;
	var B = 0x62;
	var C = 0x63;
	var D = 0x64;
	var E = 0x65;
	var F = 0x66;
	var G = 0x67;
	var H = 0x68;
	var I = 0x69;
	var J = 0x6A;
	var K = 0x6B;
	var L = 0x6C;
	var M = 0x6D;
	var N = 0x6E;
	var O = 0x6F;
	var P = 0x70;
	var Q = 0x71;
	var R = 0x72;
	var S = 0x73;
	var T = 0x74;
	var U = 0x75;
	var V = 0x76;
	var W = 0x77;
	var X = 0x78;
	var Y = 0x79;
	var Z = 0x7A;

	var F1 = 0x4000003A;
	var F2 = 0x4000003B;
	var F3 = 0x4000003C;
	var F4 = 0x4000003D;
	var F5 = 0x4000003E;
	var F6 = 0x4000003F;
	var F7 = 0x40000040;
	var F8 = 0x40000041;
	var F9 = 0x40000042;
	var F10 = 0x40000043;
	var F11 = 0x40000044;
	var F12 = 0x40000045;

	var DIGIT_0 = 0x30;
	var DIGIT_1 = 0x31;
	var DIGIT_2 = 0x32;
	var DIGIT_3 = 0x33;
	var DIGIT_4 = 0x34;
	var DIGIT_5 = 0x35;
	var DIGIT_6 = 0x36;
	var DIGIT_7 = 0x37;
	var DIGIT_8 = 0x38;
	var DIGIT_9 = 0x39;

	var NUMPAD_0 = 0x40000062;
	var NUMPAD_1 = 0x40000059;
	var NUMPAD_2 = 0x4000005A;
	var NUMPAD_3 = 0x4000005B;
	var NUMPAD_4 = 0x4000005C;
	var NUMPAD_5 = 0x4000005D;
	var NUMPAD_6 = 0x4000005E;
	var NUMPAD_7 = 0x4000005F;
	var NUMPAD_8 = 0x40000060;
	var NUMPAD_9 = 0x40000061;
	var NUMPAD_ADD = 0x40000057;
	var NUMPAD_DECIMAL = 0x40000063;
	var NUMPAD_DIVIDE = 0x40000054;
	var NUMPAD_ENTER = 0x40000058;
	var NUMPAD_MULTIPLY = 0x40000055;
	var NUMPAD_SUBTRACT = 0x40000056;

	@:op(A<=B) private static inline function lessEq (lhs:Key, rhs:Int):Bool { return lhs <= rhs; }
	@:op(A<=B) private static inline function lessEq2 (lhs:Int, rhs:Key):Bool { return lhs <= rhs; }
	@:op(A>=B) private static inline function moreEq (lhs:Int, rhs:Key):Bool { return lhs >= rhs; }
	@:op(A>=B) private static inline function moreEq2 (lhs:Int, rhs:Key):Bool { return lhs >= rhs; }
	@:op(A-B) private static inline function sub (lhs:Key, rhs:Int):Int { return lhs - rhs; }
	@:op(A-B) private static inline function sub2 (lhs:Int, rhs:Key):Int { return lhs - rhs; }
}
