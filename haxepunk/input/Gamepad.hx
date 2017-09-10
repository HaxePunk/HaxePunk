package haxepunk.input;

import flash.geom.Point;
#if lime
import lime.ui.Gamepad as LimeGamepad;
#else
import flash.events.JoystickEvent;
#end
import haxepunk.HXP;
import haxepunk.Signal;

typedef GamepadID = Int;
typedef GamepadButton = Int;
typedef GamepadAxis = Int;

@:enum
abstract JoyButtonState(Int) from Int to Int
{
	var BUTTON_ON = 1;
	var BUTTON_OFF = 0;
	var BUTTON_PRESSED = 2;
	var BUTTON_RELEASED = -1;
}

typedef AxisDefinition =
{
	var axis:GamepadAxis;
	var minValue:Float;
	var maxValue:Float;
	var input:InputType;
}

/**
 * A gamepad.
 */
class Gamepad
{
	/**
	 * Determines the gamepad's deadZone. Anything under this value will be considered 0 to prevent jitter.
	 */
	public static var deadZone:Float = 0.15;

	public static var gamepads:Map<Int, Gamepad> = new Map<Int, Gamepad>();
	public static var onConnect:Signal1<Gamepad> = new Signal1();
	public static var onDisconnect:Signal1<Gamepad> = new Signal1();

	public static function init()
	{
		#if lime
		LimeGamepad.onConnect.add(onJoyDeviceAdded);
		for (device in LimeGamepad.devices) onJoyDeviceAdded(device);
		#else
		HXP.engine.stage.addEventListener(JoystickEvent.AXIS_MOVE, onJoyAxisMove);
		HXP.engine.stage.addEventListener(JoystickEvent.BUTTON_DOWN, onJoyButtonDown);
		HXP.engine.stage.addEventListener(JoystickEvent.BUTTON_UP, onJoyButtonUp);
		HXP.engine.stage.addEventListener(JoystickEvent.DEVICE_ADDED, onJoyDeviceAdded);
		HXP.engine.stage.addEventListener(JoystickEvent.DEVICE_REMOVED, onJoyDeviceRemoved);
		#end
	}

	/**
	 * Returns a gamepad object, or null if none exists at this ID.
	 * @param  id The id of the gamepad, starting with 0
	 * @return    A Gamepad object
	 */
	public static function gamepad(id:GamepadID):Null<Gamepad>
	{
		return gamepads.get(id);
	}

	/**
	 * Returns the number of connected gamepads
	 */
	public static var gamepadCount(default, null):Int = 0;

#if lime
	static function onJoyDeviceAdded(limeGamepad:LimeGamepad)
	{
		var joy:Gamepad = new Gamepad(limeGamepad.id);
		gamepads[limeGamepad.id] = joy;
		++gamepadCount;

		limeGamepad.onButtonUp.add(joy.onButtonUp);
		limeGamepad.onButtonDown.add(joy.onButtonDown);
		limeGamepad.onAxisMove.add(onJoyAxisMove.bind(limeGamepad));
		limeGamepad.onDisconnect.add(onJoyDeviceRemoved.bind(limeGamepad));

		Input.handlers.push(joy);
		onConnect.invoke(joy);
	}

	static function onJoyDeviceRemoved(limeGamepad:LimeGamepad)
	{
		var joy:Gamepad = gamepad(limeGamepad.id);
		joy.connected = false;
		gamepads.remove(limeGamepad.id);
		--gamepadCount;

		if (Input.handlers.indexOf(joy) > -1) Input.handlers.remove(joy);
		onDisconnect.invoke(joy);
	}

	static function onJoyAxisMove(limeGamepad:LimeGamepad, a:GamepadAxis, v:Float)
	{
		var joy:Gamepad = gamepad(limeGamepad.id);
		joy.onAxisMove(a, v);
	}
#else
	static function onJoyAxisMove(e:JoystickEvent)
	{
		var joy:Gamepad = gamepad(e.device);
		for (i in 0 ... e.axis.length)
		{
			joy.onAxisMove(i, e.axis[i]);
		}
	}

	static function onJoyButtonDown(e:JoystickEvent)
	{
		var joy:Gamepad = gamepad(e.device);
		joy.onButtonDown(e.id);
	}

	static function onJoyButtonUp(e:JoystickEvent)
	{
		var joy:Gamepad = gamepad(e.device);
		joy.buttons.set(e.id, BUTTON_RELEASED);
	}

	static function onJoyDeviceAdded(e:JoystickEvent)
	{
		var joy = new Gamepad(e.device);
		gamepads[e.device] = joy;
		++gamepadCount;
		Input.handlers.push(joy);
		onConnect.invoke(joy);
	}

	static function onJoyDeviceRemoved(e:JoystickEvent)
	{
		var joy:Gamepad = gamepad(e.device);
		joy.connected = false;
		gamepads.remove(e.device);
		--gamepadCount;
		if (Input.handlers.indexOf(joy) > -1) Input.handlers.remove(joy);
		onDisconnect.invoke(joy);
	}
#end

	public var id:Int = 0;

	/**
	 * If the gamepad is currently connected.
	 */
	public var connected:Bool = true;

	/**
	 * A map of buttons and their states
	 */
	public var buttons:Map<Int, JoyButtonState> = new Map();
	/**
	 * Each axis contained in an array.
	 */
	public var axis(null, default):Map<Int, Float> = new Map();
	var lastAxis:Map<Int, Float> = new Map();
	/**
	 * A Point containing the gamepad's hat value.
	 */
	public var hat:Point = new Point();

	/**
	 * Creates and initializes a new Gamepad.
	 */
	@:dox(hide)
	function new(id:Int)
	{
		this.id = id;
	}

	public function update():Void {}

	/**
	 * Updates the gamepad's state.
	 */
	@:dox(hide)
	public function postUpdate():Void
	{
		for (button in _allButtons)
		{
			switch (buttons.get(button))
			{
				case BUTTON_PRESSED:
					buttons.set(button, BUTTON_ON);
				case BUTTON_RELEASED:
					buttons.set(button, BUTTON_OFF);
				default:
			}
		}
		for (axis in _allAxes)
		{
			lastAxis[axis] = this.axis[axis];
		}
	}

	public function defineButton(input:InputType, buttons:Array<GamepadButton>)
	{
		// undefine any pre-existing button mappings
		if (_control.exists(input))
		{
			for (button in _control[input])
			{
				_buttonMap[button].remove(input);
			}
		}
		_control.set(input, buttons);
		for (button in buttons)
		{
			if (!_buttonMap.exists(button)) _buttonMap[button] = new Array();
			if (_buttonMap[button].indexOf(input) < 0) _buttonMap[button].push(input);
		}
	}

	public function defineAxis(input:InputType, axis:GamepadAxis, minValue:Float=0, maxValue:Float=1)
	{
		if (minValue > maxValue)
		{
			var swap = maxValue;
			maxValue = minValue;
			minValue = swap;
		}
		if (!_axisControl.exists(input))
		{
			_axisControl[input] = new Array();
		}
		var def = {
			axis: axis,
			minValue: minValue,
			maxValue: maxValue,
			input: input
		};
		_axisControl[input].push(def);
		if (!_axisMap.exists(axis)) _axisMap[axis] = new Array();
		if (_axisMap[axis].indexOf(def) < 0) _axisMap[axis].push(def);
	}

	public function checkInput(input:InputType)
	{
		if (_control.exists(input))
		{
			for (button in _control[input])
			{
				if (check(button)) return true;
			}
			for (axisDef in _axisControl[input])
			{
				if (checkAxis(axisDef)) return true;
			}
		}
		return false;
	}

	public function pressedInput(input:InputType)
	{
		if (_control.exists(input))
		{
			for (button in _control[input])
			{
				if (pressed(button)) return true;
			}
		}
		if (_axisControl.exists(input))
		{
			for (axisDef in _axisControl[input])
			{
				if (pressedAxis(axisDef)) return true;
			}
		}
		return false;
	}

	public function releasedInput(input:InputType)
	{
		if (_control.exists(input))
		{
			for (button in _control[input])
			{
				if (released(button)) return true;
			}
			for (axisDef in _axisControl[input])
			{
				if (releasedAxis(axisDef)) return true;
			}
		}
		return false;
	}

	public function pressed(button:GamepadButton):Bool
	{
		return buttons.exists(button) && buttons.get(button) == BUTTON_PRESSED;
	}

	/**
	 * If the gamepad button was released this frame.
	 * Omit argument to check for any button.
	 * @param  button The button index to check.
	 */
	public function released(button:GamepadButton):Bool
	{
		return buttons.exists(button) && buttons.get(button) == BUTTON_RELEASED;
	}

	/**
	 * If the gamepad button is held down.
	 * Omit argument to check for any button.
	 * @param  button The button index to check.
	 */
	public function check(button:GamepadButton):Bool
	{
		return buttons.exists(button) && buttons[button] != BUTTON_OFF && buttons[button] != BUTTON_RELEASED;
	}

	public function pressedAxis(axisDef:AxisDefinition):Bool
	{
		return checkAxis(axisDef) && !checkLastAxis(axisDef);
	}

	public function releasedAxis(axisDef:AxisDefinition):Bool
	{
		return checkLastAxis(axisDef) && !checkAxis(axisDef);
	}

	public inline function checkAxis(axisDef:AxisDefinition):Bool
	{
		return axis.exists(axisDef.axis) && axis[axisDef.axis] >= axisDef.minValue && axis[axisDef.axis] <= axisDef.maxValue;
	}

	inline function checkLastAxis(axisDef:AxisDefinition):Bool
	{
		return lastAxis.exists(axisDef.axis) && lastAxis[axisDef.axis] >= axisDef.minValue && lastAxis[axisDef.axis] <= axisDef.maxValue;
	}

	/**
	 * Returns the axis value (from 0 to 1)
	 * @param  a The axis index to retrieve starting at 0
	 */
	public inline function getAxis(a:Int):Float
	{
		if (!axis.exists(a)) return 0;
		else return (Math.abs(axis[a]) < deadZone) ? 0 : axis[a];
	}

	function onButtonUp(id:GamepadButton)
	{
		buttons.set(id, BUTTON_RELEASED);
		if (_buttonMap.exists(id)) for (inputType in _buttonMap[id]) Input.triggerRelease(inputType);
	}

	function onButtonDown(id:GamepadButton)
	{
		if (!buttons.exists(id)) _allButtons.push(id);
		buttons.set(id, BUTTON_PRESSED);
		if (_buttonMap.exists(id)) for (inputType in _buttonMap[id]) Input.triggerPress(inputType);
	}

	function onAxisMove(axis:GamepadAxis, v:Float):Void
	{
		if (Math.abs(v) < deadZone) v = 0;
		if (!this.axis.exists(axis)) _allAxes.push(axis);
		this.axis[axis] = v;
		if (_axisMap.exists(axis))
		{
			for (axisDef in _axisMap[axis])
			{
				if (v >= axisDef.minValue && v <= axisDef.maxValue) Input.triggerPress(axisDef.input);
				else if (lastAxis[axis] >= axisDef.minValue && lastAxis[axis] <= axisDef.maxValue) Input.triggerRelease(axisDef.input);
			}
		}
	}

	var _control:Map<InputType, Array<GamepadButton>> = new Map();
	var _buttonMap:Map<GamepadButton, Array<InputType>> = new Map();
	var _allButtons:Array<GamepadButton> = new Array();
	var _axisControl:Map<InputType, Array<AxisDefinition>> = new Map();
	var _axisMap:Map<GamepadAxis, Array<AxisDefinition>> = new Map();
	var _allAxes:Array<GamepadButton> = new Array();
}
