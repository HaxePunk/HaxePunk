package com.haxepunk.masks;

import massive.munit.Assert;
import com.haxepunk.*;
import com.haxepunk.masks.*;

class CollideTest extends TestSuite
{
	@Before
	public function setup()
	{
		var engine = new Engine(640, 480);
		HXP.scene = scene = new Scene();

		hitbox = scene.addMask(new Hitbox(20, 20, -10, -10), "box");
		circle = scene.addMask(new Circle(10), "circle");

		// update entity lists
		engine.update();
	}

	@Test
	public function testHitbox()
	{
		// check that we collide with the circle
		Assert.isTrue(hitbox.collide("circle",  0,  0) != null);
		Assert.isTrue(hitbox.collide("circle", 30, 30) == null);

		circle.x = 40; circle.y = 40; // move circle out of the way

		// this shouldn't collide at all with the circle
		hitbox.moveBy(20, 20, "circle");
		Assert.isTrue(hitbox.x == 20 && hitbox.y == 20);

		// this should collide with the circle and move 20 to the left only
		hitbox.moveBy(20, 20, "circle");
		Assert.isTrue(hitbox.x == 40 && hitbox.y == 30);
	}

	private var scene:Scene;
	private var hitbox:Entity;
	private var circle:Entity;
}
