package haxepunk.graphics;

class ImageTest extends haxe.unit.TestCase
{

	public function testFlipped()
	{
		var image = new Image();

		assertFalse(image.flippedX);
		assertFalse(image.flippedY);

		image.flippedY = image.flippedX = true;
		assertEquals(-1.0, image.scale.x);
		assertEquals(-1.0, image.scale.y);

		image.scale.x = 5.2;
		image.scale.y = -3.7;
		assertEquals(5.2, image.scale.x);
		assertEquals(-3.7, image.scale.y);
		assertFalse(image.flippedX);
		assertTrue(image.flippedY);

		image.flippedY = image.flippedX = true;
		assertEquals(-5.2, image.scale.x);
		assertEquals(-3.7, image.scale.y);

		image.flippedY = false;
		assertEquals(3.7, image.scale.y);
	}

}
