package haxepunk.masks;

import massive.munit.Assert;
import haxepunk.*;
import haxepunk.masks.*;

class SlopedGridTest extends TestSuite
{
	@Before
	public function setup()
	{
		grid = new SlopedGrid(320, 320, 32, 32);
		grid.setRect(0, 0, 10, 1, Solid);
		grid.setRect(0, 9, 10, 1, Solid);
		grid.setRect(0, 0, 1, 10, Solid);
		grid.setRect(9, 0, 1, 10, Solid);
		grid.setRect(1, 4, 1, 2, Solid);
		grid.setRect(8, 4, 1, 2, Solid);

		// quick 45 degree slopes
		grid.setTile(1, 1, TopLeft);
		grid.setTile(8, 1, TopRight);
		grid.setTile(1, 8, BottomLeft);
		grid.setTile(8, 8, BottomRight);
		// custom slopes
		grid.setTile(4, 4, BelowSlope, -0.5, 1);
		grid.setTile(5, 4, BelowSlope, 0.5, 0.5);
		grid.setTile(4, 5, AboveSlope, 0.5);
		grid.setTile(5, 5, AboveSlope, -0.5, 0.5);

		grid.setTile(3, 8, BelowSlope, -0.25, 1);
		grid.setTile(4, 8, BelowSlope, -0.75, 0.75);
		grid.setTile(5, 8, BelowSlope, 0.75);
		grid.setTile(6, 8, BelowSlope, 0.25, 0.75);

		grid.setTile(3, 1, AboveSlope, 0.8, -0.5);
		grid.setTile(4, 1, AboveSlope, 0.2, 0.3);
		grid.setTile(5, 1, AboveSlope, -0.2, 0.5);
		grid.setTile(6, 1, AboveSlope, -0.8, 0.3);
	}

	@Test
	public function testCollidePoint()
	{
		// hit
		Assert.isTrue(grid.collidePoint(12, 12));
		Assert.isTrue(grid.collidePoint(150, 156));
		Assert.isTrue(grid.collidePoint(200, 284));
		Assert.isTrue(grid.collidePoint(195, 35));
		Assert.isTrue(grid.collidePoint(300, 80));

		// miss
		Assert.isFalse(grid.collidePoint(69, 178));
		Assert.isFalse(grid.collidePoint(86, 86));
		Assert.isFalse(grid.collidePoint(130, 130));
		Assert.isFalse(grid.collidePoint(190, 156));
		Assert.isFalse(grid.collidePoint(202, 39));
		Assert.isFalse(grid.collidePoint(35, 124));
		Assert.isFalse(grid.collidePoint(206, 280));
	}

	@Test
	public function testCollideCircle()
	{
		var circle = new Circle(24, -24, -24);
		Assert.isFalse(collideCircle(circle, 182, 126));

		var circle = new Circle(8, -8, -8);
		// hit
		Assert.isTrue(collideCircle(circle, -6, 0));
		Assert.isTrue(collideCircle(circle, 0, 0));
		Assert.isTrue(collideCircle(circle, 50, 50));
		Assert.isTrue(collideCircle(circle, 160, 160));
		Assert.isTrue(collideCircle(circle, 175, 146));
		Assert.isTrue(collideCircle(circle, 268, 52));
		Assert.isTrue(collideCircle(circle, 184, 48));
		Assert.isTrue(collideCircle(circle, 202, 40));
		Assert.isTrue(collideCircle(circle, 140, 48));
		Assert.isTrue(collideCircle(circle, 142, 173));
		Assert.isTrue(collideCircle(circle, 49, 266));
		Assert.isTrue(collideCircle(circle, 270, 270));
		Assert.isTrue(collideCircle(circle, 180, 264));
		Assert.isTrue(collideCircle(circle, 114, 278));

		// miss
		Assert.isFalse(collideCircle(circle, 138, 145));
		Assert.isFalse(collideCircle(circle, 73, 176));
		Assert.isFalse(collideCircle(circle, 41, 200));
	}

	@Test
	public function testCollideHitbox()
	{
		var box = new Hitbox(8, 8);
		// hit
		Assert.isTrue(collideBox(box, 1, 1));
		Assert.isTrue(collideBox(box, 28, 156));
		Assert.isTrue(collideBox(box, 42, 42));
		Assert.isTrue(collideBox(box, 171, 42));
		Assert.isTrue(collideBox(box, 195, 36));
		Assert.isTrue(collideBox(box, 274, 262));
		Assert.isTrue(collideBox(box, 270, 41));
		Assert.isTrue(collideBox(box, 111, 278));
		Assert.isTrue(collideBox(box, 200, 278));
		Assert.isTrue(collideBox(box, 158, 158));
		Assert.isTrue(collideBox(box, 154, 35));

		// miss
		Assert.isFalse(collideBox(box, 178, 169));
		Assert.isFalse(collideBox(box, 156, 134));
		Assert.isFalse(collideBox(box, 156, 178));
		Assert.isFalse(collideBox(box, 134, 143));
		Assert.isFalse(collideBox(box, 107, 274));
	}

	@:access(haxepunk.masks.Hitbox)
	private inline function collideBox(box:Hitbox, x:Int, y:Int):Bool
	{
		box._x = x; box._y = y;
		return grid.collideHitbox(box);
	}

	@:access(haxepunk.masks.Circle)
	private inline function collideCircle(circle:Circle, x:Int, y:Int):Bool
	{
		circle._x = x; circle._y = y;
		return circle.collideSlopedGrid(grid);
	}

	private var grid:SlopedGrid;
}
