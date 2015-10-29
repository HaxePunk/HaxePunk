import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.masks.*;

class Main extends Engine
{
	override public function ready()
	{
		super.ready();

		haxepunk.debug.Console.enabled = true;

		scene.addMask(new Box(30, 30, -15, -15), 0, 300, 500);
		scene.addMask(new Box(50, 50), 0, 400, 500);
		scene.addMask(new Circle(300, 50, 50), 0, 500, 500);

		var poly = Polygon.createRegular(5);
		poly.angle = -90 * Math.RAD;
		scene.addMask(poly, 0, 200, 250);

		scene.addMask(Polygon.createRegular(8, 75), 0, 400, 200);

		poly = Polygon.createRegular(5, 50);
		poly.x = poly.y = 50;
		poly.angle = 90 * Math.RAD;
		scene.addMask(poly, 0, 50, 50);
	}

}
