package haxepunk.input;

/**
 * List of keys to be used with `Input`.
 */
class Key
{
	public static inline var ANY = -1;

	public static inline var LEFT = 37;
	public static inline var UP = 38;
	public static inline var RIGHT = 39;
	public static inline var DOWN = 40;

	public static inline var ENTER = 13;
	public static inline var COMMAND = 15;
	public static inline var CONTROL = 17;
	public static inline var SPACE = 32;
	public static inline var SHIFT = 16;
	public static inline var BACKSPACE = 8;
	public static inline var CAPS_LOCK = 20;
	public static inline var DELETE = 46;
	public static inline var END = 35;
	public static inline var ESCAPE = 27;
	public static inline var HOME = 36;
	public static inline var INSERT = 45;
	public static inline var TAB = 9;
	public static inline var PAGE_DOWN = 34;
	public static inline var PAGE_UP = 33;
	public static inline var LEFT_SQUARE_BRACKET = 219;
	public static inline var RIGHT_SQUARE_BRACKET = 221;
	public static inline var TILDE = 192;

	public static inline var A = 65;
	public static inline var B = 66;
	public static inline var C = 67;
	public static inline var D = 68;
	public static inline var E = 69;
	public static inline var F = 70;
	public static inline var G = 71;
	public static inline var H = 72;
	public static inline var I = 73;
	public static inline var J = 74;
	public static inline var K = 75;
	public static inline var L = 76;
	public static inline var M = 77;
	public static inline var N = 78;
	public static inline var O = 79;
	public static inline var P = 80;
	public static inline var Q = 81;
	public static inline var R = 82;
	public static inline var S = 83;
	public static inline var T = 84;
	public static inline var U = 85;
	public static inline var V = 86;
	public static inline var W = 87;
	public static inline var X = 88;
	public static inline var Y = 89;
	public static inline var Z = 90;

	public static inline var F1 = 112;
	public static inline var F2 = 113;
	public static inline var F3 = 114;
	public static inline var F4 = 115;
	public static inline var F5 = 116;
	public static inline var F6 = 117;
	public static inline var F7 = 118;
	public static inline var F8 = 119;
	public static inline var F9 = 120;
	public static inline var F10 = 121;
	public static inline var F11 = 122;
	public static inline var F12 = 123;
	public static inline var F13 = 124;
	public static inline var F14 = 125;
	public static inline var F15 = 126;

	public static inline var DIGIT_0 = 48;
	public static inline var DIGIT_1 = 49;
	public static inline var DIGIT_2 = 50;
	public static inline var DIGIT_3 = 51;
	public static inline var DIGIT_4 = 52;
	public static inline var DIGIT_5 = 53;
	public static inline var DIGIT_6 = 54;
	public static inline var DIGIT_7 = 55;
	public static inline var DIGIT_8 = 56;
	public static inline var DIGIT_9 = 57;

	public static inline var NUMPAD_0 = 96;
	public static inline var NUMPAD_1 = 97;
	public static inline var NUMPAD_2 = 98;
	public static inline var NUMPAD_3 = 99;
	public static inline var NUMPAD_4 = 100;
	public static inline var NUMPAD_5 = 101;
	public static inline var NUMPAD_6 = 102;
	public static inline var NUMPAD_7 = 103;
	public static inline var NUMPAD_8 = 104;
	public static inline var NUMPAD_9 = 105;
	public static inline var NUMPAD_ADD = 107;
	public static inline var NUMPAD_DECIMAL = 110;
	public static inline var NUMPAD_DIVIDE = 111;
	public static inline var NUMPAD_ENTER = 108;
	public static inline var NUMPAD_MULTIPLY = 106;
	public static inline var NUMPAD_SUBTRACT = 109;

	/**
	 * Returns the name of the key.
	 * @param	char		The key to name.
	 * @return	The name.
	 */
	public static function nameOfKey(char:Int):String
	{
		if (char == -1) return "";
		
		if (char >= A && char <= Z) return String.fromCharCode(char);
		if (char >= F1 && char <= F15) return "F" + Std.string(char - 111);
		if (char >= 96 && char <= 105) return "NUMPAD " + Std.string(char - 96);
		switch (char)
		{
			case LEFT:  return "LEFT";
			case UP:    return "UP";
			case RIGHT: return "RIGHT";
			case DOWN:  return "DOWN";
			
			case LEFT_SQUARE_BRACKET: return "{";
			case RIGHT_SQUARE_BRACKET: return "}";
			case TILDE: return "~";

			case ENTER:     return "ENTER";
			case CONTROL:   return "CONTROL";
			case SPACE:     return "SPACE";
			case SHIFT:     return "SHIFT";
			case BACKSPACE: return "BACKSPACE";
			case CAPS_LOCK: return "CAPS LOCK";
			case DELETE:    return "DELETE";
			case END:       return "END";
			case ESCAPE:    return "ESCAPE";
			case HOME:      return "HOME";
			case INSERT:    return "INSERT";
			case TAB:       return "TAB";
			case PAGE_DOWN: return "PAGE DOWN";
			case PAGE_UP:   return "PAGE UP";

			case NUMPAD_ADD:      return "NUMPAD ADD";
			case NUMPAD_DECIMAL:  return "NUMPAD DECIMAL";
			case NUMPAD_DIVIDE:   return "NUMPAD DIVIDE";
			case NUMPAD_ENTER:    return "NUMPAD ENTER";
			case NUMPAD_MULTIPLY: return "NUMPAD MULTIPLY";
			case NUMPAD_SUBTRACT: return "NUMPAD SUBTRACT";
		}
		return String.fromCharCode(char);
	}
}
