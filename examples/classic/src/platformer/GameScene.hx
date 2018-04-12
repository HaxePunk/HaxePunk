package platformer;

import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.Graphic;
import haxepunk.graphics.atlas.TextureAtlas;
import haxepunk.graphics.tile.Tilemap;
import haxepunk.graphics.tile.Backdrop;
import haxepunk.graphics.shader.SceneShader;
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

	static var s1:SceneShader;
	static var s2:SceneShader;

	public function new()
	{
		super();
		Graphic.smoothDefault = false;
		// use two texture renders to scale up pixel perfect without blurring
		if (s1 == null) s1 = new SceneShader();
		s1.width = Std.int(HXP.width / 2);
		s1.height = Std.int(HXP.height / 2);
		if (s2 == null) s2 = new SceneShader();
		s2.smooth = true;
		shaders = [s1, s2];
	}


	override public function begin()
	{
		atlas = TextureAtlas.loadTexturePacker("atlas/assets.xml");
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

	override public function update()
	{
		backdrop.x += 60 * HXP.elapsed;
		backdrop.y += 60 * HXP.elapsed * MathUtil.sign(player.gravity.y);
		HXP.camera.x = player.x - HXP.halfWidth;
		HXP.camera.y = player.y - HXP.halfHeight;
		super.update();

		s2.width = Std.int(Std.int(Math.max(HXP.screen.scaleX, 1)) * HXP.width);
		s2.height = Std.int(Std.int(Math.max(HXP.screen.scaleY, 1)) * HXP.height);
	}

	var player:Player;
	var backdrop:Backdrop;
	var atlas:TextureAtlas;

}
