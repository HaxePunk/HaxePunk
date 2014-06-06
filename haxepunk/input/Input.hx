package haxepunk.input;

import lime.InputHandler;
import haxepunk.HXP;

import lime.InputHandler.MouseButton;

class Input
{

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
		if (mousePressed) mousePressed = false;
		if (mouseReleased) mouseReleased = false;

		if (middleMousePressed) middleMousePressed = false;
		if (middleMouseReleased) middleMouseReleased = false;

		if (rightMousePressed) rightMousePressed = false;
		if (rightMouseReleased) rightMouseReleased = false;
	}

	// Lime input handler
	private static var input:InputHandler;
}