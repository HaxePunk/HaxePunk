package com.haxepunk.graphics.prototype;

import com.haxepunk.RenderMode;
import com.haxepunk.graphics.atlas.AtlasData;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.geom.Point;

class Rect extends Graphic
{

	public var color(default, set_color):Int = 0;
	public var width(default, set_width):Int = 0;
	public var height(default, set_height):Int = 0;

	public function new(width:Int, height:Int, color:Int=0xFFFFFF)
	{
		super();

		this.color = color;
		this.width = width;
		this.height = height;
	}

	public override function render(target:BitmapData, point:Point, camera:Point)
	{
		if (HXP.renderMode.has(RenderMode.BUFFER))
		{
			_point.x = point.x + x;
			_point.y = point.y + y;
			image.render(target, _point, camera);
		}
		else
		{
			_point.x = point.x + x - camera.x * scrollX;
			_point.y = point.y + y - camera.y * scrollY;

			var gfx = AtlasData.getSpriteByLayer(layer).graphics;
			gfx.beginFill(color);
			gfx.drawRect(_point.x, _point.y, width, height);
		}
	}

	private function createImage()
	{
		if (HXP.renderMode.has(RenderMode.BUFFER) && width > 0 && height > 0)
		{
			var source:BitmapData = HXP.createBitmap(width, height, true, 0xFF000000 | color);
			image = new Image(source);
		}
	}

	private function set_height(value:Int):Int
	{
		if (height == value) return value;
		height = value;
		createImage();
		return value;
	}

	private function set_width(value:Int):Int
	{
		if (width == value) return value;
		width = value;
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
