import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.Scene;
import com.haxepunk.screen.ScaleMode;
import com.haxepunk.screen.UniformScaleMode;
import com.haxepunk.screen.FixedScaleMode;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.graphics.Text;
import com.haxepunk.graphics.Tilemap;

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
			mode: new FixedScaleMode(),
			description: "Fixed scale mode: Doesn't stretch on resize.",
		},
		{
			mode: new UniformScaleMode(UniformScaleType.Letterbox),
			description: "Uniform (Letterbox): Cuts off extra space."
		},
		{
		mode: new UniformScaleMode(UniformScaleType.ZoomIn),
		description: "Uniform (ZoomIn): Uses whole screen, zooms in when X/Y ratio is uneven."
		},
		{
			mode: new UniformScaleMode(UniformScaleType.Expand),
			description: "Uniform (Expand): Uses whole screen, zooms out when X/Y ratio is uneven."
		},
	];
	var scaleModeIndex:Int = 0;
	var label:Text;

	public override function begin()
	{
		HXP.stage.color = 0;

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

		Input.define("up", [Key.W, Key.UP]);
		Input.define("down", [Key.S, Key.DOWN]);
		Input.define("left", [Key.A, Key.LEFT]);
		Input.define("right", [Key.D, Key.RIGHT]);
	}

	override public function update()
	{
		if (Input.mousePressed)
		{
			scaleModeIndex = (scaleModeIndex + 1) % scaleModes.length;
			setScaleMode();
		}

		var move = HXP.elapsed * CAMERA_MOVE_PER_SECOND;
		if (Input.check("up")) HXP.camera.y -= move;
		if (Input.check("down")) HXP.camera.y += move;
		if (Input.check("left")) HXP.camera.x -= move;
		if (Input.check("right")) HXP.camera.x += move;

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
