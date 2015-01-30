import haxepunk.HXP;
import haxepunk.graphics.*;

class Effects extends haxepunk.Engine
{
	override public function ready()
	{
		emitter = new ParticleEmitter("assets/particle.png");
		emitter.acceleration.y = 0.05;
		emitter.randomVelocity.x = 1;
		emitter.velocity.y = -0.3;
		emitter.angularVelocity = 0.01;
		emitter.randomAngularVelocity = 0.1;
		emitter.growth.x = emitter.growth.y = 0.05;
		emitter.centerOrigin();
		scene.addGraphic(emitter, 0, HXP.window.width / 2, 25);

		particleCount = new haxepunk.graphics.Text("");
		scene.addGraphic(particleCount, 0, 0, 15);
	}

	override public function update(deltaTime:Int)
	{
		emitter.emit(5);
		particleCount.text = "Particles " + emitter.count + "\nFPS " + Std.int(HXP.frameRate);
		super.update(deltaTime);
	}

	private var particleCount:Text;
	private var emitter:ParticleEmitter;
}
