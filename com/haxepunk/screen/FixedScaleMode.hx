package com.haxepunk.screen;

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

	override public function resize(stageWidth:Int, stageHeight:Int)
	{
		HXP.width = HXP.screen.width = stageWidth;
		HXP.height = HXP.screen.height = stageHeight;
		HXP.screen.scaleX = HXP.screen.scaleY = 1;
	}
}
