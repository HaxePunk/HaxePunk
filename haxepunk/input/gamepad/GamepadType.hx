package haxepunk.input.gamepad;

/**
 * Represents a specific gamepad profile; maps raw input codes to
 * `GamepadButton` or `GamepadAxis` values.
 *
 * @since	4.1.0
 */
class GamepadType
{
	static var controllers:Map<String, GamepadType> #if !hxp_no_gamepad = ControllerData.getMap() #end;

	public static inline function get(guid:String):Null<GamepadType>
	{
		return (controllers != null && controllers.exists(guid)) ? controllers[guid] : null;
	}

	public var guid:String;
	public var name:String;

	// maps of raw input codes to abstract values
	var buttons:Map<Int, GamepadButton>;
	var axes:Map<Int, GamepadAxis>;

	public function new(guid:String, name:String, buttons:Map<Int, GamepadButton>, axes:Map<Int, GamepadAxis>)
	{
		this.guid = guid;
		this.name = name;
		this.buttons = buttons;
		this.axes = axes;
	}

	public function mapButton(rawButton:Int):GamepadButton
	{
		return buttons.exists(rawButton) ? buttons[rawButton] : rawButton;
	}

	public function mapAxis(rawAxis:Int):GamepadAxis
	{
		return axes.exists(rawAxis) ? axes[rawAxis] : rawAxis;
	}
}
