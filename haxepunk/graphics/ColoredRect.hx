package haxepunk.graphics;

import flash.geom.Point;
import haxepunk.Graphic;
import haxepunk.graphics.atlas.AtlasData;
import haxepunk.graphics.shader.ColorShader;
import haxepunk.utils.Color;

class ColoredRect extends Graphic
{
	public var width:Float;
	public var height:Float;

	public function new(width:Float, height:Float, color:Color = Color.White, alpha:Float = 1)
	{
		super();
		this.width = width;
		this.height = height;
		this.color = color;
		this.alpha = alpha;
		this.shader = ColorShader.defaultShader;
	}

	@:access(haxepunk.graphics.atlas.AtlasData)
	@:access(haxepunk.graphics.hardware.SceneRenderer)
	override public function render(point:Point, camera:Camera)
	{
		var command = AtlasData._batch.getDrawCommand(null, shader,
				false, blend, screenClipRect(camera, point.x, point.y));

		var fsx = camera.fullScaleX,
			fsy = camera.fullScaleY;
		var x1 = (floorX(camera, point.x) - floorX(camera, camera.x) + floorX(camera, x)) * fsx,
			x2 = x1 + width * fsx,
			y1 = (floorY(camera, point.y) - floorY(camera, camera.y) + floorY(camera, y)) * fsy,
			y2 = y1 + height * fsy;

		command.addTriangle(x1, y1, 0, 0, x2, y1, 0, 0, x1, y2, 0, 0, color, alpha);
		command.addTriangle(x1, y2, 0, 0, x2, y1, 0, 0, x2, y2, 0, 0, color, alpha);
	}
}
