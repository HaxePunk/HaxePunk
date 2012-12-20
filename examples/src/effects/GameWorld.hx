package effects;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.World;
import com.haxepunk.graphics.Backdrop;
import com.haxepunk.graphics.Emitter;
import com.haxepunk.graphics.atlas.TextureAtlas;
import com.haxepunk.utils.Input;

class GameWorld extends DemoWorld
{

	public function new()
	{
		super();

		atlas = TextureAtlas.loadTexturePacker("atlas/assets.xml");

		backdrop = new Backdrop(atlas.getRegion("tile.png"), true, true);
		backdrop.color = 0x555555;
		addGraphic(backdrop);
	}

	public override function begin()
	{
		smoke = new Emitter(atlas.getRegion("smoke.png"), 16, 16);
		smoke.newType("exhaust", [0]);
		smoke.setMotion("exhaust", 90, 30, 0.5, 360, 10, 0.5);
		smoke.setAlpha("exhaust");

		smokeEntity = addGraphic(smoke);
	}

	public override function update()
	{
		for (i in 0...10)
		{
			smoke.emit("exhaust", mouseX, mouseY);
		}

		if (Input.mousePressed)
		{
			smoke.setColor("exhaust", HXP.rand(16777215), HXP.rand(16777215));
		}
		super.update();
	}

	private var atlas:TextureAtlas;
	private var backdrop:Backdrop;
	private var smokeEntity:Entity;
	private var smoke:Emitter;

}