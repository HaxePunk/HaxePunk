import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.scene.Entity;
import haxepunk.graphics.*;
import haxepunk.graphics.shapes.Cube;
import haxepunk.graphics.importer.Wavefront;
import lime.utils.Vector3D;

class ImageTexture extends Entity
{
	public function new(imageName:String)
	{
		super();

		image = new Image(imageName);
		image.centerOrigin();
		image.scale = 0.5;
		image.scaleX = 2;
		image.scaleY = 0.5;
		image.alpha = 0.3;
		addGraphic(image);
	}

	override public function update()
	{
		x = HXP.windowWidth / 2;
		y = HXP.windowHeight / 2;
		image.angle += 1;
		super.update();
	}

	private var image:Image;
}

class CubeEntity extends Entity
{
	public function new(material:Material)
	{
		super(Math.random() * HXP.windowWidth,
			Math.random() * HXP.windowHeight,
			Math.random() * -500);

		cube = new Cube(material);
		cube.scale = Math.random() * 30 + 30;
		addGraphic(cube);

		rotate = new Vector3D(Math.random() * 2 - 1, Math.random() * 2 - 1, Math.random() * 2 - 1);
	}

	override public function update()
	{
		cube.rotation.x += rotate.x;
		cube.rotation.y += rotate.y;
		cube.rotation.z += rotate.z;
	}

	private var cube:Cube;
	private var rotate:Vector3D;
}

class Main extends Engine
{
	override public function init()
	{
		var material = new Material();
		material.addTexture(Texture.create("assets/lime.png"));
		var numCubes = Std.int(Math.random() * 50 + 150);

		var image = new Image("assets/lime.png");
		image.centerOrigin();
		image.scale = 0.2;

		for (i in 0...numCubes)
		{
			scene.add(new CubeEntity(material));

			// scene.addGraphic(image,
			// 	Std.int(Math.random() * -50),
			// 	Math.random() * HXP.windowWidth,
			// 	Math.random() * HXP.windowHeight);
		}
	}
}
