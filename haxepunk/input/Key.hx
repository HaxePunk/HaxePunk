package haxepunk.input;

/**
 * List of keys to be used with `Input`.
 */
typedef KeyCode = kha.input.KeyCode;

class Key
{
	/**
	 * Contains the string of the last keys pressed
	 */
	public static var keyString:String = "";

	/**
	 * Holds the last key pressed
	 */
	public static var lastKey:KeyCode;

	public static var ANY:Int = -1;

	/**
	 * Returns the name of the key.
	 * @param	char		The key to name.
	 * @return	The name.
	 */
	// TODO : build with macro probably
	public static function nameOfKey(char:Int):String
	{
		return "";
	}

	public static inline function define(input:InputType, keys:Array<KeyCode>)
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

	public static inline function check(key:Int):Bool
	{
		return ((key < 0 && _keyNum > 0) || _key.get(key));
	}

	public static inline function pressed(key:Int):Bool
	{
		return (key < 0 ? _pressNum != 0 : HXP.indexOf(_press, key) >= 0);
	}

	public static inline function released(key:Int):Bool
	{
		return (key < 0 ? _releaseNum != 0 : HXP.indexOf(_release, key) >= 0);
	}

	public static function update() {}

	public static function postUpdate()
	{
		while (_pressNum > 0) _press[--_pressNum] = -1;
		while (_releaseNum > 0) _release[--_releaseNum] = -1;
	}

	@:allow(haxepunk.App)
	static function onKeyDown(code:KeyCode)
	{
		lastKey = code;

		if (code == KeyCode.Backspace) keyString = keyString.substr(0, keyString.length - 1);

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

	@:allow(haxepunk.App)
	static function onKeyUp(code:KeyCode)
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

	@:allow(haxepunk.App)
	static function onCharacter(char:String)
	{
		if(keyString.length >= kKeyStringMax)
			keyString = keyString.substr(1);
		keyString += char;
	}

	static inline var kKeyStringMax = 100;
	static var _key:Map<Int, Bool> = new Map<Int, Bool>();
	static var _keyNum:Int = 0;
	static var _press:Array<Int> = new Array<Int>();
	static var _pressNum:Int = 0;
	static var _release:Array<Int> = new Array<Int>();
	static var _releaseNum:Int = 0;
	static var _control:Map<InputType, Array<KeyCode>> = new Map();
	static var _keyMap:Map<Int, Array<InputType>> = new Map();
}
