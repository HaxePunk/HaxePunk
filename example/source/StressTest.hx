import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.scene.Entity;
import haxepunk.graphics.*;
import haxepunk.graphics.Shape;
import haxepunk.graphics.importer.Wavefront;
import haxepunk.math.Vector3;

class ImageTexture extends Entity
{
	public function new(imageName:String)
	{
		super();

		var material = new Material();
		material.firstPass.addTexture(Texture.fromAsset(imageName));
		image = new Image(material);
		image.centerOrigin();
		image.scale.x = 2;
		image.scale.y = 0.5;
		image.alpha = 0.3;
		addGraphic(image);
	}

	override public function update(elapsed:Float)
	{
		x = HXP.window.width / 2;
		y = HXP.window.height / 2;
		image.angle += 1;
		super.update(elapsed);
	}

	private var image:Image;
}

class CubeEntity extends Entity
{
	public function new(material:Material)
	{
		super(Math.random() * HXP.window.width,
			Math.random() * HXP.window.height,
			Math.random() * -500);

		cube = Shape.createCube(material);
		cube.transform.identity();
		cube.transform.scale(15, 15, 15);
		// cube.scale = Math.random() * 30 + 30;
		addGraphic(cube);

		rotate = new Vector3(Math.random() * 2 - 1, Math.random() * 2 - 1, Math.random() * 2 - 1);
	}

	override public function update(elapsed:Float)
	{
		cube.transform.rotateVector3(rotate);
	}

	private var cube:Shape;
	private var rotate:Vector3;
}

class StressTest extends Engine
{
	override public function ready()
	{
		super.ready();

		var material = new Material();
		material.firstPass.addTexture(Texture.fromAsset("assets/lime.png"));
		var numCubes = Std.int(Math.random() * 50 + 150);
		numCubes = 50000;

		var material = new Material();
		material.firstPass.addTexture(new TextureAtlas(lime.Assets.getImage("assets/character.png")));

		for (i in 0...numCubes)
		{
			// scene.add(new CubeEntity(material));

			var sprite = new Spritemap(material, 32, 32);
			sprite.add("walk", [0, 1, 2, 3, 4, 5, 6, 7], 12);
			sprite.play("walk");
			sprite.centerOrigin();

			scene.addGraphic(sprite,
				Std.int(Math.random() * -50),
				Math.random() * HXP.window.width + 50,
				Math.random() * HXP.window.height);
		}

		fps = new Text("", 32);
		scene.addGraphic(fps);
	}

	override public function update(deltaTime:Int)
	{
		super.update(deltaTime);
		fps.text = "" + Std.int(HXP.frameRate);
		trace(HXP.frameRate);
	}

	private var fps:Text;

}
