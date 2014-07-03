import haxepunk.HXP;
import haxepunk.scene.Entity;
import haxepunk.graphics.Spritemap;
import haxepunk.input.Input;
import haxepunk.input.Keyboard;
import haxepunk.math.Vector3D;
import haxepunk.math.Math;

class Player extends Entity
{

	public function new()
	{
		super();

		acceleration = new Vector3D();
		velocity = new Vector3D();

		sprite = new Spritemap("assets/character.png", 32, 32);
		sprite.add("idle", [8, 8, 8, 9, 8, 8], 2);
		sprite.add("walk", [0, 1, 2, 3, 4, 5, 6, 7], 12);
		sprite.play("idle");
		sprite.centerOrigin();
		addGraphic(sprite);

		Input.define("left", [Key.LEFT, Key.A]);
		Input.define("right", [Key.RIGHT, Key.D]);
	}

	override public function update(elapsed:Float)
	{
		acceleration.x = 0;
		super.update(elapsed);
		if (Input.check("left"))
		{
			acceleration.x = -1;
		}
		if (Input.check("right"))
		{
			acceleration.x = 1;
		}

		velocity += acceleration;
		velocity *= drag;

		if (Math.abs(velocity.x) > maxVelocity) velocity.x = maxVelocity * Math.sign(velocity.x);
		else if (Math.abs(velocity.x) < 0.5) velocity.x = 0;

		if (velocity.x == 0)
		{
			sprite.play("idle");
		}
		else
		{
			sprite.flippedX = velocity.x < 0;
			sprite.play("walk");
		}

		position += velocity;

		scene.camera.position.x = position.x - HXP.window.width / 2;
		scene.camera.position.y = position.y - HXP.window.height / 2;
	}

	private var sprite:Spritemap;
	private var acceleration:Vector3D;
	private var velocity:Vector3D;
	private var drag:Float = 0.9;
	private var maxVelocity:Float = 10;

}
