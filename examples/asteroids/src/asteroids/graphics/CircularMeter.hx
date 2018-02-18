package asteroids.graphics;

import haxepunk.Camera;
import haxepunk.Graphic;
import haxepunk.math.Vector2;
import haxepunk.utils.DrawContext;

class CircularMeter extends Graphic
{
	static var context:DrawContext;

	public var fill:Float = 0;
	public var radius:Int = 0;

	public function new(size:Int=32)
	{
		super();
		if (context == null) context = new DrawContext();
		this.radius = Std.int(size / 2);
	}

	override public function render(point:Vector2, camera:Camera)
	{
		var sy = camera.screenScaleY;
		var x = point.x + x - camera.x,
			y = point.y + y - camera.y;
		context.color = color.lerp(0, 0.5);
		context.alpha = alpha;
		context.lineThickness = 24 * sy;
		context.arc(
			(x + radius) * sy,
			(y + radius) * sy,
			radius * sy,
			1.65625 * Math.PI, -1.3125 * Math.PI,
			16
		);
		if (fill > 0)
		{
			context.color = color;
			context.lineThickness = 16 * sy;
			context.arc(
				(x + radius) * sy,
				(y + radius) * sy,
				radius * sy,
				1.625 * Math.PI, -1.25 * Math.PI * fill,
				Std.int(Math.max(2, 16 * fill))
			);
		}
	}
}
