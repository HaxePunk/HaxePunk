package com.haxepunk.graphics.prototype;

import com.haxepunk.RenderMode;
import com.haxepunk.graphics.atlas.AtlasData;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.geom.Point;

class Circle extends Graphic
{

	public var color(default, set_color):Int = 0;
	public var radius(default, set_radius):Int = 0;

	public function new(radius:Int, color:Int=0xFFFFFF)
	{
		super();

		this.color = color;
		this.radius = radius;
	}

	public override function render(target:BitmapData, point:Point, camera:Point)
	{
		if (HXP.renderMode.has(RenderMode.BUFFER))
		{
			image.render(target, point, camera);
		}
		else
		{
			_point.x = point.x + x + radius - camera.x * scrollX;
			_point.y = point.y + y + radius - camera.y * scrollY;

			var gfx = AtlasData.getSpriteByLayer(layer).graphics;
			gfx.beginFill(color);
			gfx.drawCircle(_point.x, _point.y, radius);
		}
	}

	private function createImage()
	{
		if (HXP.renderMode.has(RenderMode.BUFFER) && radius > 0)
		{
			HXP.sprite.graphics.clear();
			HXP.sprite.graphics.beginFill(color);
			HXP.sprite.graphics.drawCircle(radius, radius, radius);
			var data:BitmapData = HXP.createBitmap(radius * 2, radius * 2, true);
			data.draw(HXP.sprite);
			image = new Image(data);
		}
	}

	private function set_radius(value:Int):Int
	{
		if (radius == value) return value;
		radius = value;
		createImage();
		return value;
	}

	private function set_color(value:Int):Int
	{
		if (color == value) return value;
		color = value;
		createImage();
		return value;
	}

	private var image:Image;
}
