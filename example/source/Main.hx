import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.scene.Entity;
import haxepunk.graphics.*;
import haxepunk.graphics.shapes.Cube;
import haxepunk.graphics.importer.Wavefront;
import lime.utils.Vector3D;
import lime.utils.Assets;

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
		// adding cubes with lighting shader at the right side of the screen
		var shader = new Shader([
				{src: Assets.getText("shaders/lighting.vert"), fragment:false},
				{src: Assets.getText("shaders/lighting.frag"), fragment:true}
			]);

		var texture = Texture.create("assets/lime.png");
		var material = new Material(shader);
		material.addTexture(texture);	

		var numCubes = 50;

		for (i in 0...numCubes) {
			var cube = new CubeEntity(material);
			if (cube.x < HXP.windowWidth/2) cube.x += HXP.windowWidth;
			scene.add(cube);
		}

		// adding cubes with default shader at the left side of the screen
		texture = Texture.create("assets/lime.png");
		material = new Material();
		material.addTexture(texture);	

		for (i in 0...numCubes) {
			var cube = new CubeEntity(material);
			if (cube.x > HXP.windowWidth/2) cube.x -= HXP.windowWidth;
			scene.add(cube);
		}
	}
}
