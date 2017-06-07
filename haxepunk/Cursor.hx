package haxepunk;

import haxepunk.Graphic;
import haxepunk.graphics.Image;

class Cursor extends Entity
{
	/**
	 * Constructor.
	 * @param	graphic		Graphic to assign to the Entity.
	 * @param	mask		Mask to assign to the Entity.
	 */
	override public function new(image:ImageType)
	{
		var img:Image = new Image(image);
		img.smooth = true;
		super(0, 0, img);
	}

	/**
	 * Updates the entitiy coordinates to match the cursor.
	 */
	override public function update()
	{
		super.update();
		x = scene.mouseX;
		y = scene.mouseY;
		var img:Image = cast graphic;
		if (img != null)
		{
			// scale to 1
			img.scaleX = 1 / camera.fullScaleX;
			img.scaleY = 1 / camera.fullScaleY;
		}
	}

	/**
	 * Shows the custom cursor
	 */
	public function show()
	{
		visible = true;
	}

	/**
	 * Hides the custom cursor
	 */
	public function hide()
	{
		visible = false;
	}
}
