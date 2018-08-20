package haxepunk.graphics;

import haxepunk.Graphic;
import haxepunk.HXP;
import haxepunk.graphics.atlas.AtlasData;
import haxepunk.graphics.shader.ColorShader;
import haxepunk.utils.Color;
import haxepunk.math.Vector2;

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
	override public function render(point:Vector2, camera:Camera)
	{
		var command = AtlasData._batch.getDrawCommand(null, shader,
				false, blend, screenClipRect(camera, point.x, point.y));

		var fsx = camera.screenScaleX,
			fsy = camera.screenScaleY;
		var x1 = floorX(camera, point.x) - floorX(camera, camera.x) + floorX(camera, x) - floorX(camera, originX),
			x2 = x1 + width,
			y1 = floorY(camera, point.y) - floorY(camera, camera.y) + floorY(camera, y) - floorY(camera, originY),
			y2 = y1 + height;
		
		x1 = (x1 - HXP.halfWidth) * fsx + HXP.halfWidth;
		x2 = (x2 - HXP.halfWidth) * fsx + HXP.halfWidth;
		y1 = (y1 - HXP.halfHeight) * fsx + HXP.halfHeight;
		y2 = (y2 - HXP.halfHeight) * fsx + HXP.halfHeight;
		
		command.addTriangle(x1, y1, 0, 0, x2, y1, 0, 0, x1, y2, 0, 0, color, alpha);
		command.addTriangle(x1, y2, 0, 0, x2, y1, 0, 0, x2, y2, 0, 0, color, alpha);
	}

	/**
	 *  Centers the origin of this ColoredRect.
	 */
	override public function centerOrigin():Void
	{
		originX = width * 0.5;
		originY = height * 0.5;
	}
}
