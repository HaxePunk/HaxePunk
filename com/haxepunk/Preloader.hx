package com.haxepunk;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

import openfl.display.Tilesheet;

@:bitmap("assets/graphics/preloader/haxepunk.png")
class HaxePunkLogo extends BitmapData {}

class Preloader extends NMEPreloader
{

	public function new()
	{
		tileData = [
			  0,   0, 0, 1,  0, // powered by
			 80, 190, 3, 1, 20, // large cog
			190, 185, 4, 1, 40, // small cog
			187, 260, 2, 1,  0, // factory
			  0, 260, 1, 1,  0, // haxepunk
		];

		tiles = new Tilesheet(new HaxePunkLogo(0, 0));
		tiles.addTileRect(new Rectangle(0, 0, 274, 58)); // powered by
		tiles.addTileRect(new Rectangle(0, 65, 274, 80)); // haxepunk
		tiles.addTileRect(new Rectangle(0, 165, 114, 190), new Point(57, 190)); // factory
		tiles.addTileRect(new Rectangle(115, 164, 134, 136), new Point(67, 68)); // large cog
		tiles.addTileRect(new Rectangle(123, 305, 56, 56), new Point(28, 28)); // small cog

		scaleIncrement = 0.002;

		var width = 260;
		var height = 340;

		// update bar position
		var color = 0xFFCB6325;
		var padding = 5;

		super();

		outline.x = (getWidth() - width) / 2;
		outline.y = (getHeight() - height) / 2;
		outline.graphics.clear();

		var complete = new Sprite ();
		complete.x = outline.x + width / 2;
		complete.y = outline.y + 60;
		complete.graphics.lineStyle(1, 0xFFFFFFFF);
		complete.graphics.moveTo(-width / 2 + padding, 0);
		complete.graphics.lineTo(width / 2 - padding, 0);
		addChildAt(complete, 0);

		progress.y = outline.y + 60;
		progress.x = outline.x + width / 2;
		progress.graphics.clear();
		progress.graphics.lineStyle(1, color);
		progress.graphics.moveTo(-width / 2 + padding, 0);
		progress.graphics.lineTo(width / 2 - padding, 0);

		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		onEnterFrame(null); // initial render
	}

	public function onEnterFrame(e:Event)
	{
		tileData[9] += 1; // large cog
		tileData[14] += 1; // small cog
		tileData[18] += scaleIncrement; // factory scale
		if (tileData[18] > 1.02 || tileData[18] < 1)
			scaleIncrement = -scaleIncrement;

		outline.graphics.clear();
		tiles.drawTiles(outline.graphics, tileData, true, Tilesheet.TILE_ROTATION | Tilesheet.TILE_SCALE);
	}

	private var scaleIncrement:Float;

	private var tiles:Tilesheet;
	private var tileData:Array<Float>;

}
