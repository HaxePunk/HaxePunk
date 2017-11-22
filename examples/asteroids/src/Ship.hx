import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.graphics.Image;
import haxepunk.graphics.emitter.Particle;
import haxepunk.graphics.emitter.Emitter;
import haxepunk.math.MathUtil;


class Ship extends Entity
{
	static inline var TURN_PER_SEC=180;
	static inline var MOVE_PER_SEC=180;
	static inline var ACCEL_TIME = 0.5;
	static inline var SHOOT_DELAY = 0.15;

	var body:Image;
	var bullet:Emitter;

	public var angle(default, set):Float = 0;
	function set_angle(a:Float)
	{
		return body.angle = angle = a;
	}

	public function new()
	{
		super();

		body = new Image("graphics/ship.png");
		body.color = 0x80ffff;
		body.centerOrigin();

		bullet = new Emitter("graphics/bullet.png");
		bullet.newType("bullet");
		bullet.setMotion("bullet", 0, HXP.width, 1);
		bullet.setTrail("bullet", 20, 0.005, 0.95);

		addGraphic(body);
		addGraphic(bullet);

		setHitbox(body.width, body.height, Std.int(body.width/2), Std.int(body.height/2));
	}

	@:access(haxepunk.graphics.emitter.Emitter)
	@:access(haxepunk.graphics.emitter.Particle)
	@:access(haxepunk.graphics.emitter.ParticleType)
	override public function update()
	{
		super.update();

		// decelerate if not moving
		if (!moving) velocity = 0;
		moving = false;

		if (_lastShot > 0) _lastShot = Math.max(0, _lastShot - HXP.elapsed / SHOOT_DELAY);

		// hack: check bullet particles for collision with asteroids
		var p:Particle = bullet._particle,
			hit:Asteroid = null,
			t:Float = 0, td:Float = 0;

		hit = cast collide("asteroid", x, y);
		if (hit != null)
		{
			HXP.screen.shake(0.1,4);
		}

		while (p != null)
		{
			if (p._time > 0)
			{
				t = p._time / p._duration;
				td = (p._type._ease == null) ? t : p._type._ease(t);
				if ((hit = cast collide("asteroid", p.x(td), p.y(td))) != null)
				{
					// destroy the asteroid
					hit.destroy();
					// remove this particle after it collides with something
					p._time = 1;
				}
			}
			p = p._next;
		}
	}

	public function rotate(dir:Float=1)
	{
		angle += HXP.elapsed * TURN_PER_SEC * dir;
	}

	public function move(dir:Float=1)
	{
		// speed up and move
		velocity = Math.min(1, velocity + HXP.elapsed/ACCEL_TIME);
		var moveSpeed = velocity * HXP.elapsed * MOVE_PER_SEC * dir;
		x += moveSpeed * Math.cos(MathUtil.RAD*angle);
		y += moveSpeed * Math.sin(MathUtil.RAD*angle);

		// wrap around the screen
		if (x < 0) x += HXP.width;
		if (x > HXP.width) x %= HXP.width;
		if (y < 0) y += HXP.height;
		if (y > HXP.height) y %= HXP.height;

		moving = true;
	}


	public function shoot()
	{
		if (_lastShot > 0) return;
		var bx = width/2 * Math.cos(MathUtil.RAD*angle);
		var by = height/2 * Math.sin(MathUtil.RAD*angle);
		bullet.emit("bullet", bx, by, angle);
		_lastShot = 1;
	}

	var velocity:Float=0;
	var moving:Bool=false;
	var _lastShot:Float=0;
}
