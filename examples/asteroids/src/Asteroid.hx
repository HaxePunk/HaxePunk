import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.graphics.Spritemap;
import haxepunk.graphics.emitter.Emitter;
import haxepunk.math.MathUtil;


class Asteroid extends Entity
{
	static inline var MOVE_SPEED = 32;
	static inline var TURN_SPEED = 10;

	// keep track of how many asteroids have been created
	public static var asteroidCount:Int = 0;

	var asteroid:Spritemap;
	var size:Int = 0;
	var dir:Float=0;
	var explosionEmitter:Emitter;

	public var angle(default, set):Float = 0;
	function set_angle(a:Float)
	{
		return asteroid.angle = angle = a;
	}

	public function new(explosionEmitter:Emitter, size:Int=0)
	{
		super();

		asteroidCount += 1;
		this.explosionEmitter = explosionEmitter;
		this.size = size;

		if (Std.random(2) == 0)
		{
			x = Std.random(HXP.width);
			y = 0;
		}
		else
		{
			x = 0;
			y = Std.random(HXP.height);
		}

		asteroid = new Spritemap("graphics/asteroid.png", 128, 128);
		asteroid.frame = size;
		asteroid.centerOrigin();

		if (size == 0) angle = Std.random(Std.int(360/5)) * 5;
		dir = Math.random() - 0.5;

		graphic = asteroid;

		width = height = Std.int(128 / Math.pow(2, size));
		originX = originY = Std.int(width/2);

		type = "asteroid";
	}

	override public function update()
	{
		super.update();

		angle += HXP.elapsed * dir * TURN_SPEED;
		var moveSpeed = HXP.elapsed * MOVE_SPEED * (size + 1);
		var moveX = Math.cos(angle * MathUtil.RAD);
		var moveY = Math.sin(angle * MathUtil.RAD);

		x += moveSpeed * moveX;
		y += moveSpeed * moveY;
		// wrap around the screen
		if (x < 0) x += HXP.width;
		if (x > HXP.width) x %= HXP.width;
		if (y < 0) y += HXP.height;
		if (y > HXP.height) y %= HXP.height;
	}

	public function destroy()
	{
		if (!active) return;

		explode(x, y, width/2);
		size += 1;
		if (size > 3)
		{
			// completely destroyed
			active = false;
			scene.remove(this);
			asteroidCount -= 1;
		}
		else
		{
			// break into 2 smaller asteroids
			width = Std.int(width/2);
			height = Std.int(height/2);
			originX = originY = Std.int(width/2);
			asteroid.frame = size;
			dir = 1;
			angle = (angle + 90) % 360;

			var child = new Asteroid(explosionEmitter, size);
			child.x = this.x;
			child.y = this.y;
			child.angle = (angle + 180) / 360;
			child.dir = -1;
			scene.add(child);
		}
	}

	function explode(x:Float, y:Float, radius:Float)
	{
		for (_ in 0 ... Std.int(radius))
		{
			explosionEmitter.emitInCircle("explode", x, y, radius);
		}
	}
}
