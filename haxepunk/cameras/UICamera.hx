package haxepunk.cameras;

import haxepunk.HXP;

/**
 * A static camera that doesn't move or scale.
 */
class UICamera extends StaticCamera
{
	override public function update()
	{
		super.update();
		scale = 1;
		scaleX = 1 / HXP.screen.scaleX;
		scaleY = 1 / HXP.screen.scaleY;
	}
}
