package haxepunk2d.graphics;

typedef ImageConfig = {
	> GraphicConfig,
	clip:Rectangle,
	scaleMode:ScaleMode,
	position:Position
};

/**
 * Performance-optimized non-animated image. Can be drawn to the screen with transformations.
 */
class Image extends Graphics
{
	/** Creates an image from a mask. */
	public static function fromMask(mask:Mask, ?config:ImageConfig):Image;

	/** Creates a new image of a circle. */
	public static function createCircle(radius:Int, ?config:ImageConfig):Image;

	/** Creates a new image of a rectangle. */
	public static function createRectangle(width:Int, height:Int, ?shapeAngle:Angle, ?config:ImageConfig):Image;

	/** Creates a new image of an ellipse. */
	public static function createEllipse(radiusX:Int, radiusY:Int, ?shapeAngle:Angle, ?config:ImageConfig):Image;

	/** Creates a new image of a polygon. */
	public static function createPolygon(points:Array<Point>, ?shapeAngle:Angle, ?config:ImageConfig):Image;

	/** Creates a new image of a regular polygon. */
	public static function createRegularPolygon(sides:Int, radius:Int, ?shapeAngle:Angle, ?config:ImageConfig):Image;

	/** Original width of the texture used for the image. */
	public var textureWidth : Int;

	/** Original height of the texture used for the image. */
	public var textureHeight : Int;

	/** Clipping rectangle for the image. */
	public var clip : Rectangle;

	/** Scale mode used when the source size isn't equal to the image size. */
	public var scaleMode : ScaleMode = ExactFit;

	/** Position of the texture inside the image when the source size isn't equal to the image size. */
	public var position : Position = CENTER_CENTER;

	/**
	 * Create a new image from [source].
	 */
	public function new(source:String, ?config:ImageConfig);
}

enum ScaleMode
{
	Strecht;
	NoScale;
	ExactFit;
	NearestIntergerScale;
	RepeatX;
	RepeatY;
	RepeatXY;
	NineSlice(inside:Rectangle);
}

enum Position
{
	TOP_LEFT;
	TOP_CENTER;
	TOP_RIGHT;
	CENTER_LEFT;
	CENTER_CENTER;
	CENTER_RIGHT;
	BOTTOM_LEFT;
	BOTTOM_CENTER;
	BOTTOM_RIGHT;
}
