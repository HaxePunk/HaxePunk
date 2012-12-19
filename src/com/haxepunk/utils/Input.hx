package com.haxepunk.utils;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.ui.Mouse;
import com.haxepunk.HXP;
#if (nme && (cpp || neko))
import nme.events.JoystickEvent;
#end

class Input
{

	public static var keyString:String = "";
	public static var deadZone:Float = 0.05; //joystick deadzone

	public static var lastKey:Int;

	public static var mouseCursor:String = "";

	public static var mouseDown:Bool;
	public static var mouseUp:Bool;
	public static var mousePressed:Bool;
	public static var mouseReleased:Bool;
	public static var mouseWheel:Bool;

	public static var mouseWheelDelta(getMouseWheelDelta, null):Int;
	private static function getMouseWheelDelta():Int
	{
		if (mouseWheel)
		{
			mouseWheel = false;
			return _mouseWheelDelta;
		}
		return 0;
	}

	/**
	 * X position of the mouse on the screen.
	 */
	public static var mouseX(getMouseX, null):Int;
	private static function getMouseX():Int
	{
		return HXP.screen.mouseX;
	}

	/**
	 * Y position of the mouse on the screen.
	 */
	public static var mouseY(getMouseY, null):Int;
	private static function getMouseY():Int
	{
		return HXP.screen.mouseY;
	}

	/**
	 * The absolute mouse x position on the screen (unscaled).
	 */
	public static var mouseFlashX(getMouseFlashX, null):Int;
	private static function getMouseFlashX():Int
	{
		return Std.int(HXP.stage.mouseX);
	}

	/**
	 * The absolute mouse y position on the screen (unscaled).
	 */
	public static var mouseFlashY(getMouseFlashY, null):Int;
	private static function getMouseFlashY():Int
	{
		return Std.int(HXP.stage.mouseY);
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
		return input < 0 ? _keyNum > 0 : _key[input];
	}

	/**
	 * If the input or key was pressed this frame.
	 * @param	input		An input name or key to check for.
	 * @return	True or false.
	 */
	public static function pressed(input:Dynamic):Bool
	{
		if (Std.is(input, String))
		{
			var v:Array<Int> = _control.get(input),
				i:Int = v.length;
			while (i-- > 0)
			{
				if ((v[i] < 0) ? _pressNum != 0 : indexOf(_press, v[i]) >= 0) return true;
			}
			return false;
		}
		return (input < 0) ? _pressNum != 0 : indexOf(_press, input) >= 0;
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
				if ((v[i] < 0) ? _releaseNum != 0 : indexOf(_release, v[i]) >= 0) return true;
			}
			return false;
		}
		return (input < 0) ? _releaseNum != 0 : indexOf(_release, input) >= 0;
	}

	/**
	 * Copy of Lambda.indexOf for speed/memory reasons
	 * @param	a array to use
	 * @param	v value to find index of
	 * @return	index of value in the array
	 */
	private static function indexOf(a:Array<Int>, v:Int):Int
	{
		var i = 0;
		for( v2 in a ) {
			if( v == v2 )
				return i;
			i++;
		}
		return -1;
	}

	public static function joystick(id:Int)
	{
		var joy:Joystick = _joysticks.get(id);
		if (joy == null)
		{
			joy = new Joystick();
			_joysticks.set(id, joy);
		}
		return joy;
	}

	public static function enable()
	{
		if (!_enabled && HXP.stage != null)
		{
			HXP.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false,  2);
			HXP.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false,  2);
			HXP.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false,  2);
			HXP.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false,  2);
			HXP.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel, false,  2);
			HXP.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false,  2);

#if (nme && (cpp || neko))
			HXP.stage.addEventListener(JoystickEvent.AXIS_MOVE, onJoyAxisMove);
			HXP.stage.addEventListener(JoystickEvent.BALL_MOVE, onJoyBallMove);
			HXP.stage.addEventListener(JoystickEvent.BUTTON_DOWN, onJoyButtonDown);
			HXP.stage.addEventListener(JoystickEvent.BUTTON_UP, onJoyButtonUp);
			HXP.stage.addEventListener(JoystickEvent.HAT_MOVE, onJoyHatMove);
#end

			_enabled = true;
		}
	}

	public static function update()
	{
		while (_pressNum-- > -1) _press[_pressNum] = -1;
		_pressNum = 0;
		while (_releaseNum-- > -1) _release[_releaseNum] = -1;
		_releaseNum = 0;
		if (mousePressed) mousePressed = false;
		if (mouseReleased) mouseReleased = false;

		if (mouseCursor != "")
		{
			if (mouseCursor == "hide")
			{
				if (_mouseVisible) Mouse.hide();
				_mouseVisible = false;
			}
			else
			{
				if (!_mouseVisible) Mouse.show();
#if flash
				if (Mouse.cursor != mouseCursor) Mouse.cursor = mouseCursor;
#end
				_mouseVisible = true;
			}
		}
	}

	/**
	 * Clears all input states
	 */
	public static function clear()
	{
		HXP.clear(_press);
		_pressNum = 0;
		HXP.clear(_release);
		_releaseNum = 0;
		HXP.clear(_key);
		_keyNum = 0;
	}

	/** @private Event handler for key press. */
	private static function onKeyDown(e:KeyboardEvent = null)
	{
		var code:Int = lastKey = e.keyCode;

		if (code < 0 || code > 255) return;

		if (code == Key.BACKSPACE) keyString = keyString.substr(0, keyString.length - 1);
		else if ((code > 47 && code < 58) || (code > 64 && code < 91) || code == 32)
		{
			if (keyString.length > kKeyStringMax) keyString = keyString.substr(1);
			var char:String = String.fromCharCode(code);
#if flash
			if (e.shiftKey || Keyboard.capsLock) char = char.toUpperCase();
			else char = char.toLowerCase();
#end
			keyString += char;
		}

		if (!_key[code])
		{
			_key[code] = true;
			_keyNum++;
			_press[_pressNum++] = code;
		}
	}

	private static function onKeyUp(e:KeyboardEvent = null)
	{
		var code:Int = e.keyCode;

		if (code < 0 || code > 255) return;

		if (_key[code])
		{
			_key[code] = false;
			_keyNum--;
			_release[_releaseNum++] = code;
		}
	}

	private static function onMouseDown(e:MouseEvent)
	{
		if (!mouseDown)
		{
			mouseDown = true;
			mouseUp = false;
			mousePressed = true;
		}
	}

	private static function onMouseUp(e:MouseEvent)
	{
		mouseDown = false;
		mouseUp = true;
		mouseReleased = true;
	}

	private static function onMouseWheel(e:MouseEvent)
	{
		mouseWheel = true;
		_mouseWheelDelta = e.delta;
	}

	/** @private Event handler for mouse move events: only here for a bug workaround. */
	private static function onMouseMove(e:MouseEvent)
	{
		if (mouseCursor == "hide") {
			Mouse.show();
			Mouse.hide();
		}

		HXP.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	}

#if (nme && (cpp || neko))

	private static function onJoyAxisMove(e:JoystickEvent)
	{
		var joy:Joystick = joystick(e.device);

		joy.connected = true;
		joy.axis.x = (Math.abs(e.x) < deadZone) ? 0 : e.x;
		joy.axis.y = (Math.abs(e.y) < deadZone) ? 0 : e.y;
	}

	private static function onJoyBallMove(e:JoystickEvent)
	{
		var joy:Joystick = joystick(e.device);

		joy.connected = true;
		joy.ball.x = (Math.abs(e.x) < deadZone) ? 0 : e.x;
		joy.ball.y = (Math.abs(e.y) < deadZone) ? 0 : e.y;
	}

	private static function onJoyButtonDown(e:JoystickEvent)
	{
		var joy:Joystick = joystick(e.device);

		joy.connected = true;
		if (e.id < 8)
			joy.buttons[e.id] = true;
	}

	private static function onJoyButtonUp(e:JoystickEvent)
	{
		var joy:Joystick = joystick(e.device);

		joy.connected = true;
		if (e.id < 8)
			joy.buttons[e.id] = false;
	}

	private static function onJoyHatMove(e:JoystickEvent)
	{
		var joy:Joystick = joystick(e.device);

		joy.connected = true;
		joy.hat.x = (Math.abs(e.x) < deadZone) ? 0 : e.x;
		joy.hat.y = (Math.abs(e.y) < deadZone) ? 0 : e.y;
	}

#end

	private static inline var kKeyStringMax = 100;

	private static var _enabled:Bool = false;

	private static var _joysticks:IntHash<Joystick> = new IntHash<Joystick>();

	private static var _key:Array<Bool> = new Array<Bool>();
	private static var _keyNum:Int = 0;
	private static var _press:Array<Int> = new Array<Int>();
	private static var _pressNum:Int = 0;
	private static var _release:Array<Int> = new Array<Int>();
	private static var _releaseNum:Int = 0;
	private static var _control:Hash<Array<Int>> = new Hash<Array<Int>>();

	private static var _mouseWheelDelta:Int = 0;
	private static var _mouseVisible:Bool = true;
}