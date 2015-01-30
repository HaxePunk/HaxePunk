package haxepunk.graphics;

import haxepunk.graphics.Image;
import haxepunk.math.Vector3;
import haxepunk.math.Matrix4;
import haxepunk.scene.Camera;

class Particle
{
	public var position:Vector3;
	public var angle:Float = 0;
	public var life:Float = 0;

	public function new()
	{
		position = new Vector3();
	}
}

class ParticleEmitter extends Graphic
{

	public function new(source:ImageSource, frameWidth:Int=0, frameHeight:Int=0)
	{
		super();
#if !unit_test
		material = source;
#end
		var texture = material.firstPass.getTexture(0);
		width = frameWidth == 0 ? texture.width : frameWidth;
		height = frameHeight == 0 ? texture.height : frameHeight;

		origin.y = origin.x = 50;

		particles = new Array<Particle>();
		for (i in 0...10)
		{
			particles.push(new Particle());
		}
	}

	override public function update(elapsed:Float):Void
	{
		for (p in particles)
		{
			// p.position.x = Math.random() * 10 - 5;
			// p.position.y = Math.random() * 10 - 5;
			p.angle = 12 * (Math.PI / 180);
		}
	}

	override public function draw(camera:Camera, offset:Vector3):Void
	{
		if (material == null) return;
		for (p in particles)
		{
			HXP.spriteBatch.draw(material, offset.x, offset.y, width, height);
		}
	}

	private var particles:Array<Particle>;

}
