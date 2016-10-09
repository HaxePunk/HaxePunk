import com.haxepunk.utils.Cursor;
import com.haxepunk.graphics.Image;
import com.haxepunk.utils.Input;

class MyCursor extends Cursor
{
	var blueCursor:Image;
	var redCursor:Image;

	override public function new(?image:Image = null)
	{
		super(image);
		blueCursor = new Image("graphics/blueCursor.png");
		redCursor = new Image("graphics/redCursor.png");
	}

	override public function update() {
		super.update();

		if(collide("blueBox", x, y) != null) {
			graphic = blueCursor;
			Input.hideCursor();
		}

		if(collide("redBox", x, y) != null) {
			graphic = redCursor;
			Input.hideCursor();
		}

		if(collide("blackBox", x, y) != null) {
			graphic = null;
			Input.showCursor();
		}
	}
}