package haxepunk.graphics;

import haxepunk.graphics.Image;
import haxepunk.math.Vector3;
import haxepunk.math.Matrix4;
import haxepunk.scene.Camera;

class Particle
{
	public var position:Vector3;
	public var velocity:Vector3;
	public var acceleration:Vector3;
	public var scale:Vector3;
	public var growth:Vector3;
	public var angularVelocity:Float = 0;
	public var angle:Float = 0;

	public var alive(get, never):Bool;
	inline private function get_alive():Bool { return _life > 0; }

	public function new(life:Float, ?velocity:Vector3, ?acceleration:Vector3, ?growth:Vector3, angularVelocity:Float=0)
	{
		position = new Vector3();
		scale = new Vector3(1, 1, 1);
		this.velocity = velocity == null ? new Vector3() : velocity;
		this.acceleration = acceleration == null ? new Vector3() : acceleration;
		this.growth = growth == null ? new Vector3() : growth;
		this.angularVelocity = angularVelocity;
		_life = life;
	}

	public function update(elapsed:Float)
	{
		velocity += acceleration;
		position += velocity;
		angle += angularVelocity;
		scale += growth;
		_life -= elapsed;
	}

	private var _life:Float;
}

class ParticleEmitter extends Graphic
{

	public var angularVelocity:Float = 0;
	public var randomAngularVelocity:Float = 0;
	public var velocity:Vector3;
	public var randomVelocity:Vector3;
	public var growth:Vector3;
	public var randomGrowth:Vector3;
	public var acceleration:Vector3;
	public var randomAcceleration:Vector3;

	public var count(get, never):Int;
	inline private function get_count():Int { return _particles.length; }

	public function new(source:ImageSource)
	{
		super();
#if !unit_test
		material = source;
#end
		var texture = material.firstPass.getTexture(0);
		width = texture.width;
		height = texture.height;

		velocity = new Vector3();
		randomVelocity = new Vector3();
		growth = new Vector3();
		randomGrowth = new Vector3();
		acceleration = new Vector3();
		randomAcceleration = new Vector3();

		_particles = new Array<Particle>();
	}

	inline private function randomizeFloat(base:Float, random:Float):Float
	{
		return base + (Math.random() * random) - (random / 2);
	}

	inline private function randomizeVector(base:Vector3, random:Vector3):Vector3
	{
		return new Vector3(
			randomizeFloat(base.x, random.x),
			randomizeFloat(base.y, random.y),
			randomizeFloat(base.z, random.z)
		);
	}

	public function emit(numParticles:Int=1)
	{
		for (i in 0...numParticles)
		{

			_particles.push(new Particle(2,
				randomizeVector(velocity, randomVelocity),
				randomizeVector(acceleration, randomAcceleration),
				randomizeVector(growth, randomGrowth),
				randomizeFloat(angularVelocity, randomAngularVelocity)));
		}
	}

	override public function update(elapsed:Float):Void
	{
		for (p in _particles)
		{
			p.update(elapsed);
		}
	}

	override public function draw(offset:Vector3):Void
	{
		for (p in _particles)
		{
			if (p.alive)
			{
				HXP.spriteBatch.draw(material, offset.x + p.position.x, offset.y + p.position.y, width, height,
					0, 0, width, height, false, false,
					origin.x, origin.y, scale.x * p.scale.x, scale.y * p.scale.y, angle + p.angle);
			}
			else
			{
				_particles.remove(p);
			}
		}
	}

	private var _particles:Array<Particle>;

}
