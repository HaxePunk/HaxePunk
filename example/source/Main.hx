import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.graphics.*;
import haxepunk.math.*;

class Main extends Engine
{
	override public function ready()
	{
		super.ready();

		// var image = new Image("assets/lime.jpg");
		// image.centerOrigin();
		// image.scale.x = 0.5;
		// image.scale.y = 0.75;
		// scene.addGraphic(image);

		// scene.camera.clearColor.r = scene.camera.clearColor.g = scene.camera.clearColor.b = 0.6;

		// var text = new haxepunk.graphics.Text("The quick brown fox jumps over the lazy dog.", 16);
		// text.color.r = 0.997;
		// text.color.g = 0.868;
		// text.color.b = 0.462;
		// scene.addGraphic(text, 50, 200);

		// scene.add(new Player());
		scene.addGraphic(new ParticleEmitter("graphics/lime.png"));

		scene.camera.x = -(HXP.window.width / 2);
		scene.camera.y = -(HXP.window.height / 2);
		var material = new Material();
		var pass = material.firstPass;
		pass.depthCheck = true;
		pass.shader = new Shader(lime.Assets.getText("shaders/lighting.vert"), lime.Assets.getText("shaders/lighting.frag"));

		// var mesh = haxepunk.graphics.importer.Wavefront.load("assets/project.obj", material);
		// scene.addGraphic(mesh);

		// fps = new Text("Hello world", 32);
		// scene.addGraphic(fps, scene.camera.x, scene.camera.y);
	}

	override public function update(deltaTime:Int)
	{
		super.update(deltaTime);
		// fps.text = "" + Std.int(HXP.frameRate);
	}

	private var fps:Text;

}
