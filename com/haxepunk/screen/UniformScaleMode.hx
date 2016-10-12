package com.haxepunk.screen;

/**
 * ScaleMode that ensures scaleX = scaleY.
 * @since	2.6.0
 */
class UniformScaleMode extends ScaleMode
{
	var letterBox:Bool = false;

	/**
	 * @param	integer		Whether scale should be rounded to an integer.
	 * @param	letterBox	true = zoom out and letterbox, false = zoom in.
	 */
	public function new(?integer:Bool = false, ?letterBox:Bool = false)
	{
		super(integer);
		this.letterBox = letterBox;
	}

	override public function resize(stageWidth:Int, stageHeight:Int)
	{
		var scaleX = stageWidth / HXP.width,
			scaleY = stageHeight / HXP.height;
		var scale = letterBox ? Math.min(scaleX, scaleY) : Math.max(scaleX, scaleY);
		if (integer)
		{
			scale = Std.int(letterBox ? Math.floor(scale) : Math.ceil(scale));
			if (scale < 1) scale = 1;
		}
		HXP.screen.width = Std.int(Math.ceil(HXP.width * scale));
		HXP.screen.height = Std.int(Math.ceil(HXP.height * scale));
		HXP.screen.scaleX = HXP.screen.scaleY = scale;
		HXP.screen.x = Std.int((stageWidth - HXP.screen.width) / 2);
		HXP.screen.y = Std.int((stageHeight - HXP.screen.height) / 2);
	}
}
