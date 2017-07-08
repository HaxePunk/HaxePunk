package haxepunk.debug;

import haxepunk.HXP;
import haxepunk.graphics.text.Text;
import haxepunk.input.MouseManager;
import haxepunk.utils.CircularBuffer;
import haxepunk.utils.Draw;

class LogPanel extends Entity
{
	static inline var EXPAND_PER_SECOND:Int = 2048;
	static inline var LOG_LINES:Int = 24;

	var label:Text;
	var expanded:Bool = false;
	var alpha:Float = 0.5;
	var logMessages:CircularBuffer<String> = new CircularBuffer(LOG_LINES);

	public function new(mouseManager:MouseManager)
	{
		super();
		label = new Text("Mouse");
		addGraphic(label);
		height = 48;
		type = mouseManager.type;
		mouseManager.add(this, null, onClick, onEnter, onExit);
	}

	override public function update()
	{
		super.update();

		var targetHeight:Int = (expanded ? 20 * LOG_LINES : 40) + 8;
		if (height != targetHeight)
		{
			var change = Std.int(EXPAND_PER_SECOND * HXP.elapsed);
			if (Math.abs(height - targetHeight) < change)
			{
				height = targetHeight;
			}
			else
			{
				height += change * (height > targetHeight ? -1 : 1);
			}
		}

		var txt:String = "";
		if (expanded && height == targetHeight)
		{
			for (msg in logMessages)
			{
				txt += msg + "\n";
			}
		}
		else
		{
			if (logMessages.length > 0) txt += logMessages.last + "\n";
		}
		for (scene in HXP.engine)
		{
			var mouseLabel = StringTools.rpad("Mouse: " + scene.mouseX + "," + scene.mouseY, " ", 20);
			txt += mouseLabel + "Camera: " + scene.camera.x + "," + scene.camera.y;
		}
		if (label.text != txt) label.text = txt;
		label.y = height - label.textHeight - 4;
	}

	override public function render(camera:Camera)
	{
		var fsx:Float = camera.fullScaleX,
			fsy:Float = camera.fullScaleY;
		Draw.setColor(0, alpha);
		Draw.lineThickness = 4;
		Draw.rectFilled(x * fsx, y * fsy, width * fsx, height * fsy);

		super.render(camera);
	}

	public function log(data:Array<Dynamic>)
	{
		for (msgs in data)
		{
			for (msg in Std.string(msgs).split("\n")) logMessages.push(Std.string(msg));
		}
	}

	function onClick()
	{
		expanded = !expanded;
	}

	function onEnter() alpha = 0.75;
	function onExit() alpha = 0.5;
}
