import haxepunk.graphics.*;

class Effects extends haxepunk.Engine
{
	override public function ready()
	{
		image = new Spritemap("assets/walk.png", 32, 44);
		image.add("walk", [0, 1, 2, 3, 4, 5], 12);
		image.play("walk");
		image.centerOrigin();
		scene.addGraphic(image, 0, 50, 50);
	}

	override public function update(deltaTime:Int)
	{
		super.update(deltaTime);
		image.angle += 0.01;
	}

	private var image:Spritemap;
}
