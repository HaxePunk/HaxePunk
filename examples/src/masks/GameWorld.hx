package masks;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Tilemap;
import com.haxepunk.masks.Circle;
import com.haxepunk.masks.Grid;
import com.haxepunk.masks.Hitbox;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;

class GameWorld extends DemoWorld
{

	public function new()
	{
		super();
	}

	public override function begin()
	{
		// create a circle entity we can move around
		circle = createCircle(25, 25, 30, 0xFF0000FF);

		createGrid(32, 256, 64, 64, [
				[0, 0, 0, 1, 0],
				[1, 0, 1, 1, 1],
				[1, 1, 1, 0, 0]
			], 0xFF00FF00);

		// these are static objects
		createCircle(352, 32, 150, 0xFFFF00FF);
		createBox(128, 196, 400, 50, 0xFF00FFFF);
	}

	private function createBox(x:Int, y:Int, w:Int, h:Int, color:Int = 0xFFFFFFFF):Entity
	{
		var e:Entity = new Entity(x, y);
		var image = Image.createRect(w, h, color);
		e.graphic = image;
		e.setHitbox(w, h);
		e.type = "solid";
		add(e);
		return e;
	}

	private function createCircle(x:Int, y:Int, radius:Int, color:Int = 0xFFFFFFFF):Entity
	{
		var e:Entity = new Entity(x, y);
		e.graphic = Image.createCircle(radius, color);
		e.mask = new Circle(radius);
		e.type = "solid";
		add(e);
		return e;
	}

	private function createGrid(x:Int, y:Int, tileWidth:Int, tileHeight:Int, tiles:Array<Array<Int>>, color: Int = 0xFFFFFFFF):Entity
	{
		var width:Int = tiles[0].length;
		var height:Int = tiles.length;
		var e:Entity = new Entity(x, y);

		// create a tilemap using a single color
		var tilemap:Tilemap = new Tilemap(
				HXP.createBitmap(tileWidth, tileHeight, false, color),
				width * tileWidth, height * tileHeight,
				tileWidth, tileHeight);
		var grid:Grid = new Grid(width * tileWidth, height * tileHeight, tileWidth, tileHeight);

		for (y in 0...height)
		{
			for (x in 0...width)
			{
				if (tiles[y][x] != 0)
				{
					tilemap.setTile(x, y, 1);
					grid.setTile(x, y, true);
				}
			}
		}

		e.mask = grid;
		e.graphic = tilemap;
		e.type = "solid";
		add(e);
		return e;
	}

	public override function update()
	{
		super.update();
		var x:Int = 0, y:Int = 0;

		if (Input.check(Key.LEFT))
			x = -8;

		if (Input.check(Key.RIGHT))
			x = 8;

		if (Input.check(Key.UP))
			y = -8;

		if (Input.check(Key.DOWN))
			y = 8;

		circle.moveBy(x, y, "solid");
	}

	var circle:Entity;

}