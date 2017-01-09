package com.haxepunk.screen;

@:enum
abstract UniformScaleType(Int)
{
	/**
	 * When the screen ratio changes, zoom in (show less of the game.)
	 */
	var ZoomIn = 0;
	/**
	 * When the screen ratio changes, zoom out (show more of the game.)
	 */
	var Expand = 1;
	/**
	 * When the screen ratio changes, zoom out and hide the overflow behind
	 * black bars.
	 */
	var Letterbox = 2;
}

/**
 * ScaleMode that ensures scaleX = scaleY.
 * @since	2.6.0
 */
class UniformScaleMode extends ScaleMode
{
	var type:UniformScaleType;

	/**
	 * @param	integer		Whether scale should be rounded to an integer.
	 * @param	mode
	 */
	public function new(type:UniformScaleType = Expand, ?integer:Bool = false)
	{
		super(integer);
		this.type = type;
	}

	override public function resize(stageWidth:Int, stageHeight:Int)
	{
		var scaleX = stageWidth / baseWidth,
			scaleY = stageHeight / baseHeight;
		var zoomIn = type == ZoomIn,
			expand = type == Expand;
		var scale = zoomIn ? Math.max(scaleX, scaleY) : Math.min(scaleX, scaleY);
		if (integer)
		{
			scale = Std.int(zoomIn ? Math.ceil(scale) : Math.floor(scale));
			if (scale < 1) scale = 1;
		}

		HXP.screen.scaleX = HXP.screen.scaleY = scale;
		if (expand)
		{
			// fill the window and offset the camera
			HXP.screen.x = HXP.screen.y = 0;
			HXP.screen.offsetX = Std.int((stageWidth - baseWidth * scale) / 2);
			HXP.screen.offsetY = Std.int((stageHeight - baseHeight * scale) / 2);
			HXP.screen.width = stageWidth;
			HXP.screen.height = stageHeight;
		}
		else
		{
			// visible area may not match the window
			HXP.screen.offsetX = HXP.screen.offsetY = 0;
			HXP.screen.width = Std.int(Math.ceil(baseWidth * scale));
			HXP.screen.height = Std.int(Math.ceil(baseHeight * scale));
			HXP.screen.x = Std.int((stageWidth - HXP.screen.width) / 2);
			HXP.screen.y = Std.int((stageHeight - HXP.screen.height) / 2);
		}
	}
}
