import haxepunk.HXP;
import haxepunk.graphics.Draw;
import haxepunk.graphics.Color;

class DrawEntity extends haxepunk.scene.Entity
{

	public function new() { super(); }

	override public function draw()
	{
		var color = new Color();
		color.fromInt(0xFF00FF);
		var x = 0;
		while (x < HXP.window.width)
		{
			var nx = x + 25;
			Draw.line(x, 0, nx, 50, color);
			Draw.line(nx, 50, nx, 0, color);
			x = nx;
		}

		Draw.pixel(70, 70, color);

		color.fromInt(0x0055FF);
		Draw.line(350, 100, 250, 150, color, 10);

		color.fromInt(0xFF00FF);
		Draw.fillRect(15, 150, 150, 50, color);
		color.fromInt(0x0055FF);
		Draw.rect(15, 150, 150, 50, color, 3);
	}

}

class Main extends haxepunk.Engine
{
	override public function ready()
	{
		scene.add(new DrawEntity());
	}
}
