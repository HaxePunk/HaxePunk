package haxepunk.graphics;

import flash.display.BlendMode;
import flash.geom.Point;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.graphics.atlas.AtlasData;
import haxepunk.utils.Color;

class ColoredRect extends Graphic
{
	public var width:Float;
	public var height:Float;
	public var blendMode:BlendMode = BlendMode.ALPHA;

	public var color:Color;
	public var alpha:Float;

	public function new(width:Float, height:Float, color:Color = Color.White, alpha:Float = 1)
	{
		super();
		this.width = width;
		this.height = height;
		this.color = color;
		this.alpha = alpha;
	}

	@:access(haxepunk.graphics.atlas.AtlasData)
	@:access(haxepunk.graphics.atlas.SceneSprite)
	override public function render(layer:Int, point:Point, camera:Point)
	{
		var batch = AtlasData._scene.sprite.batch,
			command = batch.getDrawCommand(null, false, blendMode);
		var x1 = (point.x - camera.x + x) * HXP.screen.fullScaleX,
			x2 = x1 + width * HXP.screen.fullScaleX,
			y1 = (point.y - camera.y + y) * HXP.screen.fullScaleY,
			y2 = y1 + height * HXP.screen.fullScaleY;
		var red = color.red,
			green = color.green,
			blue = color.blue;
		command.addTriangle(x1, y1, 0, 0, x2, y1, 0, 0, x1, y2, 0, 0, red, green, blue, alpha);
		command.addTriangle(x1, y2, 0, 0, x2, y1, 0, 0, x2, y2, 0, 0, red, green, blue, alpha);
	}
}
