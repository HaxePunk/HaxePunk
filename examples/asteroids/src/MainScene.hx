import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.Scene;
import haxepunk.graphics.emitter.Emitter;
import haxepunk.graphics.shader.SceneShader;
import haxepunk.input.Input;
import haxepunk.input.Key;
import haxepunk.input.Mouse;
import haxepunk.utils.Ease;


class MainScene extends Scene
{
	static inline var ASTEROID_TIME = 2;
	static inline var MAX_ASTEROIDS = 8;

	var ship:Ship;
	var explosionEmitter:Emitter;
	var spawnAsteroid:Float = 0;

	override public function begin()
	{
		ship = new Ship();
		ship.x = HXP.width/2;
		ship.y = HXP.height/2;
		add(ship);

		Key.define("shoot", [Key.SPACE, Key.K]);
		Mouse.define("shoot", MouseButton.LEFT);
		Key.define("left", [Key.A, Key.LEFT]);
		Key.define("right", [Key.D, Key.RIGHT]);
		Key.define("up", [Key.W, Key.UP]);
		Key.define("down", [Key.S, Key.DOWN]);

		explosionEmitter = new Emitter("graphics/explosion.png");
		explosionEmitter.newType("explode");
		explosionEmitter.setMotion("explode", 0, 12, 0.5, 360, 4, 0.25);
		explosionEmitter.setTrail("explode", 2, 0.05, 0.9);
		explosionEmitter.setAlpha("explode", 1, 0, Ease.quadInOut);
		explosionEmitter.setScale("explode", 1, 1.5, Ease.quadInOut);

		var e = new Entity(0, 0, explosionEmitter);
		e.layer = -1;
		add(e);

		for (i in 0 ... 4) newAsteroid();

		shaders = [SceneShader.fromAsset("shaders/pixel.frag")];

		onInputPressed.shoot.bind(ship.shoot);
	}

	override public function update()
	{
		spawnAsteroid += HXP.elapsed / ASTEROID_TIME;
		if (spawnAsteroid >= 1)
		{
			spawnAsteroid -= 1;
			newAsteroid();
		}

		if (Input.check("up")) ship.move(1);
		if (Input.check("down")) ship.move(-0.5);
		if (Input.check("left")) ship.rotate(1);
		if (Input.check("right")) ship.rotate(-1);

		super.update();
	}

	function newAsteroid()
	{
		if (Asteroid.asteroidCount < MAX_ASTEROIDS)
		{
			var asteroid = new Asteroid(explosionEmitter);
			add(asteroid);
		}
	}
}
