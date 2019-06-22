package haxepunk.input;

import haxepunk.HXP;

@:enum
abstract MouseButton(Int) from Int to Int
{
	var LEFT = 0;
	var RIGHT = 1;
	var MIDDLE = 2;
}

class Mouse
{
	@:access(haxepunk.App)
	public static function init(){
		var mouse = kha.input.Mouse.get();

		mouse.notify(
			// Mouse Down
			function(button:Int, x:Int, y:Int)
			{
				Mouse._mouseOnScreen = true;
				App._mouseX = x;
				App._mouseY = y;
				switch(button)
				{
					case LEFT: onMouseDown();
					case RIGHT: onRightMouseDown();
					case MIDDLE: onMiddleMouseDown();
				}

			},
			// Mouse Up
			function(button:Int, x:Int, y:Int)
			{
				Mouse._mouseOnScreen = true;
				App._mouseX = x;
				App._mouseY = y;
				switch(button)
				{
					case LEFT: onMouseUp();
					case RIGHT: onRightMouseUp();
					case MIDDLE: onMiddleMouseUp();
				}
			},
			// Mouse Move
			function(x:Int, y:Int, _, _) 
			{
				Mouse._mouseOnScreen = true;
				App._mouseX = x;
				App._mouseY = y;
			},
			// Mouse wheel
			onMouseWheel,
			// Mouse leave
			() -> Mouse._mouseOnScreen = false
		);	
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
	 * If the mouse is current over the window. If not, the mouse coordinates
	 * will show the last position before the mouse was moved out.
	 */
	public static var mouseOnScreen(get, never):Bool;
	static inline function get_mouseOnScreen() return _mouseOnScreen;

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
	public static inline function showCursor()
	{
		kha.input.Mouse.get().showSystemCursor();
	}

	/**
	 * Hides the native cursor
	 */
	public static inline function hideCursor()
	{
		kha.input.Mouse.get().hideSystemCursor();
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

	static function onMouseDown()
	{
		if (!mouseDown)
		{
			mouseDown = true;
			mouseUp = false;
			mousePressed = true;
			if (_buttonMap.exists(MouseButton.LEFT)) for (input in _buttonMap[MouseButton.LEFT]) Input.triggerPress(input);
		}
	}

	static function onMouseUp()
	{
		mouseDown = false;
		mouseUp = true;
		mouseReleased = true;
		if (_buttonMap.exists(MouseButton.LEFT)) for (input in _buttonMap[MouseButton.LEFT]) Input.triggerRelease(input);
	}

	static function onMouseWheel(delta:Int)
	{
		mouseWheel = true;
		_mouseWheelDelta = delta;
	}

	static function onMiddleMouseDown()
	{
		if (!middleMouseDown)
		{
			middleMouseDown = true;
			middleMouseUp = false;
			middleMousePressed = true;
			if (_buttonMap.exists(MouseButton.MIDDLE)) for (input in _buttonMap[MouseButton.MIDDLE]) Input.triggerPress(input);
		}
	}

	static function onMiddleMouseUp()
	{
		middleMouseDown = false;
		middleMouseUp = true;
		middleMouseReleased = true;
		if (_buttonMap.exists(MouseButton.MIDDLE)) for (input in _buttonMap[MouseButton.MIDDLE]) Input.triggerRelease(input);
	}

	static function onRightMouseDown()
	{
		if (!rightMouseDown)
		{
			rightMouseDown = true;
			rightMouseUp = false;
			rightMousePressed = true;
			if (_buttonMap.exists(MouseButton.RIGHT)) for (input in _buttonMap[MouseButton.RIGHT]) Input.triggerPress(input);
		}
	}

	static function onRightMouseUp()
	{
		rightMouseDown = false;
		rightMouseUp = true;
		rightMouseReleased = true;
		if (_buttonMap.exists(MouseButton.RIGHT)) for (input in _buttonMap[MouseButton.RIGHT]) Input.triggerRelease(input);
	}

	static var _control:Map<InputType, MouseButton> = new Map();
	static var _buttonMap:Map<MouseButton, Array<InputType>> = new Map();
	static var _mouseWheelDelta:Int = 0;
	static var _mouseOnScreen:Bool = true;
}
