package haxepunk.screen;

/**
 * Uniform scaling; holds Y virtual resolution constant, and allows visible
 * horizontal area to vary.
 * @since	4.0.0
 */
class FixedHeightScaleMode extends ScaleMode
{
	public function new()
	{
		super(false);
	}

	override public function resize(stageWidth:Int, stageHeight:Int)
	{
		var scale = stageHeight / baseHeight;

		HXP.screen.scaleX = HXP.screen.scaleY = scale;
		HXP.screen.x = HXP.screen.y = 0;
		HXP.screen.width = stageWidth;
		HXP.screen.height = stageHeight;
	}
}
