package haxepunk.debug;

import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.scene.*;
import haxepunk.utils.*;

typedef FrameInfo = {
	var frameRate:Float;
	var updateTime:Float;
	var renderTime:Float;
};

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

		_frameInfos = new HistoryQueue<FrameInfo>(50);

		logText = new Text(lines.join("\n"), 12);
		logText.color.fromRGB(0.5, 0.5, 0.5);

		fpsText = new Text("");
	}

	public function update(elapsed:Float):Void
	{
		_frameInfos.add({
			frameRate: Std.int(HXP.frameRate) / 100,
			updateTime: HXP.updateTime * 20,
			renderTime: HXP.renderTime * 150,
		});
		logText.text = lines.join("\n") + "\n> " + input;
		fpsText.text = "FPS: " + Std.int(HXP.frameRate);
	}

	public function draw():Void
	{
		var pos = HXP.scene.camera.position;

		logText.origin.y = HXP.window.height - logText.height;
		logText.draw(pos);

		fpsText.draw(pos);

		if (_frameInfos.length > 1)
		{
			var lastInfo:FrameInfo = _frameInfos[0];
			var fpsColor = new Color(0.27, 0.54, 0.4);
			var updateColor = new Color(1.0, 0.94, 0.65);
			var renderColor = new Color(0.71, 0.29, 0.15);
			var x = 0, y = 50, w = 3, h = 30;
			for (i in 1..._frameInfos.length)
			{
				var info = _frameInfos[i];
				x = i * w;
				Draw.line(x, y - lastInfo.frameRate * h, x + w, y - info.frameRate * h, fpsColor);
				Draw.line(x, y - lastInfo.updateTime * h, x + w, y - info.updateTime * h, updateColor);
				Draw.line(x, y - lastInfo.renderTime * h, x + w, y - info.renderTime * h, renderColor);
				lastInfo = info;
			}
		}
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

	private var _frameInfos:HistoryQueue<FrameInfo>;
	private var logText:Text;
	private var fpsText:Text;
	private var lines:Array<String>;
	private var origin:Vector3;
	private var input:String = "";

}
