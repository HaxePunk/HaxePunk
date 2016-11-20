package com.haxepunk.graphics.atlas;

#if draw_tiles
import flash.geom.Rectangle;
import openfl.display.Tilesheet;

@:access(com.haxepunk.graphics.atlas.AtlasData)
@:access(com.haxepunk.graphics.atlas.DrawCommand)
@:access(com.haxepunk.graphics.atlas.QuadData)
@:dox(hide)
class DrawTilesRenderer
{
	static var flags:Int = Tilesheet.TILE_TRANS_2X2 | Tilesheet.TILE_ALPHA | Tilesheet.TILE_BLEND_NORMAL | Tilesheet.TILE_RGB | Tilesheet.TILE_RECT;
	static var _data:Array<Float> = new Array();

	public function new(data:AtlasData) {}

	public static function render(drawCommand:DrawCommand, scene:Scene, rect:Rectangle):Void
	{
		var count:Int;

		while (drawCommand != null)
		{
			count = 0;
			var quad = drawCommand.quad;
			while (quad != null)
			{
				_data[count++] = quad.tx;
				_data[count++] = quad.ty;
				_data[count++] = quad.rx;
				_data[count++] = quad.ry;
				_data[count++] = quad.rw;
				_data[count++] = quad.rh;
				_data[count++] = quad.a;
				_data[count++] = quad.b;
				_data[count++] = quad.c;
				_data[count++] = quad.d;
				_data[count++] = quad.red;
				_data[count++] = quad.green;
				_data[count++] = quad.blue;
				_data[count++] = quad.alpha;

				quad = quad._next;
			}

			if (count > 0)
			{
				var tilesheet = new Tilesheet(drawCommand.texture);
				tilesheet.drawTiles(scene.sprite.graphics, _data, drawCommand.smooth, flags | drawCommand.blend.tilesheetBlendFlag, count);
			}

			drawCommand = drawCommand._next;
		}
	}

	public static function startFrame(scene:Scene)
	{
		scene.sprite.graphics.clear();
	}

	@:access(com.haxepunk.graphics.atlas.SceneSprite)
	public static function endFrame(scene:Scene)
	{
		render(scene.sprite.draw, scene, scene.sprite.scrollRect);
	}
}
#end
