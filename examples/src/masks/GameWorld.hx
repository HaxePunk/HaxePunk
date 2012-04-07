package masks;

import com.haxepunk.World;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.masks.Circle;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;

class GameWorld extends World
{

	public function new()
	{
		super();
	}

	private function createBox(x:Int, y:Int, w:Int, h:Int, color:Int = 0xFFFFFFFF):Entity
	{
		var e:Entity = new Entity(x, y);
		e.graphic = Image.createRect(w, h, color);
		e.setHitbox(w, h);
		e.type = "solid";
		add(e);
		return e;
	}

	private function createCircle(x:Int, y:Int, radius:Int, color:Int = 0xFFFFFFFF):Entity
	{
		var e:Entity = new Entity(x, y);
		e.graphic = Image.createCircle(radius, color);
		e.mask = new Circle(radius);
		e.type = "solid";
		add(e);
		return e;
	}

	public override function begin()
	{
		circle = createCircle(25, 25, 40, 0xFF0000FF);

		createCircle(300, 50, 50, 0xFFFF00FF);
		createBox(150, 200, 50, 50, 0xFF00FFFF);
	}

	public override function update()
	{
		super.update();
		var x:Int = 0, y:Int = 0;

		if (Input.check(Key.LEFT))
			x = -5;

		if (Input.check(Key.RIGHT))
			x = 5;

		if (Input.check(Key.UP))
			y = -5;

		if (Input.check(Key.DOWN))
			y = 5;

		circle.moveBy(x, y, "solid", true);
	}

	var circle:Entity;

}