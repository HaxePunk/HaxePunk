package masks;

import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.Scene;
import haxepunk.graphics.Image;
import haxepunk.masks.Circle;
import haxepunk.masks.Hitbox;
import haxepunk.masks.SlopedGrid;
import haxepunk.input.Input;

class SlopedScene extends DemoScene
{

	public function new()
	{
		super();
	}

	public override function begin()
	{
		var grid = new SlopedGrid(320, 320, 32, 32);
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
		addMask(grid, "mask", 100, 100);

		entity = new Entity(0, 0);
		image = Image.createCircle(8, 0xFFFFFFFF);
		image.centerOrigin();
		entity.mask = new Circle(8, -8, -8);
		entity.graphic = image;
		add(entity);

		HXP.engine.console.debugDraw = true;
	}

	public override function update()
	{
		entity.x = mouseX;
		entity.y = mouseY;
		if (entity.collide("mask", entity.x, entity.y) != null)
		{
			image.color = 0xFF0000;
		}
		else
		{
			image.color = 0xFFFFFF;
		}
		super.update();
	}

	var entity:Entity;
	var image:Image;

}