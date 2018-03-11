package haxepunk.math;

class RectangleTest
{
	@Test
	public function testSetLeft()
	{
		var r = new Rectangle();
		r.left = 40;
		r.x = 20;
		Assert.areEqual(20, r.x);
		Assert.areEqual(r.left, r.x);
		r.x = 20;
		r.left = 40;
		Assert.areEqual(40, r.left);
		Assert.areEqual(r.x, r.left);
	}

	@Test
	public function testSetTop()
	{
		var r = new Rectangle();
		r.top = 40;
		r.y = 20;
		Assert.areEqual(20, r.y);
		Assert.areEqual(r.top, r.y);
		r.y = 20;
		r.top = 40;
		Assert.areEqual(40, r.top);
		Assert.areEqual(r.y, r.top);
	}

	@Test
	public function testSetWidth()
	{
		var r = new Rectangle(20);
		r.width = 50;
		Assert.areEqual(50, r.width);
		Assert.areEqual(70, r.right);
	}

	@Test
	public function testSetHeight()
	{
		var r = new Rectangle(0, 20);
		r.height = 50;
		Assert.areEqual(50, r.height);
		Assert.areEqual(70, r.bottom);
	}

	@Test
	public function testSetRight()
	{
		var r = new Rectangle(20, 0, 10);
		r.right = 10;
		Assert.areEqual(0, r.x);
		Assert.areEqual(10, r.width); // shouldn't change
	}

	@Test
	public function testSetBottom()
	{
		var r = new Rectangle(0, 20, 0, 15);
		r.bottom = 10;
		Assert.areEqual(-5, r.y);
		Assert.areEqual(15, r.height); // shouldn't change
	}

	@Test
	public function testClone()
	{
		var r = new Rectangle(25, 14, 64, 53);
		var r2 = r.clone();
		Assert.areEqual(r.x, r2.x);
		Assert.areEqual(r.y, r2.y);
		Assert.areEqual(r.width, r2.width);
		Assert.areEqual(r.height, r2.height);
	}

	@Test
	public function testIsEmpty()
	{
		var r = new Rectangle();
		Assert.isTrue(r.isEmpty());
	}

	@Test
	public function testIntersects()
	{
		var r = new Rectangle(8, 10, 8, 10);
		var r2 = new Rectangle(10, 15, 10, 15);
		Assert.isTrue(r.intersects(r2));
	}

	@Test
	public function testContains()
	{
		var r = new Rectangle(8, 10, 8, 10);
		var r2 = new Rectangle(9, 12, 4, 4);
		Assert.isTrue(r.intersects(r2));
	}

	@Test
	public function testMoveAndKeepShape()
	{
		var r = new Rectangle(5, 5, 10, 15);
		r.x = 10;
		r.y = 10;
		Assert.areEqual(20, r.right);
		Assert.areEqual(25, r.bottom);
	}
}
