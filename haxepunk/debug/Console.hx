package haxepunk.debug;

import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.scene.*;
import haxepunk.utils.*;

class Console
{

	public static var enabled:Bool = false;

	public static function log(line:String)
	{
		instance.lines.push(line);
		if (instance.lines.length > 500) instance.lines.shift();
	}

	private function new()
	{
		lines = [LibInfo.name + " " + LibInfo.fullVersion];
		origin = new Vector3();
		text = new Text(lines.join("\n"), 12);
		text.color.fromRGB(0.2, 0.2, 0.2);
	}

	public function update(elapsed:Float):Void
	{
		text.text = lines.join("\n") + "\n> " + input;
	}

	public function draw(camera:Camera):Void
	{
		origin.y = HXP.window.height - text.height;
		// TODO: only use projection and not worldview matrix
		text.draw(camera, origin);
	}

	@:allow(haxepunk.scene.Scene)
	private static var instance(get, null):Console;
	private static inline function get_instance():Console {
		if (instance == null)
		{
			instance = new Console();
		}
		return instance;
	}

	private var text:Text;
	private var lines:Array<String>;
	private var origin:Vector3;
	private var input:String = "";

}
