package com.haxepunk;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

@:bitmap("assets/graphics/preloader/haxepunk.png")
@:dox(hide)
class HaxePunkLogo extends BitmapData {}

class Preloader extends #if (openfl >= "4.4.1") openfl.display.Preloader.DefaultPreloader #else NMEPreloader #end
{
	var largeCog:Sprite;
	var smallCog:Sprite;
	var factory:Sprite;

	public function new()
	{
		super();

		var bmd = new HaxePunkLogo(0, 0);

		scaleIncrement = 0.002;

		var width = 260;
		var height = 340;

		// update bar position
		var color = 0xFFCB6325;
		var padding = 5;

		outline.x = (getWidth() - width) / 2;
		outline.y = (getHeight() - height) / 2;
		outline.graphics.clear();

		// powered by
		var img = new Bitmap(crop(bmd, new Rectangle(0, 0, 274, 58)));
		addChild(img);
		img.x = outline.x;
		img.y = outline.y;

		// haxepunk
		var img = new Bitmap(crop(bmd, new Rectangle(0, 65, 274, 80)));
		addChild(img);
		img.x = outline.x;
		img.y = outline.y + 260;

		// factory
		factory = new Sprite();
		factory.x = outline.x + 187;
		factory.y = outline.y + 260;
		var img = new Bitmap(crop(bmd, new Rectangle(0, 165, 114, 190)));
		img.x = -57;
		img.y = -190;
		factory.addChild(img);
		addChild(factory);

		// large cog
		largeCog = new Sprite();
		largeCog.x = outline.x + 80;
		largeCog.y = outline.y + 190;
		var img = new Bitmap(crop(bmd, new Rectangle(115, 164, 134, 136)));
		img.x = -67;
		img.y = -68;
		largeCog.addChild(img);
		addChild(largeCog);

		// small cog
		smallCog = new Sprite();
		smallCog.x = outline.x + 190;
		smallCog.y = outline.y + 185;
		var img = new Bitmap(crop(bmd, new Rectangle(123, 305, 56, 56)));
		img.x = -28;
		img.y = -28;
		smallCog.addChild(img);
		addChild(smallCog);

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
		largeCog.rotation += 1;
		smallCog.rotation -= 1;
		factory.scaleX += scaleIncrement;
		factory.scaleY += scaleIncrement;
		if (factory.scaleX > 1.02 || factory.scaleX < 1)
			scaleIncrement = -scaleIncrement;

		outline.graphics.clear();
	}

	function crop(bmd:BitmapData, rect:Rectangle):BitmapData
	{
		var cropped = new BitmapData(Std.int(rect.width), Std.int(rect.height));
		cropped.copyPixels(bmd, rect, new Point());
		return cropped;
	}

	private var scaleIncrement:Float;
}
