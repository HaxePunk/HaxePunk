package haxepunk.graphics;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.Matrix;
import flash.geom.Point;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.RenderMode;
import haxepunk.graphics.atlas.AtlasData;
import haxepunk.utils.Color;

class ColoredRect extends Graphic
{
	public var width:Float;
	public var height:Float;
	public var blendMode:BlendMode = BlendMode.ALPHA;

	public var color(get, set):Color;
	inline function get_color() return _color;
	inline function set_color(v:Color)
	{
		if (blit)
		{
			_canvas.fillRect(_canvas.rect, v.toARGB(alpha));
		}
		return _color = v;
	}

	public var alpha(get, set):Float;
	inline function get_alpha() return _alpha;
	inline function set_alpha(v:Float)
	{
		if (blit)
		{
			_canvas.fillRect(_canvas.rect, color.toARGB(v));
		}
		return _alpha = v;
	}

	var _canvas:BitmapData;
	var _color:Color;
	var _alpha:Float;

	public function new(width:Float, height:Float, color:Color = Color.White, alpha:Float = 1)
	{
		super();
		this.width = width;
		this.height = height;
		this._color = color;
		this._alpha = alpha;
		blit = HXP.renderMode == RenderMode.BUFFER;

		if (blit)
		{
			_canvas = new BitmapData(1, 1, true, color.toARGB(alpha));
		}
	}

	override public function render(target:BitmapData, point:Point, camera:Camera)
	{
		var sx = width * HXP.screen.fullScaleX,
			sy = height * HXP.screen.fullScaleY,
			tx = point.x - camera.x + x,
			ty = point.y - camera.y + y;
		if (_matrix == null) _matrix = new Matrix(sx, 0, 0, sy, tx, ty);
		else _matrix.setTo(sx, 0, 0, sy, tx, ty);
		target.draw(_canvas, _matrix);
	}

	@:access(haxepunk.graphics.atlas.AtlasData)
	@:access(haxepunk.graphics.atlas.SceneSprite)
	override public function renderAtlas(layer:Int, point:Point, camera:Point)
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

	static var _matrix:Matrix;
}
