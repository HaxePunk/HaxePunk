package haxepunk.debug;

import haxepunk.Entity;
import haxepunk.graphics.text.BitmapText;
import haxepunk.utils.CircularBuffer;
import haxepunk.utils.Color;
import haxepunk.utils.DrawContext;
import haxepunk.math.MathUtil;

class Metric<T:Float> extends Entity
{
	static var drawContext:DrawContext;

	var metricName:String;
	var data:CircularBuffer<T>;
	var minScale:Float = 0;
	var color:Color = 0xffffff;

	var label:BitmapText;

	public function new(name:String, data:CircularBuffer<T>, color:Color, minScale:Float)
	{
		super();
		this.metricName = name;
		this.data = data;
		this.color = color;
		this.minScale = minScale;

		label = new BitmapText(name);
		label.x = label.y = 4;
		addGraphic(label);

		width = 240;
		height = 80;

		if (drawContext == null)
		{
			drawContext = new DrawContext();
			drawContext.lineThickness = 4;
		}
	}

	override public function update()
	{
		var last = data.last == null ? 0 : MathUtil.roundDecimal(data.last, 2);
		label.text = '$metricName: $last';
	}

	override public function render(camera:Camera)
	{
		var fsx:Float = camera.fullScaleX,
			fsy:Float = camera.fullScaleY;

		drawContext.scene = scene;
		drawContext.setColor(color.lerp(0, 0.9), 0.8);
		drawContext.rectFilled(x * fsx, y * fsy, width * fsx, height * fsy);

		if (data.length > 1)
		{
			HXP.clear(points);
			inline function tx(v:Float) return (x + width * MathUtil.clamp(v, 0, 1)) * fsx;
			inline function ty(v:Float) return (y + height * (1 - MathUtil.clamp(v, 0, 1))) * fsy;
			var max:Float = minScale;
			for (value in data)
			{
				if (value > max) max = value;
			}
			for (i in 0 ... data.length)
			{
				points.push(tx(i / data.maxLength));
				points.push(ty(data.get(i) / max));
			}
			drawContext.setColor(color, 0.75);
			drawContext.polyline(points, false);
		}

		super.render(camera);
	}

	var points:Array<Float> = new Array();
}
