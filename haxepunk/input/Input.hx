package haxepunk.input;

import haxepunk.HXP;
import lime.ui.*;

class Input implements IMouseEventListener// implements IKeyEventListener implements ITouchEventListener
{

	/**
	 * If the left button mouse is held down
	 */
	public var mouseDown:Bool;
	/**
	 * If the left button mouse is up
	 */
	public var mouseUp:Bool;
	/**
	 * If the left button mouse was recently pressed
	 */
	public var mousePressed:Bool;
	/**
	 * If the left button mouse was recently released
	 */
	public var mouseReleased:Bool;

	/**
	 * If the right button mouse is held down
	 */
	public var rightMouseDown:Bool;
	/**
	 * If the right button mouse is up
	 */
	public var rightMouseUp:Bool;
	/**
	 * If the right button mouse was recently pressed
	 */
	public var rightMousePressed:Bool;
	/**
	 * If the right button mouse was recently released
	 */
	public var rightMouseReleased:Bool;

	/**
	 * If the middle button mouse is held down
	 */
	public var middleMouseDown:Bool;
	/**
	 * If the middle button mouse is up
	 */
	public var middleMouseUp:Bool;
	/**
	 * If the middle button mouse was recently pressed
	 */
	public var middleMousePressed:Bool;
	/**
	 * If the middle button mouse was recently released
	 */
	public var middleMouseReleased:Bool;

	/**
	 * X position of the mouse on the screen.
	 */
	public var mouseX(default, null):Float;

	/**
	 * Y position of the mouse on the screen.
	 */
	public var mouseY(default, null):Float;


	/**
	 * Lime onmousemove event
	 */
	public function onMouseMove(x:Float, y:Float, button:Int)
	{
		mouseX = x;
		mouseY = y;
	}

	/**
	 * Lime onmousedown event
	 */
	public function onMouseDown(x:Float, y:Float, button:Int)
	{
		mouseX = x;
		mouseY = y;
		switch (button) {
			case 0:
				mousePressed = true;
				mouseDown = true;
				mouseUp = false;
			case 2:
				rightMouseDown = true;
				rightMouseUp = false;
				rightMousePressed = true;
			case 1:
				middleMouseDown = true;
				middleMouseUp = false;
				middleMousePressed = true;
		}
	}

	/**
	 * Lime onmouseup event
	 */
	public function onMouseUp(x:Float, y:Float, button:Int)
	{
		mouseX = x;
		mouseY = y;
		switch (button) {
			case 0:
				mouseReleased = true;
				mouseDown = false;
				mouseUp = true;
			case 2:
				rightMouseDown = false;
				rightMouseUp = true;
				rightMouseReleased = true;
			case 1:
				middleMouseDown = false;
				middleMouseUp = true;
				middleMouseReleased = true;
		}
	}

	/**
	 * Enables input handling
	 */
	public function new()
	{
		MouseEventManager.addEventListener(this);
		// KeyEventManager.addEventListener(this);
		// TouchEventManager.addEventListener(this);

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

	/**
	 * Updates the input states
	 */
	public function update()
	{
		if (mousePressed) mousePressed = false;
		if (mouseReleased) mouseReleased = false;

		if (middleMousePressed) middleMousePressed = false;
		if (middleMouseReleased) middleMouseReleased = false;

		if (rightMousePressed) rightMousePressed = false;
		if (rightMouseReleased) rightMouseReleased = false;
	}

}
