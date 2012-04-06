package platformer.entities;

import com.haxepunk.HXP;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import platformer.entities.Physics;

private enum JumpStyle
{
	Normal;
	Gravity;
	Disable;
}

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

		sprite.add("down_idle", [19, 19, 19, 20], 4, true);
		sprite.add("down_walk", [11, 12, 13, 14, 15, 16, 17, 18], 12, true);
		sprite.add("down_jump", [21]);

		graphic = sprite;
		setHitbox(16, 32, -8);

		// Set physics properties
		gravity.y = 2.2;
		maxVelocity.y = kJumpForce;
		maxVelocity.x = kMoveSpeed * 4;
		friction.x = 0.92; // floor friction
		friction.y = 0.99; // wall friction

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
			switch (kJumpStyle)
			{
				case Normal:
					acceleration.y = -HXP.sign(gravity.y) * kJumpForce;
				case Gravity:
					gravity.y = -gravity.y;
				case Disable:
			}
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
		var anim:String = "";
		if (gravity.y < 0) {
			anim = "down_";
		}
		if (onGround)
		{
			if (velocity.x == 0)
				sprite.play(anim+"idle");
			else
				sprite.play(anim+"walk");
		}
		else
		{
			sprite.play(anim+"jump");
		}
	}

	private var sprite:Spritemap;

	private static inline var kJumpStyle:JumpStyle = Gravity;
	private static inline var kMoveSpeed:Float = 1.2;
	private static inline var kJumpForce:Int = 20;

}
