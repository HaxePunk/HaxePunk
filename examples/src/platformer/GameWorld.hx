package platformer;

import com.haxepunk.HXP;
import com.haxepunk.World;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Tilemap;
import com.haxepunk.masks.Grid;
import platformer.entities.Character;

class GameWorld extends World
{

	public function new()
	{
		super();
	}

	public override function begin()
	{
		HXP.screen.color = 0x8EDFFA;

		add(new Character(HXP.screen.width / 2, HXP.screen.height - 64));

		// Create tilemap
		var tilemap:Tilemap = new Tilemap("gfx/block.png", HXP.screen.width, HXP.screen.height, 32, 32);
		// Create grid mask
		var grid:Grid = new Grid(tilemap.columns * tilemap.tileWidth, tilemap.rows * tilemap.tileHeight, tilemap.tileWidth, tilemap.tileHeight);

		// Fill the tilemap and grid programatically
		var i:Int;
		for (i in 0...tilemap.columns)
		{
			// top wall
			tilemap.setTile(i, 0, 1);
			grid.setTile(i, 0, true);
			// bottom wall
			tilemap.setTile(i, tilemap.rows - 1, 1);
			grid.setTile(i, tilemap.rows - 1, true);
		}
		for (i in 0...tilemap.rows)
		{
			// left wall
			tilemap.setTile(0, i, 1);
			grid.setTile(0, i, true);
			// right wall
			tilemap.setTile(tilemap.columns - 1, i, 1);
			grid.setTile(tilemap.columns - 1, i, true);
		}

		// Create a new entity to use as a tilemap
		var entity:Entity = new Entity();
		entity.graphic = tilemap;
		entity.mask = grid;
		entity.type = "solid";
		add(entity);
	}

}