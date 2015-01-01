package haxepunk2d;

/**
 * The camera class allow to display a `Scene` unto the screen.
 */
class Camera
{
	/** The position of the center of the camera. */
	public var position:Point;

	/** The width of the camera. */
	public var width : Float;

	/** The height of the camera. */
	public var height : Float;

	/** Half of the width of the camera. */
	public var halfWidth(default, null) : Float;

	/** Half of the height of the camera. */
	public var halfHeight(default, null) : Float;

	/** The angle of the camera.*/
	public var angle : Angle = 0;

	/** Zoom factor, 0.5 = half ; 1 = normal ; 2 = twice ... */
	public var zoom : Float = 1;

	/** Background color for the camera, if null uses `Engine.backgroundColor` */
	public var backgroundColor : Color;

	/** Only display Entity belonging to those groups. If null display all entities. */
	public var groups : Array<String>;

	/** If not null will add a collision shape around the camera with group name [borderType]. */
	public var borderType : String;

	/**
	 * Rotate the camera by [angle].
	 */
	public function rotateBy (angle:Angle);

	/** The shape of the camera.*/
	public var shape:CameraShape = Box;

	/** The filters applied to the entire camera. */
	public var filters : Array<Filter>;

	/**
	 * Check if either a point, a rectangle, a circle or an entity is inside the camera.
	 * If [fully] it needs to be completely inside the camera view.
	 */
	public function isInside(e:Either<Point, Rectangle, Circle, Entity>, fully:Bool=false):Bool;

	/**
	 * Center the camera either on a point, a rectangle, a circle, an entity, a graphic or a mask.
	 */
	public function centerOn(e:Either<Point, Rectangle, Circle, Entity, Graphic, Mask>):Void;
}

/**
 * Possible shapes for a `Camera`.
 */
enum CameraShape
{
	/** A box shape. This is the default value for new `Camera`. */
	Box;

	/** A circle shape. */
	Circle;
}
