package haxepunk.debug;

import haxepunk.HXP;
import haxepunk.graphics.text.BitmapText;
import haxepunk.input.MouseManager;
import haxepunk.utils.CircularBuffer;
import haxepunk.utils.Draw;

class LogPanel extends Entity
{
	static inline var EXPAND_PER_SECOND:Int = 2048;
	static inline var LOG_LINES:Int = 10;
	static inline var MAX_HEIGHT:Int = 216;
	static inline var MIN_HEIGHT:Int = 48;

	var label:BitmapText;
	var expanded:Bool = false;
	var alpha:Float = 0.5;
	var logMessages:CircularBuffer<String> = new CircularBuffer(LOG_LINES);

	public function new(mouseManager:MouseManager)
	{
		super();
		label = new BitmapText("Mouse");
		label.x = 8;
		addGraphic(label);
		height = 48;
		type = mouseManager.type;
		mouseManager.add(this, null, onClick, onEnter, onExit);
	}

	override public function update()
	{
		super.update();

		var targetHeight:Int = expanded ? MAX_HEIGHT : MIN_HEIGHT;
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
		var heightDiff = MAX_HEIGHT - MIN_HEIGHT;
		var p = (height - MIN_HEIGHT) / heightDiff;
		var lines:Int = Std.int(1 + p * (LOG_LINES - 1));
		for (msg in logMessages.slice(logMessages.length - lines))
		{
			if (msg != null)
			{
				txt += msg + "\n";
			}
		}
		var mouseLabel = StringTools.rpad("Mouse: " + HXP.scene.mouseX + "," + HXP.scene.mouseY, " ", 20);
		txt += mouseLabel + "Camera: " + HXP.scene.camera.x + "," + HXP.scene.camera.y;
		if (label.text != txt) label.text = txt;
		label.y = height - label.textHeight - 4;
	}

	override public function render(camera:Camera)
	{
		var fsx:Float = camera.screenScaleX,
			fsy:Float = camera.screenScaleY;
		Draw.setColor(0, alpha);
		Draw.lineThickness = 4;
		Draw.rectFilled(x * fsx, y * fsy, width * fsx, height * fsy);

		super.render(camera);
	}

	public function log(data:Dynamic)
	{
		logMessages.push(Std.string(data));
	}

	function onClick()
	{
		expanded = !expanded;
	}

	function onEnter() alpha = 0.75;
	function onExit() alpha = 0.5;
}
