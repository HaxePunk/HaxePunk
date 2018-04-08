package haxepunk._internal;

import lime.ui.Gamepad as LimeGamepad;
import haxepunk.input.Gamepad;
import haxepunk.input.Input;

@:access(haxepunk.input.Gamepad)
class GamepadInput
{
	public static function init(app:FlashApp)
	{
		LimeGamepad.onConnect.add(onJoyDeviceAdded);
		for (device in LimeGamepad.devices) onJoyDeviceAdded(device);
	}

	static function onJoyDeviceAdded(limeGamepad:LimeGamepad)
	{
		var joy:Gamepad = new Gamepad(limeGamepad.id);
		Gamepad.gamepads[limeGamepad.id] = joy;
		++Gamepad.gamepadCount;

		// Lime automatically maps gamepad inputs to a common profile; store
		// name/guid, but don't use a mapping class
		joy.name = limeGamepad.name;
		joy.guid = limeGamepad.guid;

		Log.info('Gamepad (${joy.guid}: ${joy.name} added');
		if (joy.type != null)
		{
			Log.debug(@:privateAccess joy.type.buttons.toString());
			Log.debug(@:privateAccess joy.type.axes.toString());
		}

		limeGamepad.onButtonUp.add(joy.onButtonUp);
		limeGamepad.onButtonDown.add(joy.onButtonDown);
		limeGamepad.onAxisMove.add(onJoyAxisMove.bind(limeGamepad));
		limeGamepad.onDisconnect.add(onJoyDeviceRemoved.bind(limeGamepad));

		Input.handlers.push(joy);
		Gamepad.onConnect.invoke(joy);
	}

	static function onJoyDeviceRemoved(limeGamepad:LimeGamepad)
	{
		var joy:Gamepad = Gamepad.gamepad(limeGamepad.id);
		joy.connected = false;
		Gamepad.gamepads.remove(limeGamepad.id);
		--Gamepad.gamepadCount;
		if (Input.handlers.indexOf(joy) > -1) Input.handlers.remove(joy);
		Gamepad.onDisconnect.invoke(joy);
		Log.info('Gamepad (${joy.guid}: ${joy.name}) removed');
	}

	static function onJoyAxisMove(limeGamepad:LimeGamepad, a:Int, v:Float)
	{
		var joy:Gamepad = Gamepad.gamepad(limeGamepad.id);
		joy.onAxisMove(a, v);
	}
}
