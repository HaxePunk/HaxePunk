import haxepunk.graphics.ParticleEmitter;

class Effects extends haxepunk.Engine
{
	override public function ready()
	{
		scene.addGraphic(new ParticleEmitter("assets/particle.png"));
	}
}
