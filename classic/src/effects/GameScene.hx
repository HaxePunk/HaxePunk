package effects;

import haxepunk.Entity;
import haxepunk.HXP;
import haxepunk.graphics.tile.Backdrop;
import haxepunk.graphics.emitter.Emitter;
import haxepunk.graphics.Image;
import haxepunk.graphics.atlas.TextureAtlas;
import haxepunk.input.Input;
import haxepunk.input.Mouse;
import haxepunk.utils.Random;

class GameScene extends DemoScene
{

	public function new()
	{
		super();
	}

	public override function begin()
	{
#if !flash
		atlas = TextureAtlas.loadTexturePacker("atlas/assets.xml");
#end

		backdrop = new Backdrop("gfx/tile.png", true, true);
		backdrop.color = 0x555555;
		addGraphic(backdrop);

		smoke = new Emitter("gfx/smoke.png", 16, 16);
		smoke.newType("exhaust", [0]);
		smoke.setMotion("exhaust", 90, 30, 0.5, 360, 10, 0.5);
		smoke.setAlpha("exhaust");

		smokeEntity = addGraphic(smoke);
	}

	public override function end()
	{
#if !flash
		atlas.destroy();
#end
	}

	function onTouch(touch:haxepunk.input.Touch)
	{
		smoke.emit("exhaust", touch.sceneX, touch.sceneY);
	}

	public override function update()
	{
#if mobile
		if (Input.multiTouchSupported)
		{
			Input.touchPoints(onTouch);
		}
		else
		{
#else
		if (true)
		{
#end
			for (i in 0...10)
			{
				smoke.emit("exhaust", mouseX, mouseY);
			}

			if (Mouse.mousePressed)
			{
				smoke.setColor("exhaust", Random.randInt(16777215), Random.randInt(16777215));
			}
		}
		super.update();
	}

	var atlas:TextureAtlas;
	var backdrop:Backdrop;
	var smokeEntity:Entity;
	var smoke:Emitter;

}
