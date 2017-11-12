package scenes;

import haxepunk.graphics.Graphiclist;
import haxepunk.graphics.Image;
import haxepunk.graphics.text.Text;
import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.graphics.atlas.TextureAtlas;
import haxepunk.graphics.tile.Tilemap;
import haxepunk.graphics.tile.Backdrop;
import haxepunk.masks.Grid;
import haxepunk.input.Input;
import haxepunk.input.Key;
import haxepunk.input.Mouse;
import haxepunk.Scene;
import flash.Lib;
import entities.Bunny;

class GameScene extends Scene
{
	var backdrop:Backdrop;
	var pirate:Image;
	var gravity:Float;
	var incBunnies:Int;
	var atlas:TextureAtlas;
	var numBunnies:Int;

	var bunnies:Array<BunnyImage>;
	var bunnyImage:BunnyImage;
	var bunny:Entity;
	var bunnyList:Graphiclist;

	var tapTime:Float;
	var overlayText:Text;

	public function new()
	{
		super();

		gravity = 5;
		incBunnies = 100;

		numBunnies = incBunnies;

		tapTime = 0;

		atlas = TextureAtlas.loadTexturePacker("atlas/assets.xml");
	}

	override public function begin()
	{
		// background
		backdrop = new Backdrop(atlas.getRegion("grass.png"), true, true);
		addGraphic(backdrop);

		// bunnies
		bunnies = [];
		bunny = new Entity();
		bunnyList = new Graphiclist([]);
		bunny.graphic = bunnyList;
		add(bunny);

		// and some big pirate
		pirate = new Image(atlas.getRegion("pirate.png"));
		addGraphic(pirate);

		overlayText = new Text("numBunnies = " + numBunnies, 0, 0, 0, 0, { color:0x000000, size:30 } );
		overlayText.resizable = true;
		var overlay:Entity = new Entity(0, HXP.screen.height - 40, overlayText);
		add(overlay);

		addBunnies(numBunnies);
	}

	function addBunnies(numToAdd:Int):Void
	{
		var image = atlas.getRegion("bunny.png");
		for (i in 0...(numToAdd))
		{
			bunnyImage = new BunnyImage(image);
			bunnyImage.x = HXP.width * Math.random();
			bunnyImage.y = HXP.height * Math.random();
			bunnyImage.velocity.x = 50 * (Math.random() * 5) * (Math.random() < 0.5 ? 1 : -1);
			bunnyImage.velocity.y = 50 * ((Math.random() * 5) - 2.5) * (Math.random() < 0.5 ? 1 : -1);
			bunnyImage.angle = 15 - Math.random() * 30;
			bunnyImage.angularVelocity = 30 * (Math.random() * 5) * (Math.random() < 0.5 ? 1 : -1);
			bunnyImage.scale = 0.3 + Math.random();
			bunnyList.add(bunnyImage);
			bunnies.push(bunnyImage);
		}

		numBunnies = bunnies.length;
		overlayText.text = "numBunnies = " + numBunnies;
	}

	override public function update()
	{
		var t = Lib.getTimer();
		pirate.x = Std.int((HXP.width - pirate.width) * (0.5 + 0.5 * Math.sin(t / 3000)));
		pirate.y = Std.int(HXP.height - 1.3 * pirate.height + 70 - 30 * Math.sin(t / 100));

		if (Mouse.mousePressed)
		{
			addingBunnies = true;
		}
		if (Mouse.mouseReleased)
		{
			addingBunnies = false;
		}

		if (addingBunnies)
		{
			addBunnies(incBunnies);
		}

		super.update();
	}

	var addingBunnies:Bool = false;
}
