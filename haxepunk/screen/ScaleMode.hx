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
	public function new(?integer:Bool = false)
	{
		this.integer = integer;
		setBaseSize(HXP.width, HXP.height);
	}

	public function setBaseSize(?width:Int, ?height:Int)
	{
		if (width == null) width = HXP.width;
		if (height == null) height = HXP.height;
		baseWidth = width;
		baseHeight = height;
	}

	public function resize(stageWidth:Int, stageHeight:Int)
	{
		HXP.screen.x = HXP.screen.y = 0;
		HXP.screen.offsetX = HXP.screen.offsetY = 0;
		var scaleXMult = HXP.screen._scaleXMult,
			scaleYMult = HXP.screen._scaleYMult;
		HXP.screen.scaleX = scaleXMult * stageWidth / baseWidth;
		HXP.screen.scaleY = scaleYMult * stageHeight / baseHeight;
		HXP.screen._scaleXMult = scaleXMult;
		HXP.screen._scaleYMult = scaleYMult;
		HXP.screen.width = stageWidth;
		HXP.screen.height = stageHeight;

		if (integer)
		{
			HXP.screen.scaleX = Std.int(HXP.screen.scaleX);
			HXP.screen.scaleY = Std.int(HXP.screen.scaleY);
		}
	}
}
