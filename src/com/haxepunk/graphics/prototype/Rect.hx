package com.haxepunk.graphics.prototype;

import com.haxepunk.RenderMode;
import com.haxepunk.graphics.atlas.Atlas;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.geom.Point;

class Rect extends Graphic
{

	public var color(default, setColor):Int = 0;
	public var width(default, setWidth):Int = 0;
	public var height(default, setHeight):Int = 0;

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
			image.render(target, point, camera);
		}
		else
		{
			_point.x = point.x + x - camera.x * scrollX;
			_point.y = point.y + y - camera.y * scrollY;

			var gfx = Atlas.getSpriteByLayer(layer).graphics;
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

	private function setHeight(value:Int):Int
	{
		if (height == value) return value;
		height = value;
		createImage();
		return value;
	}

	private function setWidth(value:Int):Int
	{
		if (width == value) return value;
		width = value;
		createImage();
		return value;
	}

	private function setColor(value:Int):Int
	{
		if (color == value) return value;
		color = value;
		createImage();
		return value;
	}

	private var image:Image;
}