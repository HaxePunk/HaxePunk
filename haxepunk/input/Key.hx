package haxepunk.input;

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

	public static function checkInput(input:InputType):Bool
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

	public static function pressedInput(input:InputType):Bool
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

	public static function releasedInput(input:InputType):Bool
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

	public static function postUpdate()
	{
		while (_pressNum > 0) _press[--_pressNum] = -1;
		while (_releaseNum > 0) _release[--_releaseNum] = -1;
	}

	static function onKeyDown(code:Int, shift:Bool)
	{
		lastKey = code;

		if (code == Key.BACKSPACE) keyString = keyString.substr(0, keyString.length - 1);
		else if ((code > 47 && code < 58) || (code > 64 && code < 91) || code == 32)
		{
			if (keyString.length > kKeyStringMax) keyString = keyString.substr(1);
			var char:String = String.fromCharCode(code);

			if (shift != Key.check(Key.CAPS_LOCK))
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

	static function onKeyUp(code:Int)
	{
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

	static inline var kKeyStringMax = 100;
	static var _key:Map<Int, Bool> = new Map<Int, Bool>();
	static var _keyNum:Int = 0;
	static var _press:Array<Int> = new Array<Int>();
	static var _pressNum:Int = 0;
	static var _release:Array<Int> = new Array<Int>();
	static var _releaseNum:Int = 0;
	static var _control:Map<InputType, Array<Key>> = new Map();
	static var _keyMap:Map<Key, Array<InputType>> = new Map();
}

// can't use abstract for the handler so we pass it through this class
class Handler
{
	public static function update() {}

	public static function postUpdate()
	{
		Key.postUpdate();
	}

	public static function checkInput(input:InputType):Bool
	{
		return Key.checkInput(input);
	}

	public static function pressedInput(input:InputType):Bool
	{
		return Key.pressedInput(input);
	}

	public static function releasedInput(input:InputType):Bool
	{
		return Key.releasedInput(input);
	}
}
