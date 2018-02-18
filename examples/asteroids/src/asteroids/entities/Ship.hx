package asteroids.entities;

import haxepunk.HXP;
import haxepunk.graphics.Image;
import haxepunk.graphics.emitter.Particle;
import haxepunk.graphics.emitter.Emitter;
import haxepunk.math.MathUtil;

class Ship extends ExplodingEntity
{
	public static inline var WEAPON_SHOTS:Float = 10;

	static inline var TURN_PER_SEC=180;
	static inline var MOVE_PER_SEC=180;
	static inline var ACCEL_TIME = 0.5;
	static inline var SHOOT_DELAY = 0.15;

	static inline var SHIELD_DURATION:Float = 2.5;
	static inline var SHIELD_RECOVERY_TIME:Float = 60;
	static inline var WEAPON_RECOVERY_TIME:Float = 5;

	public var score:Int = 0;
	public var shields:Float = 1;
	public var weapon:Float = WEAPON_SHOTS;

	var body:Image;
	var bullet:Emitter;

	public var angle(default, set):Float = 0;
	function set_angle(a:Float)
	{
		return body.angle = angle = a;
	}

	public function new(explosionEmitter:Emitter)
	{
		super(explosionEmitter);

		body = new Image("graphics/ship.png");
		body.color = 0x80ffff;
		body.centerOrigin();

		bullet = new Emitter("graphics/bullet.png");
		bullet.newType("bullet");
		bullet.setMotion("bullet", 0, HXP.width, 1);
		bullet.setTrail("bullet", 20, 0.005, 0.95);

		addGraphic(body);
		addGraphic(bullet);

		setHitbox(body.width, body.height, Std.int(body.width / 2), Std.int(body.height / 2));
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
			scene.camera.shake(0.1, 4);
			if (shields > 0)
			{
				shields -= HXP.elapsed / SHIELD_DURATION;
				if (shields <= 0)
				{
					shields = 0;
					explode(x, y, width / 2);
				}
			}
		}
		else if (shields < 1)
		{
			shields += HXP.elapsed / SHIELD_RECOVERY_TIME;
			if (shields > 1) shields = 1;
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
					++score;
				}
			}
			p = p._next;
		}

		if (weapon < WEAPON_SHOTS)
		{
			weapon += WEAPON_SHOTS * HXP.elapsed / WEAPON_RECOVERY_TIME;
			if (weapon > WEAPON_SHOTS) weapon = WEAPON_SHOTS;
		}
	}

	public function rotate(dir:Float=1)
	{
		angle += HXP.elapsed * TURN_PER_SEC * dir;
	}

	public function move(dir:Float=1)
	{
		// speed up and move
		velocity = Math.min(1, velocity + HXP.elapsed / ACCEL_TIME);
		var moveSpeed = velocity * HXP.elapsed * MOVE_PER_SEC * dir;
		x += moveSpeed * Math.cos(MathUtil.RAD * angle);
		y += moveSpeed * Math.sin(MathUtil.RAD * angle);

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
		if (weapon < 1) return;
		--weapon;
		var bx = width / 2 * Math.cos(MathUtil.RAD * angle);
		var by = height / 2 * Math.sin(MathUtil.RAD * angle);
		bullet.emit("bullet", bx, by, angle);
		_lastShot = 1;
	}

	var velocity:Float = 0;
	var moving:Bool = false;
	var _lastShot:Float = 0;
}
