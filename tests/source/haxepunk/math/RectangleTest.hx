package haxepunk.math;

class RectangleTest extends haxe.unit.TestCase
{

	public function testArea()
	{
		var rect = new Rectangle(0, 0, 4, 5);
		assertEquals(20.0, rect.area);
	}

	public function testProperties()
	{
		var rect = new Rectangle();
		assertEquals(4.0, rect.left = 4);
		assertEquals(4.0, rect.x);
		assertEquals(4.0, rect.right);
		assertEquals(6.2, rect.right = 6.2);
		assertEquals(2.2, rect.width);

		assertEquals(-8.1, rect.top = -8.1);
		assertEquals(-8.1, rect.y);
		assertEquals(-8.1, rect.bottom);
		assertEquals(2.5, rect.bottom = 2.5);
		assertEquals(10.6, rect.height);
	}

}
