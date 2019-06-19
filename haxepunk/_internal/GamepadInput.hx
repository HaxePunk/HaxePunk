package haxepunk._internal;

import kha.input.Gamepad as KhaGamepad;
import haxepunk.input.Gamepad;
import haxepunk.input.Input;

@:access(haxepunk.input.Gamepad)
class GamepadInput
{
	public static function init()
	{
        KhaGamepad.notifyOnConnect(onGamepadAdded, onGamepadRemoved);

        // Make sure we mount any gamepads which may be pre-registered?
        var id = 0;
        while(KhaGamepad.get(id) != null)
        {
            onGamepadAdded(id);
            ++id;
        }
	}

    static function onGamepadAdded(id:Int)
    {
        // Don't add the same gamepad twice.
        if (!Gamepad.gamepads.exists(id))
        {
            var controller = KhaGamepad.get(id);
            var joy:Gamepad = new Gamepad(id);
            Gamepad.gamepads[id] = joy;
            ++Gamepad.gamepadCount;

            // map kha gamepad listeners to our joydevice
            controller.notify(joy.onAxisMove, joy.onButtonInput);

            Input.handlers.push(joy);
            Gamepad.onConnect.invoke(joy);
        }
    }

    static function onGamepadRemoved(id:Int)
    {   
        var controller = KhaGamepad.get(id);
		var joy:Gamepad = Gamepad.gamepad(id);
		joy.connected = false;

		Gamepad.gamepads.remove(id);
		--Gamepad.gamepadCount;

        // Free up listeners for this gamepad
        controller.remove(joy.onAxisMove, joy.onButtonInput);

		if (Input.handlers.indexOf(joy) > -1) Input.handlers.remove(joy);
		Gamepad.onDisconnect.invoke(joy);
    }
}
