package haxepunk.screen;

/**
 * The game fills the screen without scaling.
 * @since	2.6.0
 */
class FixedScaleMode extends ScaleMode
{
	public function new()
	{
		super(false);
	}

	override public function resizeScreen(screen:Screen, stageWidth:Int, stageHeight:Int)
	{
		screen.width = stageWidth;
		screen.height = stageHeight;
		screen.scale = screen.scaleX = screen.scaleY = 1;
	}
}
