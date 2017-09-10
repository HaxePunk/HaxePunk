package haxepunk.input;

import flash.events.MouseEvent;
import flash.ui.Mouse as FlashMouse;
import haxepunk.HXP;

@:enum
abstract MouseButton(Int) from Int to Int
{
	var LEFT = 1;
	var RIGHT = 2;
	var MIDDLE = 3;
}

class Mouse
{
	public static function init()
	{
		HXP.engine.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false,  2);
		HXP.engine.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false,  2);
		HXP.engine.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel, false,  2);
		HXP.engine.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseDown, false, 2);
		HXP.engine.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMiddleMouseUp, false, 2);
		HXP.engine.stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown, false, 2);
		HXP.engine.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onRightMouseUp, false, 2);
	}

	/**
	 * X position of the mouse on the screen.
	 */
	public static var mouseX(get, never):Int;
	static function get_mouseX():Int
	{
		return HXP.screen.mouseX;
	}

	/**
	 * Y position of the mouse on the screen.
	 */
	public static var mouseY(get, never):Int;
	static function get_mouseY():Int
	{
		return HXP.screen.mouseY;
	}

	/**
	 * The absolute mouse x position on the screen (unscaled).
	 */
	public static var mouseFlashX(get, never):Int;
	static function get_mouseFlashX():Int
	{
		return Std.int(HXP.engine.mouseX - HXP.screen.x);
	}

	/**
	 * The absolute mouse y position on the screen (unscaled).
	 */
	public static var mouseFlashY(get, never):Int;
	static function get_mouseFlashY():Int
	{
		return Std.int(HXP.engine.mouseY - HXP.screen.y);
	}

	/**
	 * If the left button mouse is held down
	 */
	public static var mouseDown:Bool = false;
	/**
	 * If the left button mouse is up
	 */
	public static var mouseUp:Bool = false;
	/**
	 * If the left button mouse was recently pressed
	 */
	public static var mousePressed:Bool = false;
	/**
	 * If the left button mouse was recently released
	 */
	public static var mouseReleased:Bool = false;

	/**
	 * If the right button mouse is held down.
	 */
	public static var rightMouseDown:Bool = false;
	/**
	 * If the right button mouse is up.
	 */
	public static var rightMouseUp:Bool = false;
	/**
	 * If the right button mouse was recently pressed.
	 */
	public static var rightMousePressed:Bool = false;
	/**
	 * If the right button mouse was recently released.
	 */
	public static var rightMouseReleased:Bool = false;

	/**
	 * If the middle button mouse is held down.
	 */
	public static var middleMouseDown:Bool = false;
	/**
	 * If the middle button mouse is up.
	 */
	public static var middleMouseUp:Bool = false;
	/**
	 * If the middle button mouse was recently pressed.
	 */
	public static var middleMousePressed:Bool = false;
	/**
	 * If the middle button mouse was recently released.
	 */
	public static var middleMouseReleased:Bool = false;

	/**
	 * If the mouse wheel has moved
	 */
	public static var mouseWheel:Bool = false;

	/**
	 * If the mouse wheel was moved this frame, this was the delta.
	 */
	public static var mouseWheelDelta(get, never):Int;
	static function get_mouseWheelDelta():Int
	{
		if (mouseWheel)
		{
			mouseWheel = false;
			return _mouseWheelDelta;
		}
		return 0;
	}

	/**
	 * Shows the native cursor
	 */
	public static function showCursor()
	{
		FlashMouse.show();
	}

	/**
	 * Hides the native cursor
	 */
	public static function hideCursor()
	{
		FlashMouse.hide();
	}

	public static inline function define(input:InputType, button:MouseButton)
	{
		// undefine any pre-existing key mappings
		if (_control.exists(input))
		{
			_buttonMap[button].remove(input);
		}
		_control.set(input, button);
		if (!_buttonMap.exists(button)) _buttonMap[button] = new Array();
		if (_buttonMap[button].indexOf(input) < 0) _buttonMap[button].push(input);
	}

	public static function checkInput(input:InputType)
	{
		if (_control.exists(input))
		{
			if (check(_control[input])) return true;
		}
		return false;
	}

	public static function pressedInput(input:InputType)
	{
		if (_control.exists(input))
		{
			if (pressed(_control[input])) return true;
		}
		return false;
	}

	public static function releasedInput(input:InputType)
	{
		if (_control.exists(input))
		{
			if (released(_control[input])) return true;
		}
		return false;
	}

	static inline function check(btn:MouseButton) return switch (btn)
	{
		case LEFT: mouseDown;
		case RIGHT: rightMouseDown;
		case MIDDLE: middleMouseDown;
	}

	static inline function pressed(btn:MouseButton) return switch (btn)
	{
		case LEFT: mousePressed;
		case RIGHT: rightMousePressed;
		case MIDDLE: middleMousePressed;
	}

	static inline function released(btn:MouseButton) return switch (btn)
	{
		case LEFT: mouseReleased;
		case RIGHT: rightMouseReleased;
		case MIDDLE: middleMouseReleased;
	}

	public static function update() {}

	public static function postUpdate()
	{
		mousePressed = mouseReleased = middleMousePressed = middleMouseReleased = rightMousePressed = rightMouseReleased = false;
	}

	static function onMouseDown(e:MouseEvent)
	{
		if (!mouseDown)
		{
			mouseDown = true;
			mouseUp = false;
			mousePressed = true;
			if (_buttonMap.exists(MouseButton.LEFT)) for (input in _buttonMap[MouseButton.LEFT]) Input.triggerPress(input);
		}
	}

	static function onMouseUp(e:MouseEvent)
	{
		mouseDown = false;
		mouseUp = true;
		mouseReleased = true;
		if (_buttonMap.exists(MouseButton.LEFT)) for (input in _buttonMap[MouseButton.LEFT]) Input.triggerRelease(input);
	}

	static function onMouseWheel(e:MouseEvent)
	{
		mouseWheel = true;
		_mouseWheelDelta = e.delta;
	}

	static function onMiddleMouseDown(e:MouseEvent)
	{
		if (!middleMouseDown)
		{
			middleMouseDown = true;
			middleMouseUp = false;
			middleMousePressed = true;
			if (_buttonMap.exists(MouseButton.MIDDLE)) for (input in _buttonMap[MouseButton.MIDDLE]) Input.triggerPress(input);
		}
	}

	static function onMiddleMouseUp(e:MouseEvent)
	{
		middleMouseDown = false;
		middleMouseUp = true;
		middleMouseReleased = true;
		if (_buttonMap.exists(MouseButton.MIDDLE)) for (input in _buttonMap[MouseButton.MIDDLE]) Input.triggerRelease(input);
	}

	static function onRightMouseDown(e:MouseEvent)
	{
		if (!rightMouseDown)
		{
			rightMouseDown = true;
			rightMouseUp = false;
			rightMousePressed = true;
			if (_buttonMap.exists(MouseButton.RIGHT)) for (input in _buttonMap[MouseButton.RIGHT]) Input.triggerPress(input);
		}
	}

	static function onRightMouseUp(e:MouseEvent)
	{
		rightMouseDown = false;
		rightMouseUp = true;
		rightMouseReleased = true;
		if (_buttonMap.exists(MouseButton.RIGHT)) for (input in _buttonMap[MouseButton.RIGHT]) Input.triggerRelease(input);
	}

	static var _control:Map<InputType, MouseButton> = new Map();
	static var _buttonMap:Map<MouseButton, Array<InputType>> = new Map();
	static var _mouseWheelDelta:Int = 0;
}
