import haxepunk.scene.Entity;
import haxepunk.inputs.Input;
import haxepunk.inputs.Keyboard;
import haxepunk.graphics.*;

class Player extends Entity
{
	public function new()
	{
		super(50, 50);
		Input.define("up", [Key.UP, Key.W]);
		Input.define("down", [Key.DOWN, Key.S]);
		Input.define("left", [Key.LEFT, Key.A]);
		Input.define("right", [Key.RIGHT, Key.D]);

		var material = new Material();
		material.firstPass.addTexture(Texture.fromXPM(lime.Assets.getText("assets/player.xpm")));
		addGraphic(new Image(material));
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (Input.check("up"))
		{
			trace("pressed");
		}
	}
}
