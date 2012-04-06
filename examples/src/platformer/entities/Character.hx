package platformer.entities;

import com.haxepunk.HXP;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import platformer.entities.Physics;

// Example character class using simple physics
class Character extends Physics
{

	public function new(x:Float, y:Float)
	{
		super(x, y);

		sprite = new Spritemap("gfx/character.png", 32, 32);

		sprite.add("idle", [8, 8, 8, 9], 4, true);
		sprite.add("walk", [0, 1, 2, 3, 4, 5, 6, 7], 12, true);
		sprite.add("jump", [10]);

		graphic = sprite;
		setHitbox(16, 32, -8);

		// Set physics properties
		gravity.y = 2.6;
		maxVelocity.y = kJumpForce;
		maxVelocity.x = kMoveSpeed * 4;
		friction.x = 0.7; // floor friction
		friction.y = 2.0; // wall friction

		// Define input keys
		Input.define("left", [Key.A, Key.LEFT]);
		Input.define("right", [Key.D, Key.RIGHT]);
		Input.define("jump", [Key.W, Key.SPACE, Key.UP]);
	}

	override public function update()
	{
		acceleration.x = acceleration.y = 0;

		if (Input.check("left"))
			acceleration.x = -kMoveSpeed;

		if (Input.check("right"))
			acceleration.x = kMoveSpeed;

		if (Input.pressed("jump") && onGround)
		{
			acceleration.y = -HXP.sign(gravity.y) * kJumpForce;
			acceleration.x = -HXP.sign(gravity.x) * kJumpForce;
		}

		// Make animation changes here
		setAnimation();

		super.update();

		// Always face the direction we were last heading
		if (velocity.x < 0)
			sprite.flipped = true; // left
		else if (velocity.x > 0)
			sprite.flipped = false; // right
	}

	private function setAnimation()
	{
		if (onGround)
		{
			if (velocity.x == 0)
				sprite.play("idle");
			else
				sprite.play("walk");
		}
		else
		{
			sprite.play("jump");
		}
	}

	private var sprite:Spritemap;

	private static inline var kMoveSpeed:Int = 2;
	private static inline var kJumpForce:Int = 20;

}
