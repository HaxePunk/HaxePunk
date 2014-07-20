package haxepunk.inputs;

import haxe.ds.IntMap;
import haxepunk.inputs.Input;
import haxepunk.inputs.InputState;
import lime.ui.KeyEventManager;

/**
 * Get information on the keyboard input.
 */
class Keyboard
{

	/** Contains the string of the last keys pressed */
	public static var keyString(default, null):String = "";

	/** Holds the last key detected */
	public static var last(default, null):Key = Key.ANY;

	/**
	 * Returns the name of the key.
	 *
	 * @param key The key to name
	 * @return The name of [key]
	 */
	public static function nameOf(key:Key):String
	{
		var char:Int = cast key;

		if (char == -1)
		{
			return "";
		}
		if (char >= Key.A && char <= Key.Z)
		{
			return String.fromCharCode(char);
		}
		if (char >= Key.F1 && char <= Key.F15)
		{
			return "F" + Std.string(char - Key.F1 + 1);
		}
		if (char >= Key.NUMPAD_0 && char <= Key.NUMPAD_9)
		{
			return "NUMPAD " + Std.string(char - Key.NUMPAD_0);
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
			case TILDE: "~";

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

	private static var _states:IntMap<InputState> = new IntMap<InputState>();

}



/**
 * The keyboard keys.
 */
@:enum
abstract Key(Int) to Int
{
	var ANY = -1;

	var LEFT = 37;
	var UP = 38;
	var RIGHT = 39;
	var DOWN = 40;

	var ENTER = 13;
	var COMMAND = 15;
	var CONTROL = 17;
	var SPACE = 32;
	var SHIFT = 16;
	var BACKSPACE = 8;
	var CAPS_LOCK = 20;
	var DELETE = 46;
	var END = 35;
	var ESCAPE = 27;
	var HOME = 36;
	var INSERT = 45;
	var TAB = 9;
	var PAGE_DOWN = 34;
	var PAGE_UP = 33;
	var LEFT_SQUARE_BRACKET = 219;
	var RIGHT_SQUARE_BRACKET = 221;
	var TILDE = 192;

	var A = 65;
	var B = 66;
	var C = 67;
	var D = 68;
	var E = 69;
	var F = 70;
	var G = 71;
	var H = 72;
	var I = 73;
	var J = 74;
	var K = 75;
	var L = 76;
	var M = 77;
	var N = 78;
	var O = 79;
	var P = 80;
	var Q = 81;
	var R = 82;
	var S = 83;
	var T = 84;
	var U = 85;
	var V = 86;
	var W = 87;
	var X = 88;
	var Y = 89;
	var Z = 90;

	var F1 = 112;
	var F2 = 113;
	var F3 = 114;
	var F4 = 115;
	var F5 = 116;
	var F6 = 117;
	var F7 = 118;
	var F8 = 119;
	var F9 = 120;
	var F10 = 121;
	var F11 = 122;
	var F12 = 123;
	var F13 = 124;
	var F14 = 125;
	var F15 = 126;

	var DIGIT_0 = 48;
	var DIGIT_1 = 49;
	var DIGIT_2 = 50;
	var DIGIT_3 = 51;
	var DIGIT_4 = 52;
	var DIGIT_5 = 53;
	var DIGIT_6 = 54;
	var DIGIT_7 = 55;
	var DIGIT_8 = 56;
	var DIGIT_9 = 57;

	var NUMPAD_0 = 96;
	var NUMPAD_1 = 97;
	var NUMPAD_2 = 98;
	var NUMPAD_3 = 99;
	var NUMPAD_4 = 100;
	var NUMPAD_5 = 101;
	var NUMPAD_6 = 102;
	var NUMPAD_7 = 103;
	var NUMPAD_8 = 104;
	var NUMPAD_9 = 105;
	var NUMPAD_ADD = 107;
	var NUMPAD_DECIMAL = 110;
	var NUMPAD_DIVIDE = 111;
	var NUMPAD_ENTER = 108;
	var NUMPAD_MULTIPLY = 106;
	var NUMPAD_SUBTRACT = 109;

	@:op(A<=B) private static inline function lessEq (lhs:Key, rhs:Int):Bool { return lhs <= rhs; }
	@:op(A<=B) private static inline function lessEq2 (lhs:Int, rhs:Key):Bool { return lhs <= rhs; }
	@:op(A>=B) private static inline function moreEq (lhs:Int, rhs:Key):Bool { return lhs >= rhs; }
	@:op(A>=B) private static inline function moreEq2 (lhs:Int, rhs:Key):Bool { return lhs >= rhs; }
	@:op(A-B) private static inline function sub (lhs:Key, rhs:Int):Int { return lhs - rhs; }
	@:op(A-B) private static inline function sub2 (lhs:Int, rhs:Key):Int { return lhs - rhs; }
}
