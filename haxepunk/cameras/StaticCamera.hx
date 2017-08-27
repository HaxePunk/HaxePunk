package haxepunk.cameras;

/**
 * A camera that doesn't move.
 */
class StaticCamera extends Camera
{
	override public function update()
	{
		super.update();
		x = y = 0;
	}
}
