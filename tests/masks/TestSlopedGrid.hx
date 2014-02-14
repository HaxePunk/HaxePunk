package masks;

import com.haxepunk.*;
import com.haxepunk.masks.*;

class TestSlopedGrid extends haxe.unit.TestCase
{

	public override function setup()
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

	public function testCollidePoint()
	{
		// hit
		assertTrue(grid.collidePoint(12, 12));
		assertTrue(grid.collidePoint(150, 156));
		assertTrue(grid.collidePoint(200, 284));
		assertTrue(grid.collidePoint(195, 35));
		assertTrue(grid.collidePoint(300, 80));

		// miss
		assertFalse(grid.collidePoint(69, 178));
		assertFalse(grid.collidePoint(86, 86));
		assertFalse(grid.collidePoint(130, 130));
		assertFalse(grid.collidePoint(190, 156));
		assertFalse(grid.collidePoint(202, 39));
		assertFalse(grid.collidePoint(35, 124));
		assertFalse(grid.collidePoint(206, 280));
	}

	public function testCollideCircle()
	{
		var circle = new Circle(8, -8, -8);
		// hit
		assertTrue(collideCircle(circle, -6, 0));
		assertTrue(collideCircle(circle, 0, 0));
		assertTrue(collideCircle(circle, 50, 50));
		assertTrue(collideCircle(circle, 160, 160));
		assertTrue(collideCircle(circle, 175, 146));
		assertTrue(collideCircle(circle, 268, 52));
		assertTrue(collideCircle(circle, 184, 48));
		assertTrue(collideCircle(circle, 202, 40));
		assertTrue(collideCircle(circle, 140, 48));
		assertTrue(collideCircle(circle, 142, 173));
		assertTrue(collideCircle(circle, 49, 266));
		assertTrue(collideCircle(circle, 270, 270));
		assertTrue(collideCircle(circle, 180, 264));
		assertTrue(collideCircle(circle, 114, 278));

		// miss
		assertFalse(collideCircle(circle, 138, 145));
		assertFalse(collideCircle(circle, 73, 176));
		assertFalse(collideCircle(circle, 41, 200));
	}

	@:access(com.haxepunk.masks.Circle)
	private inline function collideCircle(circle:Circle, x:Int, y:Int):Bool
	{
		circle._x = x; circle._y = y;
		return circle.collideSlopedGrid(grid);
	}

	private var grid:SlopedGrid;

}