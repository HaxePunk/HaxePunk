import haxepunk.Scene;
import haxepunk.Entity;
import haxepunk.graphics.Image;
import haxepunk.HXP;
import haxepunk.Cursor;
import haxepunk.input.Input;
import haxepunk.input.Key;

class MainScene extends Scene
{
	var redCursor:Cursor = new Cursor("graphics/redCursor.png");
	var blueCursor:Cursor = new Cursor("graphics/blueCursor.png");

	var blueBox:Entity;
	var redBox:Entity;
	var blackBox:Entity;

	override public function begin()
	{
		blueBox = new Entity(114, 194, new Image("graphics/blueBox.png"));
		blueBox.setHitbox(92, 92);
		add(blueBox);

		redBox = new Entity(434, 194, new Image("graphics/redBox.png"));
		redBox.setHitbox(92, 92);
		add(redBox);

		blackBox = new Entity(274, 194, new Image("graphics/blackBox.png"));
		blackBox.setHitbox(92, 92);
		add(blackBox);
	}

	override public function update()
	{
		super.update();

		if (blueBox.collidePoint(blueBox.x, blueBox.y, mouseX, mouseY))
		{
			HXP.cursor = blueCursor;
		}
		else if (redBox.collidePoint(redBox.x, redBox.y, mouseX, mouseY))
		{
			HXP.cursor = redCursor;
		}
		else if (blackBox.collidePoint(blackBox.x, blackBox.y, mouseX, mouseY))
		{
			HXP.cursor = null;
		}
	}
}
