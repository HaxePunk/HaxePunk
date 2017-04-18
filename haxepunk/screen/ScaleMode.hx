package haxepunk.screen;

/**
 * The default ScaleMode stretches the game area to fill the screen. This can
 * result in non-uniform scaling.
 * @since	2.6.0
 */
class ScaleMode
{
	public var integer:Bool = false;

	var baseWidth:Int = 0;
	var baseHeight:Int = 0;

	/**
	 * @param	integer		Whether scale should be rounded to an integer.
	 */
	public function new(integer:Bool = false)
	{
		this.integer = integer;
		setBaseSize(HXP.width, HXP.height);
	}

	public function setBaseSize(width:Int = -1, height:Int = -1)
	{
		if (width == -1) width = HXP.width;
		if (height == -1) height = HXP.height;
		baseWidth = width;
		baseHeight = height;
	}

	public function resize(stageWidth:Int, stageHeight:Int)
	{
		HXP.screen.x = HXP.screen.y = 0;
		HXP.screen.scale = 1;
		HXP.screen.scaleX = stageWidth / baseWidth;
		HXP.screen.scaleY = stageHeight / baseHeight;
		HXP.screen.width = stageWidth;
		HXP.screen.height = stageHeight;

		if (integer)
		{
			HXP.screen.scaleX = Std.int(Math.max(1, HXP.screen.scaleX));
			HXP.screen.scaleY = Std.int(Math.max(1, HXP.screen.scaleY));
		}
	}
}
