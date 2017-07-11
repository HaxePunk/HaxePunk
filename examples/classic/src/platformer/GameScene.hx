package platformer;

import haxepunk.Entity;
import haxepunk.graphics.atlas.TextureAtlas;
import haxepunk.graphics.tile.Tilemap;
import haxepunk.graphics.tile.Backdrop;
import haxepunk.masks.Grid;
import haxepunk.math.MathUtil;
import platformer.entities.Player;

class GameScene extends DemoScene
{

	static var map:Array<Array<Int>> = [
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
	}

	public override function begin()
	{
#if !flash
		atlas = TextureAtlas.loadTexturePacker("atlas/assets.xml");
#end
		backdrop = new Backdrop("gfx/tile.png", true, true);
		addGraphic(backdrop, 20);

		player = new Player(11 * 32, 12 * 32);
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
				if (tile != 0)
				{
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

	public override function end()
	{
#if !flash
		atlas.destroy();
#end
	}

	public override function update()
	{
		backdrop.x += 1;
		backdrop.y += 2 * MathUtil.sign(player.gravity.y);
		camera.x = player.x - width / 2;
		camera.y = player.y - height / 2;
		super.update();
	}

	var player:Player;
	var backdrop:Backdrop;
	var atlas:TextureAtlas;

}
