package haxepunk._internal;

import nme.events.JoystickEvent;
import haxepunk.input.Gamepad;
import haxepunk.input.Input;

@:access(haxepunk.input.Gamepad)
class GamepadInput
{
	public static function init(app:App)
	{
		var stage = app.stage;
		stage.addEventListener(JoystickEvent.AXIS_MOVE, onJoyAxisMove);
		stage.addEventListener(JoystickEvent.BUTTON_DOWN, onJoyButtonDown);
		stage.addEventListener(JoystickEvent.BUTTON_UP, onJoyButtonUp);
		stage.addEventListener(JoystickEvent.DEVICE_ADDED, onJoyDeviceAdded);
		stage.addEventListener(JoystickEvent.DEVICE_REMOVED, onJoyDeviceRemoved);
	}

	static function onJoyAxisMove(e:JoystickEvent)
	{
		var joy:Gamepad = Gamepad.gamepad(e.device);
		for (i in 0 ... e.axis.length)
		{
			joy.onAxisMove(i, e.axis[i]);
		}
	}

	static function onJoyButtonDown(e:JoystickEvent)
	{
		var joy:Gamepad = Gamepad.gamepad(e.device);
		joy.onButtonDown(e.id);
	}

	static function onJoyButtonUp(e:JoystickEvent)
	{
		var joy:Gamepad = Gamepad.gamepad(e.device);
		joy.buttons.set(e.id, BUTTON_RELEASED);
	}

	static function onJoyDeviceAdded(e:JoystickEvent)
	{
		var joy = new Gamepad(e.device);
		Gamepad.gamepads[e.device] = joy;
		++Gamepad.gamepadCount;
		Input.handlers.push(joy);
		Gamepad.onConnect.invoke(joy);
	}

	static function onJoyDeviceRemoved(e:JoystickEvent)
	{
		var joy:Gamepad = Gamepad.gamepad(e.device);
		joy.connected = false;
		Gamepad.gamepads.remove(e.device);
		--Gamepad.gamepadCount;
		if (Input.handlers.indexOf(joy) > -1) Input.handlers.remove(joy);
		Gamepad.onDisconnect.invoke(joy);
	}
}
