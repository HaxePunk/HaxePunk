package haxepunk2d.utils;

/**
 * A pair <width, height>.
 */
class Size
{
	/**  */
	public var width : Float;

	/**  */
	public var height : Float;
	
	/** Half the width. */
	var halfWidth(default, null) : Float;

	/** Half the height. */
	var halfHeight(default, null) : Float;

	/**
	 *
	 */
	public inline function new (width:Float, height:Float)
	{
		this.width = width;
		this.height = height;
	}
}
