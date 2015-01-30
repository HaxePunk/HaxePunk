import haxepunk.graphics.*;

class Effects extends haxepunk.Engine
{
	override public function ready()
	{
		sprite = new Spritemap("assets/character.png", 32, 32);
		sprite.add("norm_idle", [8, 8, 8, 9], 3, true);
		sprite.add("norm_walk", [0, 1, 2, 3, 4, 5, 6, 7], 19, true);
		sprite.add("norm_jump", [10]);
		sprite.play("norm_walk");
		sprite.centerOrigin();
		scene.addGraphic(sprite, 0, 50, 50);
	}

	override public function update(deltaTime:Int)
	{
		super.update(deltaTime);
		sprite.angle += 0.02;
	}

	private var sprite:Spritemap;
}
