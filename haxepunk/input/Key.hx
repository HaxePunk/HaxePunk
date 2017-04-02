package haxepunk.input;

import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

/**
 * List of keys to be used with `Input`.
 */
@:enum
abstract Key(Int) from Int to Int
{
	/**
	 * Contains the string of the last keys pressed
	 */
	public static var keyString:String = "";

	/**
	 * Holds the last key pressed
	 */
	public static var lastKey:Int;

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

	@:op(A > B) static function gt(k1:Key, k2:Key):Bool;
	@:op(A >= B) static function gte(k1:Key, k2:Key):Bool;
	@:op(A < B) static function lt(k1:Key, k2:Key):Bool;
	@:op(A <= B) static function lte(k1:Key, k2:Key):Bool;
	@:op(A == B) static function eq(k1:Key, k2:Key):Bool;

	/**
	 * Returns the name of the key.
	 * @param	char		The key to name.
	 * @return	The name.
	 */
	public static function nameOfKey(char:Key):String
	{
		if (char == -1) return "";
		else if (char >= A && char <= Z) return String.fromCharCode(char);
		else if (char >= F1 && char <= F15) return "F" + Std.string(Std.int(char) - 111);
		else if (char >= NUMPAD_0 && char <= NUMPAD_9) return "NUMPAD " + Std.string(Std.int(char) - 96);
		else return switch (char)
		{
			case LEFT: "LEFT";
			case UP: "UP";
			case RIGHT: "RIGHT";
			case DOWN: "DOWN";

			case LEFT_SQUARE_BRACKET: "{";
			case RIGHT_SQUARE_BRACKET: "}";
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
			default: String.fromCharCode(char);
		}
	}

	public static function init()
	{
		HXP.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false,  2);
		HXP.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false,  2);
#if !(flash || js)
		_nativeCorrection.set("0_64", Key.INSERT);
		_nativeCorrection.set("0_65", Key.END);
		_nativeCorrection.set("0_66", Key.DOWN);
		_nativeCorrection.set("0_67", Key.PAGE_DOWN);
		_nativeCorrection.set("0_68", Key.LEFT);
		_nativeCorrection.set("0_69", -1);
		_nativeCorrection.set("0_70", Key.RIGHT);
		_nativeCorrection.set("0_71", Key.HOME);
		_nativeCorrection.set("0_72", Key.UP);
		_nativeCorrection.set("0_73", Key.PAGE_UP);
		_nativeCorrection.set("0_266", Key.DELETE);
		_nativeCorrection.set("123_222", Key.LEFT_SQUARE_BRACKET);
		_nativeCorrection.set("125_187", Key.RIGHT_SQUARE_BRACKET);
		_nativeCorrection.set("126_233", Key.TILDE);

		_nativeCorrection.set("0_80", Key.F1);
		_nativeCorrection.set("0_81", Key.F2);
		_nativeCorrection.set("0_82", Key.F3);
		_nativeCorrection.set("0_83", Key.F4);
		_nativeCorrection.set("0_84", Key.F5);
		_nativeCorrection.set("0_85", Key.F6);
		_nativeCorrection.set("0_86", Key.F7);
		_nativeCorrection.set("0_87", Key.F8);
		_nativeCorrection.set("0_88", Key.F9);
		_nativeCorrection.set("0_89", Key.F10);
		_nativeCorrection.set("0_90", Key.F11);

		_nativeCorrection.set("48_224", Key.DIGIT_0);
		_nativeCorrection.set("49_38", Key.DIGIT_1);
		_nativeCorrection.set("50_233", Key.DIGIT_2);
		_nativeCorrection.set("51_34", Key.DIGIT_3);
		_nativeCorrection.set("52_222", Key.DIGIT_4);
		_nativeCorrection.set("53_40", Key.DIGIT_5);
		_nativeCorrection.set("54_189", Key.DIGIT_6);
		_nativeCorrection.set("55_232", Key.DIGIT_7);
		_nativeCorrection.set("56_95", Key.DIGIT_8);
		_nativeCorrection.set("57_231", Key.DIGIT_9);

		_nativeCorrection.set("48_64", Key.NUMPAD_0);
		_nativeCorrection.set("49_65", Key.NUMPAD_1);
		_nativeCorrection.set("50_66", Key.NUMPAD_2);
		_nativeCorrection.set("51_67", Key.NUMPAD_3);
		_nativeCorrection.set("52_68", Key.NUMPAD_4);
		_nativeCorrection.set("53_69", Key.NUMPAD_5);
		_nativeCorrection.set("54_70", Key.NUMPAD_6);
		_nativeCorrection.set("55_71", Key.NUMPAD_7);
		_nativeCorrection.set("56_72", Key.NUMPAD_8);
		_nativeCorrection.set("57_73", Key.NUMPAD_9);
		_nativeCorrection.set("42_268", Key.NUMPAD_MULTIPLY);
		_nativeCorrection.set("43_270", Key.NUMPAD_ADD);
		//_nativeCorrection.set("", Key.NUMPAD_ENTER);
		_nativeCorrection.set("45_269", Key.NUMPAD_SUBTRACT);
		_nativeCorrection.set("46_266", Key.NUMPAD_DECIMAL); // point
		_nativeCorrection.set("44_266", Key.NUMPAD_DECIMAL); // comma
		_nativeCorrection.set("47_267", Key.NUMPAD_DIVIDE);
#end
	}

	public static inline function define(input:InputType, keys:Array<Key>)
	{
		// undefine any pre-existing key mappings
		if (_control.exists(input))
		{
			for (key in _control[input])
			{
				_keyMap[key].remove(input);
			}
		}
		_control.set(input, keys);
		for (key in keys)
		{
			if (!_keyMap.exists(key)) _keyMap[key] = new Array();
			if (_keyMap[key].indexOf(input) < 0) _keyMap[key].push(input);
		}
	}

	public static function checkInput(input:InputType)
	{
		if (_control.exists(input))
		{
			for (key in _control[input])
			{
				if (check(key)) return true;
			}
		}
		return false;
	}

	public static function pressedInput(input:InputType)
	{
		if (_control.exists(input))
		{
			for (key in _control[input])
			{
				if (pressed(key)) return true;
			}
		}
		return false;
	}

	public static function releasedInput(input:InputType)
	{
		if (_control.exists(input))
		{
			for (key in _control[input])
			{
				if (released(key)) return true;
			}
		}
		return false;
	}

	public static inline function check(key:Key):Bool
	{
		return ((key < 0 && _keyNum > 0) || _key.get(key));
	}

	public static inline function pressed(key:Key):Bool
	{
		return (key < 0 ? _pressNum != 0 : HXP.indexOf(_press, key) >= 0);
	}

	public static inline function released(key:Key):Bool
	{
		return (key < 0 ? _releaseNum != 0 : HXP.indexOf(_release, key) >= 0);
	}

	public static function update() {}

	public static function postUpdate()
	{
		while (_pressNum > 0) _press[--_pressNum] = -1;
		while (_releaseNum > 0) _release[--_releaseNum] = -1;
	}

	static function onKeyDown(?e:KeyboardEvent)
	{
		var code:Int = keyCode(e);
		if (code == -1) // No key
			return;

		lastKey = code;

		if (code == Key.BACKSPACE) keyString = keyString.substr(0, keyString.length - 1);
		else if ((code > 47 && code < 58) || (code > 64 && code < 91) || code == 32)
		{
			if (keyString.length > kKeyStringMax) keyString = keyString.substr(1);
			var char:String = String.fromCharCode(code);

			if (e.shiftKey != #if flash Keyboard.capsLock #else Key.check(Key.CAPS_LOCK) #end)
				char = char.toUpperCase();
			else char = char.toLowerCase();

			keyString += char;
		}

		if (!_key[code])
		{
			_key[code] = true;
			_keyNum++;
			_press[_pressNum++] = code;

			if (_keyMap.exists(code))
			{
				for (input in _keyMap[code])
				{
					Input.triggerPress(input);
				}
			}
		}
	}

	static function onKeyUp(?e:KeyboardEvent)
	{
		var code:Int = keyCode(e);
		if (code == -1) // No key
			return;

		if (_key[code])
		{
			_key[code] = false;
			_keyNum--;
			_release[_releaseNum++] = code;

			if (_keyMap.exists(code))
			{
				for (input in _keyMap[code])
				{
					Input.triggerRelease(input);
				}
			}
		}
	}

	static inline function keyCode(e:KeyboardEvent):Int
	{
	#if (flash || js)
		return e.keyCode;
	#else
		var code = _nativeCorrection.get(e.charCode + "_" + e.keyCode);
		return code == null ? e.keyCode : code;
	#end
	}

	static inline var kKeyStringMax = 100;
	static var _key:Map<Int, Bool> = new Map<Int, Bool>();
	static var _keyNum:Int = 0;
	static var _press:Array<Int> = new Array<Int>();
	static var _pressNum:Int = 0;
	static var _release:Array<Int> = new Array<Int>();
	static var _releaseNum:Int = 0;
	static var _nativeCorrection:Map<String, Int> = new Map<String, Int>();
	static var _control:Map<InputType, Array<Key>> = new Map();
	static var _keyMap:Map<Key, Array<InputType>> = new Map();
}
