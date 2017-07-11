package haxepunk.screen;

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
	public function new(type:UniformScaleType = Expand, integer:Bool = false)
	{
		super(integer);
		this.type = type;
	}

	override public function resizeScreen(screen:Screen, stageWidth:Int, stageHeight:Int)
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

		screen.scale = scale;
		screen.scaleX = screen.scaleY = 1;
		switch (type)
		{
			case Letterbox:
				// fill only part of the window
				screen.width = Std.int(baseWidth * scale);
				screen.height = Std.int(baseHeight * scale);
				screen.x = Std.int((stageWidth - screen.width) / 2);
				screen.y = Std.int((stageHeight - screen.height) / 2);
			case Expand, ZoomIn:
				// fill the window
				screen.x = screen.y = 0;
				screen.width = stageWidth;
				screen.height = stageHeight;
		}
	}
}
