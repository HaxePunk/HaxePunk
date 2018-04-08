package haxepunk._internal;

import nme.events.JoystickEvent;
import haxepunk.input.Gamepad;
import haxepunk.input.Input;

@:access(haxepunk.input.Gamepad)
class GamepadInput
{
	public static function init(app:FlashApp)
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
		// FIXME: NME doesn't expose device name/guid
		Log.info(joy.type == null ? 'unknown Gamepad (${joy.guid}: ${joy.name}) added' : 'Gamepad (${joy.guid}: ${joy.name}) added; mapped as ${joy.type.name}');
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
		Input.handlers.remove(joy);
		Gamepad.onDisconnect.invoke(joy);
		Log.info('Gamepad (${joy.guid}: ${joy.name}) removed');
	}
}
