package haxepunk.input;

import lime.InputHandler;
import haxepunk.HXP;

import lime.InputHandler.MouseButton;
import lime.helpers.Keys;

class Input
{

	/**
	 * Contains the string of the last keys pressed
	 */
	public static var keyString:String = "";

	/**
	 * Holds the last key pressed
	 */
	public static var lastKey:Int;

	/**
	 * If the left button mouse is held down
	 */
	public static var mouseDown:Bool;
	/**
	 * If the left button mouse is up
	 */
	public static var mouseUp:Bool;
	/**
	 * If the left button mouse was recently pressed
	 */
	public static var mousePressed:Bool;
	/**
	 * If the left button mouse was recently released
	 */
	public static var mouseReleased:Bool;

	/**
	 * If the right button mouse is held down
	 */
	public static var rightMouseDown:Bool;
	/**
	 * If the right button mouse is up
	 */
	public static var rightMouseUp:Bool;
	/**
	 * If the right button mouse was recently pressed
	 */
	public static var rightMousePressed:Bool;
	/**
	 * If the right button mouse was recently released
	 */
	public static var rightMouseReleased:Bool;

	/**
	 * If the middle button mouse is held down
	 */
	public static var middleMouseDown:Bool;
	/**
	 * If the middle button mouse is up
	 */
	public static var middleMouseUp:Bool;
	/**
	 * If the middle button mouse was recently pressed
	 */
	public static var middleMousePressed:Bool;
	/**
	 * If the middle button mouse was recently released
	 */
	public static var middleMouseReleased:Bool;

	/**
	 * X position of the mouse on the screen.
	 */
	public static var mouseX(get, never):Int;
	private static function get_mouseX():Int
	{
		return input.last_mouse_x;
	}

	/**
	 * Y position of the mouse on the screen.
	 */
	public static var mouseY(get, never):Int;
	private static function get_mouseY():Int
	{
		return input.last_mouse_y;
	}

	/**
	 * Defines a new input.
	 * @param	name		String to map the input to.
	 * @param	keys		The keys to use for the Input.
	 */
	public static function define(name:String, keys:Array<Int>)
	{
		_control.set(name, keys);
	}

	/**
	 * If the input or key is held down.
	 * @param	input		An input name or key to check for.
	 * @return	True or false.
	 */
	public static function check(input:Dynamic):Bool
	{
		if (Std.is(input, String))
		{
#if debug
			if (!_control.exists(input))
			{
				return false;
			}
#end
			var v:Array<Int> = _control.get(input),
				i:Int = v.length;
			while (i-- > 0)
			{
				if (v[i] < 0)
				{
					if (_keyNum > 0) return true;
					continue;
				}
				if (_key[v[i]] == true) return true;
			}
			return false;
		}

		return input < 0 ? _keyNum > 0 : _key.get(input);
	}


	/**
	 * If the input or key was pressed this frame.
	 * @param	input		An input name or key to check for.
	 * @return	True or false.
	 */
	public static function pressed(input:Dynamic):Bool
	{
		if (Std.is(input, String) && _control.exists(input))
		{
			var v:Array<Int> = _control.get(input),
				i:Int = v.length;
			while (i-- > 0)
			{
				if ((v[i] < 0) ? _pressNum != 0 : HXP.indexOf(_press, v[i]) >= 0) return true;
			}
			return false;
		}
		return (input < 0) ? _pressNum != 0 : HXP.indexOf(_press, input) >= 0;
	}

	/**
	 * If the input or key was released this frame.
	 * @param	input		An input name or key to check for.
	 * @return	True or false.
	 */
	public static function released(input:Dynamic):Bool
	{
		if (Std.is(input, String))
		{
			var v:Array<Int> = _control.get(input),
				i:Int = v.length;
			while (i-- > 0)
			{
				if ((v[i] < 0) ? _releaseNum != 0 : HXP.indexOf(_release, v[i]) >= 0) return true;
			}
			return false;
		}
		return (input < 0) ? _releaseNum != 0 : HXP.indexOf(_release, input) >= 0;
	}


	public static function onkeydown(_event:Dynamic)
	{
		var code:Int = _event.value;
		
		if (code==Key.CAPS_LOCK)
			capsLock != capsLock;

		lastKey = code;

		if (code == Key.BACKSPACE) keyString = keyString.substr(0, keyString.length - 1);
		else if ((code > 47 && code < 58) || (code > 64 && code < 91) || code == 32)
		{
			if (keyString.length > kKeyStringMax) keyString = keyString.substr(1);
			var char:String = String.fromCharCode(code);

		// TODO: Caps lock
			//if (e.shiftKey != #if flash  #else check(Key.CAPS_LOCK) #end)
			//	char = char.toUpperCase();
			//else char = char.toLowerCase();


			keyString += char;
		}
		if (!_key[code])
		{
			_key[code] = true;
			_keyNum++;
			_press[_pressNum++] = code;
		}
	}

	public static function onkeyup(_event:Dynamic)
	{
		var code:Int = _event.value;

		if (_key[code])
		{
			_key[code] = false;
			_keyNum--;
			_release[_releaseNum++] = code;
		}
	}

	/**
	 * Lime onmousemove event
	 */
	public static function onmousemove(_event:Dynamic)
	{

	}

	/**
	 * Lime onmousedown event
	 */
	public static function onmousedown(_event:Dynamic)
	{
		switch (_event.button) {
			case MouseButton.left:
				mousePressed = true;
				mouseDown = true;
				mouseUp = false;
			case MouseButton.right:
				rightMouseDown = true;
				rightMouseUp = false;
				rightMousePressed = true;
			case MouseButton.middle:
				middleMouseDown = true;
				middleMouseUp = false;
				middleMousePressed = true;
		}
	}

	/**
	 * Lime onmouseup event
	 */
	public static function onmouseup(_event:Dynamic)
	{
		switch (_event.button) {
			case MouseButton.left:
				mouseReleased = true;
				mouseDown = false;
				mouseUp = true;
			case MouseButton.right:
				rightMouseDown = false;
				rightMouseUp = true;
				rightMouseReleased = true;
			case MouseButton.middle:
				middleMouseDown = false;
				middleMouseUp = true;
				middleMouseReleased = true;
		}
	}

	/**
	 * Enables input handling
	 */
	public static function init()
	{
		if (HXP.lime != null && HXP.lime.input != null)
		{
			input = HXP.lime.input;
		
			mouseDown 			= false;
			mouseUp 			= false;
			mousePressed 		= false;
			mouseReleased 		= false;
			rightMouseDown 		= false;
			rightMouseUp 		= false;
			rightMousePressed 	= false;
			rightMouseReleased 	= false;
			middleMouseDown 	= false;
			middleMouseUp 		= false;
			middleMousePressed 	= false;
			middleMouseReleased = false;
		}
	#if debug
		else
		{
			trace ("HXP.lime or HXP.lime.input are not yet specified.");
		}
	#end
	}

	/**
	 * Updates the input states
	 */
	public static function update()
	{
		while (_pressNum-- > -1) _press[_pressNum] = -1;
		_pressNum = 0;
		while (_releaseNum-- > -1) _release[_releaseNum] = -1;
		_releaseNum = 0;

		if (mousePressed) mousePressed = false;
		if (mouseReleased) mouseReleased = false;

		if (middleMousePressed) middleMousePressed = false;
		if (middleMouseReleased) middleMouseReleased = false;

		if (rightMousePressed) rightMousePressed = false;
		if (rightMouseReleased) rightMouseReleased = false;
	}

	// Lime input handler
	private static var input:InputHandler;

	private static inline var kKeyStringMax = 100;

//	private static var _touchNum:Int = 0;
	private static var _key:Map<Int, Bool> = new Map<Int, Bool>();
	private static var _keyNum:Int = 0;
	private static var _press:Array<Int> = new Array<Int>();
	private static var _pressNum:Int = 0;
	private static var _release:Array<Int> = new Array<Int>();
	private static var _releaseNum:Int = 0;
//	private static var _mouseWheelDelta:Int = 0;
//	private static var _touches:Map<Int,Touch> = new Map<Int,Touch>();
//	private static var _joysticks:Map<Int,Joystick> = new Map<Int,Joystick>();
	private static var _control:Map<String,Array<Int>> = new Map<String,Array<Int>>();
//	private static var _nativeCorrection:Map<String, Int> = new Map<String, Int>();

	public static var capsLock:Bool = false;
}