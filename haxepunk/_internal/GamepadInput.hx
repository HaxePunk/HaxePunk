package haxepunk._internal;

import kha.input.Gamepad as KhaGamepad;
import haxepunk.input.Gamepad;
import haxepunk.input.Input;

import haxepunk.utils.Log;

@:access(haxepunk.input.Gamepad)
class GamepadInput
{
	public static function init()
	{
        Log.debug('Internal gamepad listening.');
        KhaGamepad.notifyOnConnect(onGamepadAdded, onGamepadRemoved);
	}

    static function onGamepadAdded(id:Int)
    {
        Log.debug('internal gamepad added( #$id )');
        if( Gamepad.gamepads.exists(id) ) Log.error('INTERNAL GAMEPAD $id is already registered!');
        // Don't add the same gamepad twice.
        var controller = KhaGamepad.get(id);
        var joy:Gamepad = new Gamepad(id);
        Gamepad.gamepads[id] = joy;
        ++Gamepad.gamepadCount;

        // map kha gamepad listeners to our joydevice
        controller.notify(joy.onAxisMove, joy.onButtonInput);

        Input.handlers.push(joy);
        Gamepad.onConnect.invoke(joy);
    }

    static function onGamepadRemoved(id:Int)
    {   
        Log.debug('internal gamepad removed( #$id )');
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
