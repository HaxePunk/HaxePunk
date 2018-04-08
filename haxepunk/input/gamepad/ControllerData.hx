package haxepunk.input.gamepad;

import haxe.macro.Context;
import haxe.macro.Expr;
using StringTools;

@:dox(hide)
class ControllerData
{
	macro public static function getMap()
	{
		var platform = getPlatform();
		if (platform == null) return macro new Map();

		var map:Map<String, Expr> = new Map();
		var path = Context.resolvePath("haxepunk/input/gamepad/gamecontrollerdb.txt");
		var input = sys.io.File.read(path);
		try
		{
			while (true)
			{
				var line = input.readLine().trim();

				if (line.length == 0 || line.startsWith("#")) continue;

				var vals = line.split(",");
				var guid = vals[0],
					name = vals[1];
				var mappingSpecs = vals.slice(2);
				var buttonMappings:Map<Int, Expr> = new Map();
				var axisMappings:Map<Int, Expr> = new Map();
				var use:Bool = true;

				for (mapping in mappingSpecs)
				{
					var parts = mapping.split(":");
					if (parts.length != 2) continue;
					if (parts[0] == "platform")
					{
						if (parts[1] != platform)
						{
							use = false;
							break;
						}
						continue;
					}
					var btn = parts[0],
						type = parts[1].charAt(0),
						val = Std.parseInt(parts[1].substr(1));
					try
					{
						if (type == "b")
						{
							var button = fromString(btn);
							if (buttonMappings.exists(val))
								throw 'Duplicate button: [$name] $val (${buttonMappings[val]}, ${button})';
							buttonMappings[val] = button;
						}
						else if (type == "a")
						{
							var axis = fromString(btn);
							if (axisMappings.exists(val))
								throw 'Duplicate axis: [$name] $val (${axisMappings[val]}, ${axis})';
							axisMappings[val] = axis;
						}
					}
					catch (e:String) {}
				}
				if (use)
				{
					var buttonMappings = [for (key in buttonMappings.keys()) macro $v{key} => ${buttonMappings[key]}];
					var axisMappings = [for (key in axisMappings.keys()) macro $v{key} => ${axisMappings[key]}];
					map[guid] = macro new GamepadType($v{guid}, $v{name}, $a{buttonMappings}, ${axisMappings.length > 0 ? macro [$a{axisMappings}] : macro new Map()});
				}
			}
		}
		catch (_:haxe.io.Eof) {}

		var map = $a{[for (guid in map.keys()) macro $v{guid} => ${map[guid]}]};
		return macro $a{map};
	}

	#if macro
	static function fromString(s:String):Expr
	{
		return switch (s)
		{
			case "a": macro GamepadButton.BtnA;
			case "b": macro GamepadButton.BtnB;
			case "x": macro GamepadButton.BtnX;
			case "y": macro GamepadButton.BtnY;
			case "leftshoulder": macro GamepadButton.LeftShoulder;
			case "rightshoulder": macro GamepadButton.RightShoulder;
			case "back": macro GamepadButton.Back;
			case "start": macro GamepadButton.Start;
			case "leftstick": macro GamepadButton.LeftStick;
			case "rightstick": macro GamepadButton.RightStick;
			case "guide": macro GamepadButton.Guide;
			case "dpup": macro GamepadButton.DpadUp;
			case "dpdown": macro GamepadButton.DpadDown;
			case "dpleft": macro GamepadButton.DpadLeft;
			case "dpright": macro GamepadButton.DpadRight;
			case "lefttrigger": macro GamepadAxis.LeftTrigger;
			case "righttrigger": macro GamepadAxis.RightTrigger;
			case "leftx": macro GamepadAxis.LeftX;
			case "lefty": macro GamepadAxis.LeftY;
			case "rightx": macro GamepadAxis.RightX;
			case "righty": macro GamepadAxis.RightY;
			default: throw 'Unrecognized button or axis: $s';
		}
	}

	static function getPlatform():Null<String>
	{
		if (Context.defined("windows"))
		{
			return "Windows";
		}
		else if (Context.defined("mac"))
		{
			return "Mac OS X";
		}
		else if (Context.defined("linux"))
		{
			return "Linux";
		}
		else if (Context.defined("android"))
		{
			return "Android";
		}
		else if (Context.defined("ios"))
		{
			return "iOS";
		}
		else return null;
	}
	#end
}
