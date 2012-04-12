package platformer;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Tilemap;
import com.haxepunk.masks.Grid;
import platformer.entities.Player;

class GameWorld extends DemoWorld
{

	private static var map:Array<Array<Int>> = [
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1],
		[1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1],
		[1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
		[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1],
		[1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1],
		[1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1],
		[1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1],
		[1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1],
		[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1],
		[1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1],
		[1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1],
		[1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
	];

	public function new()
	{
		super();
	}

	public override function begin()
	{
		add(new Player(HXP.screen.width / 2, HXP.screen.height - 64));

		var mapWidth:Int = map[0].length;
		var mapHeight:Int = map.length;

		// Create tilemap
		var tilemap:Tilemap = new Tilemap("gfx/block.png", mapWidth * 32, mapHeight * 32, 32, 32);
		// Create grid mask
		var grid:Grid = new Grid(tilemap.columns * tilemap.tileWidth, tilemap.rows * tilemap.tileHeight, tilemap.tileWidth, tilemap.tileHeight);

		// Fill the tilemap and grid programatically
		for (i in 0...tilemap.columns)
		{
			for (j in 0...tilemap.rows)
			{
				var tile = map[j][i];
				if (tile != 0) {
					tilemap.setTile(i, j, tile);
					grid.setTile(i, j, true);
				}
			}
		}

		// Create a new entity to use as a tilemap
		var entity:Entity = new Entity();
		entity.graphic = tilemap;
		entity.mask = grid;
		entity.type = "solid";
		add(entity);
	}

}