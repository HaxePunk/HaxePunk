package asteroids.scenes;

import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.Scene;
import haxepunk.graphics.emitter.Emitter;
import haxepunk.graphics.shader.SceneShader;
import haxepunk.graphics.text.BitmapText;
import haxepunk.input.Input;
import haxepunk.input.Key;
import haxepunk.input.Mouse;
import haxepunk.utils.Ease;
import haxepunk.pixel.PixelArtScaler;

class MainScene extends Scene
{
	static inline var ASTEROID_TIME = 2;
	static inline var MAX_ASTEROIDS = 8;

	var score(default, set):Int = -1;
	inline function set_score(v:Int)
	{
		if (v != score)
		{
			scoreLabel.text = "SCORE: " + StringTools.lpad(Std.string(v), "0", 8);
			scoreLabel.x = (HXP.width - scoreLabel.textWidth) / 2;
			scoreLabel.y = HXP.height - scoreLabel.textHeight * 1.25;
		}
		return score = v;
	}

	var ship:Ship;
	var explosionEmitter:Emitter;
	var spawnAsteroid:Float = 0;

	var scoreLabel:BitmapText;
	var shieldsMeter:CircularMeter;
	var weaponMeter:CircularMeter;

	var shader:PixelArtScaler;

	function new()
	{
		super();

		Key.define("shoot", [Key.SPACE, Key.K]);
		Mouse.define("shoot", MouseButton.LEFT);
		Key.define("left", [Key.A, Key.LEFT]);
		Key.define("right", [Key.D, Key.RIGHT]);
		Key.define("up", [Key.W, Key.UP]);
		Key.define("down", [Key.S, Key.DOWN]);
		Key.define("shader", [Key.Z]);

		explosionEmitter = new Emitter("graphics/explosion.png");
		explosionEmitter.newType("explode");
		explosionEmitter.setMotion("explode", 0, 12, 0.5, 360, 4, 0.25);
		explosionEmitter.setTrail("explode", 2, 0.05, 0.9);
		explosionEmitter.setAlpha("explode", 1, 0, Ease.quadInOut);
		explosionEmitter.setScale("explode", 1, 1.5, Ease.quadInOut);

		var e = new Entity(0, 0, explosionEmitter);
		e.layer = -1;
		add(e);

		ship = new Ship(explosionEmitter);
		ship.x = HXP.width / 2;
		ship.y = HXP.height / 2;
		add(ship);

		for (i in 0 ... 4) newAsteroid();

		onInputPressed.shoot.bind(ship.shoot);
		onInputPressed.shader.bind(toggleShader);

		scoreLabel = new BitmapText("SCORE: 00000000", {size: 24});
		addGraphic(scoreLabel);
		score = 0;

		shieldsMeter = new CircularMeter();
		shieldsMeter.color = 0x44aa00;
		weaponMeter = new CircularMeter();
		weaponMeter.color = 0x5f5fd3;
		shieldsMeter.x = shieldsMeter.y = 32;
		weaponMeter.y = shieldsMeter.y;
		weaponMeter.x = shieldsMeter.x + 64;
		addGraphic(shieldsMeter);
		addGraphic(weaponMeter);
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

		if (ship.score > 0)
		{
			score += ship.score;
			ship.score = 0;
		}

		shieldsMeter.fill = ship.shields;
		weaponMeter.fill = ship.weapon / Ship.WEAPON_SHOTS;
	}

	function newAsteroid()
	{
		if (Asteroid.asteroidCount < MAX_ASTEROIDS)
		{
			var asteroid = new Asteroid(explosionEmitter);
			add(asteroid);
		}
	}

	function toggleShader()
	{
		if (shader != null)
		{
			remove(shader);
			shader = null;
		}
		else shader = PixelArtScaler.activate();
	}
}
