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
		super(HXP.window.width / 2, HXP.window.height / 2);

		acceleration = new Vector3D();
		velocity = new Vector3D();

		sprite = new Spritemap("assets/character.png", 32, 32);
		sprite.add("idle", [8, 8, 8, 9, 8, 8], 2);
		sprite.add("walk", [0, 1, 2, 3, 4, 5, 6, 7], 12);
		sprite.play("idle");
		sprite.centerOrigin();
		addGraphic(sprite);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (Input.check(Key.LEFT))
		{
			acceleration.x = -1;
		}
		if (Input.check(Key.RIGHT))
		{
			acceleration.x = 1;
		}

		velocity += acceleration;

		if (Math.abs(velocity.x) > maxVelocity) velocity.x = maxVelocity * Math.sign(velocity.x);

		if (velocity.x == 0)
		{
			sprite.play("idle");
		}
		else
		{
			// sprite.flipped = velocity.x > 0;
			sprite.play("walk");
		}

		position += velocity;
	}

	private var sprite:Spritemap;
	private var acceleration:Vector3D;
	private var velocity:Vector3D;
	private var maxVelocity:Float = 10;

}
