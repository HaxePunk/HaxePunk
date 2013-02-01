package platformer;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.atlas.TextureAtlas;
import com.haxepunk.graphics.Tilemap;
import com.haxepunk.graphics.Backdrop;
import com.haxepunk.masks.Grid;
import platformer.entities.Player;

class GameWorld extends DemoWorld
{

	private static var map:Array<Array<Int>> = [
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1],
		[1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 1],
		[1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
		[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1],
		[1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1],
		[1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1],
		[1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1],
		[1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1],
		[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1],
		[1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1],
		[1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1],
		[1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
	];

	public function new()
	{
		super();

#if !flash
		var atlas = TextureAtlas.loadTexturePacker("atlas/assets.xml");
#end
		backdrop = new Backdrop(#if flash "gfx/tile.png" #else atlas.getRegion("tile.png") #end, true, true);
		addGraphic(backdrop, 20);
	}

	public override function begin()
	{
		player = new Player(10 * 32, 11 * 32);
		add(player);

		overlayText.text = "Arrow keys to move - Press 'j' to change jump mode";

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

	public override function update()
	{
		backdrop.x += 1;
		backdrop.y += 2 * HXP.sign(player.gravity.y);
		HXP.camera.x = player.x - HXP.halfWidth;
		HXP.camera.y = player.y - HXP.halfHeight;
		super.update();
	}

	private var player:Player;
	private var backdrop:Backdrop;

}