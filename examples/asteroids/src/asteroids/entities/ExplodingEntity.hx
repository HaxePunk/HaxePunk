package asteroids.entities;

import haxepunk.Entity;
import haxepunk.graphics.emitter.Emitter;

class ExplodingEntity extends Entity
{
	var explosionEmitter:Emitter;

	public function new(explosionEmitter:Emitter)
	{
		super();
		this.explosionEmitter = explosionEmitter;
	}

	function explode(x:Float, y:Float, radius:Float)
	{
		for (_ in 0 ... Std.int(radius))
		{
			explosionEmitter.emitInCircle("explode", x, y, radius);
		}
	}
}
