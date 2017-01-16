package scenes;

import haxepunk.graphics.Graphiclist;
import haxepunk.graphics.Image;
import haxepunk.graphics.Text;
import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.graphics.atlas.TextureAtlas;
import haxepunk.graphics.Tilemap;
import haxepunk.graphics.Backdrop;
import haxepunk.masks.Grid;
import haxepunk.input.Input;
import haxepunk.Scene;
import flash.Lib;
import entities.Bunny;

class GameScene extends Scene
{
	private var backdrop:Backdrop;
	private var pirate:Image;
	private var gravity:Float;
	private var incBunnies:Int;
	private var atlas:TextureAtlas;
	private var numBunnies:Int;

	private var bunnies:Array<BunnyImage>;
	private var bunnyImage:BunnyImage;
	private var bunny:Entity;
	private var bunnyList:Graphiclist;

	private var tapTime:Float;
	private var overlayText:Text;

	public function new()
	{
		super();

		gravity = 5;
		#if flash
		incBunnies = 50;
		#else
		incBunnies = 100;
		#end

		numBunnies = incBunnies;

		tapTime = 0;

#if !flash
		atlas = TextureAtlas.loadTexturePacker("atlas/assets.xml");
#end
	}

	public override function begin()
	{
		// background
		backdrop = new Backdrop(#if flash "gfx/grass.png" #else atlas.getRegion("grass.png") #end, true, true);
		addGraphic(backdrop);

		// bunnies
		bunnies = [];
		bunny = new Entity();
		bunnyList = new Graphiclist([]);
		bunny.graphic = bunnyList;
		addBunnies(numBunnies);
		add(bunny);

		// and some big pirate
		pirate = new Image(#if flash "gfx/pirate.png" #else atlas.getRegion("pirate.png") #end);
		addGraphic(pirate);

		overlayText = new Text("numBunnies = " + numBunnies, 0, 0, 0, 0, { color:0x000000, size:30 } );
		overlayText.resizable = true;
		var overlay:Entity = new Entity(0, HXP.screen.height - 40, overlayText);
		//overlay.layer = 0;
		add(overlay);
	}

	private function addBunnies(numToAdd:Int):Void
	{
		var image = #if flash "gfx/wabbit_alpha.png" #else atlas.getRegion("bunny.png") #end;
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
	}

	public override function update()
	{
		var t = Lib.getTimer();
		pirate.x = Std.int((HXP.width - pirate.width) * (0.5 + 0.5 * Math.sin(t / 3000)));
		pirate.y = Std.int(HXP.height - 1.3 * pirate.height + 70 - 30 * Math.sin(t / 100));

		tapTime -= HXP.elapsed;
		if (Input.mousePressed)
		{
			if (tapTime > 0)
			{
				addSomeBunnies();
			}
			tapTime = 0.6;
		}

		super.update();
	}

	private function addSomeBunnies():Void
	{
		var more:Int = numBunnies + incBunnies;
		addBunnies(more - numBunnies);
		overlayText.text = "numBunnies = " + numBunnies;
	}
}