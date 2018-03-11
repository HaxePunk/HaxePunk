package haxepunk._internal;

import flash.events.Event;
import flash.events.MouseEvent;
import haxepunk.input.Mouse;

@:access(haxepunk.input.Mouse)
class MouseInput
{
	public static function init(app:FlashApp)
	{
		var stage = app.stage;
		stage.addEventListener(MouseEvent.MOUSE_DOWN, Mouse.onMouseDown, false, 2);
		stage.addEventListener(MouseEvent.MOUSE_UP, Mouse.onMouseUp, false, 2);
		stage.addEventListener(MouseEvent.MOUSE_WHEEL, function(e:MouseEvent) {
			Mouse.onMouseWheel(e.delta);
		}, false, 2);
		stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, Mouse.onMiddleMouseDown, false, 2);
		stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, Mouse.onMiddleMouseUp, false, 2);
		stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, Mouse.onRightMouseDown, false, 2);
		stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, Mouse.onRightMouseUp, false, 2);

		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseOver, false, 2);
		stage.addEventListener(Event.MOUSE_LEAVE, onMouseOut, false, 2);
	}

	static function onMouseOver(_)
	{
		Mouse._mouseOnScreen = true;
	}

	static function onMouseOut(_)
	{
		Mouse._mouseOnScreen = false;
	}
}
