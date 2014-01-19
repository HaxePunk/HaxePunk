package com.haxepunk.graphics.prototype;

import com.haxepunk.RenderMode;
import com.haxepunk.graphics.atlas.AtlasData;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Point;

class Rect extends Graphic
{

	public var color(default, set_color):Int = 0;
	public var width(default, set_width):Int = 0;
	public var height(default, set_height):Int = 0;

	/**
	 * Constructor.
	 *
	 * @param	width	The Rect's width
	 * @param	height	The Rect's height
	 * @param	color	The Rect's color
	 */
	public function new(width:Int, height:Int, color:Int=0xFFFFFF)
	{
		super();

		this.color = color;
		this.width = width;
		this.height = height;
	}

	public override function render(target:BitmapData, point:Point, camera:Point)
	{
		if (HXP.renderMode == RenderMode.BUFFER)
		{
			_point.x = point.x + x;
			_point.y = point.y + y;
			image.render(target, _point, camera);
		}
		else if (_entity != null && _entity.scene != null)
		{
			var fsx = HXP.screen.fullScaleX,
				fsy = HXP.screen.fullScaleY;

			_point.x = point.x + x - camera.x * scrollX;
			_point.y = point.y + y - camera.y * scrollY;

			_point.x = Math.floor(_point.x * fsx);
			_point.y = Math.floor(_point.y * fsy);
			
			var gfx = _entity.scene.sprite.graphics;
			gfx.beginFill(color);
			gfx.drawRect(_point.x, _point.y, width*fsx, height*fsy);
		}
	}

	private function createImage()
	{
		if (HXP.renderMode == RenderMode.BUFFER && width > 0 && height > 0)
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
