import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.Scene;
import haxepunk.screen.ScaleMode;
import haxepunk.screen.UniformScaleMode;
import haxepunk.screen.FixedScaleMode;
import haxepunk.input.Input;
import haxepunk.input.Key;
import haxepunk.input.Mouse;
import haxepunk.graphics.text.Text;
import haxepunk.graphics.tile.Tilemap;

typedef ScaleModeInfo =
{
	var mode:ScaleMode;
	var description:String;
}

class MainScene extends Scene
{
	static inline var CAMERA_MOVE_PER_SECOND:Float = 128;

	var scaleModes:Array<ScaleModeInfo> = [
		{
			mode: new ScaleMode(),
			description: "Default scale mode: Stretches to fill the screen.",
		},
		{
			mode: new ScaleMode(true),
			description: "Default scale mode (integer): Stretches to fill the screen, constrains scale to integer values.",
		},
		{
			mode: new FixedScaleMode(),
			description: "Fixed scale mode: Doesn't stretch on resize.",
		},
		{
			mode: new UniformScaleMode(UniformScaleType.Letterbox),
			description: "Uniform (Letterbox): Cuts off extra space."
		},
		{
			mode: new UniformScaleMode(UniformScaleType.Letterbox, true),
			description: "Uniform (Letterbox, integer): Cuts off extra space."
		},
		{
			mode: new UniformScaleMode(UniformScaleType.ZoomIn),
			description: "Uniform (ZoomIn): Uses whole screen, zooms in when X/Y ratio is uneven."
		},
		{
			mode: new UniformScaleMode(UniformScaleType.ZoomIn, true),
			description: "Uniform (ZoomIn, integer): Uses whole screen, zooms in when X/Y ratio is uneven."
		},
		{
			mode: new UniformScaleMode(UniformScaleType.Expand),
			description: "Uniform (Expand): Uses whole screen, zooms out when X/Y ratio is uneven."
		},
		{
			mode: new UniformScaleMode(UniformScaleType.Expand, true),
			description: "Uniform (Expand, integer): Uses whole screen, zooms out when X/Y ratio is uneven."
		},
	];
	var scaleModeIndex:Int = 0;
	var label:Text;

	public override function begin()
	{
		var tilemap = new Tilemap("graphics/tiles.png", 840, 512, 60, 60, 4, 4);
		for (x in 0 ... Std.int(840/60))
		{
			for (y in 0 ... Std.int(480/60))
			{
				tilemap.setTile(x, y, Std.random(4));
			}
		}
		tilemap.smooth = false;
		// make any seams caused by scaling obvious
		tilemap.scale = 1.1;
		addGraphic(tilemap);

		label = new Text("Default\nClick to change scale mode.");
		label.smooth = false;
		addGraphic(label);
		label.y = HXP.height/2;

		setScaleMode();

		Key.define("up", [Key.W, Key.UP]);
		Key.define("down", [Key.S, Key.DOWN]);
		Key.define("left", [Key.A, Key.LEFT]);
		Key.define("right", [Key.D, Key.RIGHT]);
		Key.define("next", [Key.TAB, Key.SPACE, Key.ENTER]);
		Mouse.define("next", MouseButton.LEFT);
		onInputPressed.next.bind(changeScaleMode);
	}

	function changeScaleMode()
	{
		scaleModeIndex = (scaleModeIndex + 1) % scaleModes.length;
		setScaleMode();
	}

	override public function update()
	{
		var move = HXP.elapsed * CAMERA_MOVE_PER_SECOND;
		if (Input.check("up")) camera.y -= move;
		if (Input.check("down")) camera.y += move;
		if (Input.check("left")) camera.x -= move;
		if (Input.check("right")) camera.x += move;

		super.update();
	}

	function setScaleMode()
	{
		label.text = scaleModes[scaleModeIndex].description + "\nClick to change. Arrows to move.";

		HXP.screen.scaleMode = scaleModes[scaleModeIndex].mode;
		HXP.screen.scaleMode.setBaseSize(640, 480);
		HXP.resize(HXP.windowWidth, HXP.windowHeight);
	}
}
