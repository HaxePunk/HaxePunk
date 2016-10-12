package com.haxepunk.screen;

/**
 * The default ScaleMode stretches the game area to fill the screen. This can
 * result in non-uniform scaling.
 * @since	2.6.0
 */
class ScaleMode
{
	public var integer:Bool = false;

	/**
	 * @param	integer		Whether scale should be rounded to an integer.
	 */
	public function new(?integer:Bool = false)
	{
		this.integer = integer;
	}

	public function resize(stageWidth:Int, stageHeight:Int)
	{
		HXP.screen.x = HXP.screen.y = 0;
		HXP.screen.width = stageWidth;
		HXP.screen.height = stageHeight;
		HXP.screen.scaleX = stageWidth / HXP.width;
		HXP.screen.scaleY = stageHeight / HXP.height;
		if (integer)
		{
			HXP.screen.scaleX = Std.int(HXP.screen.scaleX);
			HXP.screen.scaleY = Std.int(HXP.screen.scaleY);
		}
	}
}
