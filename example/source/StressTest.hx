import haxepunk.*;
import haxepunk.scene.Entity;
import haxepunk.graphics.*;
import haxepunk.math.Vector3;

class StressTest extends Engine
{
	override public function ready()
	{
		super.ready();

		var material = new Material();
		material.firstPass.addTexture(Assets.getTexture("assets/lime.png"));
		var num = Std.int(Math.random() * 50 + 150);
		num = 10000;

		var material = new Material();
		material.firstPass.addTexture(Assets.getTexture("assets/character.png"));

		for (i in 0...num)
		{
			var sprite = new Spritemap(material, 32, 32);
			sprite.add("walk", [0, 1, 2, 3, 4, 5, 6, 7], 12);
			sprite.play("walk");
			sprite.centerOrigin();

			scene.addGraphic(sprite,
				Std.int(Math.random() * -50),
				Math.random() * HXP.window.width,
				Math.random() * HXP.window.height);
		}

		fps = new Text("", 32);
		scene.addGraphic(fps);
	}

	override public function update(deltaTime:Int)
	{
		super.update(deltaTime);
		fps.text = "" + Std.int(HXP.frameRate);
		// trace(HXP.frameRate);
	}

	private var fps:Text;

}
