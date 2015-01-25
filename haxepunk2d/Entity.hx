package haxepunk2d;

/**
 *
 */
class Entity
{
	/**
	 * Create a new Entity, omitted configuration variables will use the default value.
	 *
	 * Default values: { x: 0, y: 0, graphic: null, mask: null }.
	 */
	function new (config : { x:Float, y:Float, graphic:Graphic, mask:Mask });

	/** Unique ID for this entity. Can be used to retrive the entity with `Scene.getByID`. */
	var ID(default, null) : Int;

	/** If the entity respond to collision. */
	var collidable : Bool;

	/** If the entity is drawn. */
	var visible : Bool;

	/** If the entity is updated. */
	var active : Bool;

	/**
	 * Pause updating this entity.
	 */
	function pause():Void;

	/**
	 * Resume updating this entity.
	 */
	function resume():Void;

	/** The position of the center of the entity. */
	var position : Point;

	/** Graphical component to render to the screen. */
	var graphic : GraphicList;

	/** An optional Mask component, used for specialized collision. If not assigned the entity will not do collision checks. */
	var mask : MaskList;

	/** The groups the entity belongs to, used to limit collision and retrival. */
	var groups : Array<String>;

	/** An optional name for the entity. To be used with `Scene.getByName`. */
	var name:String;

	/** The scene the entity was added to. */
	var scene(default, null) : Scene;

	/**
	 * Adds the graphic to the Entity.
	 */
	function addGraphic (g:Graphic) : Graphic;

	/**
	 * Center the graphic in the mask.
	 */
	function centerGraphicInMask () : Bool;

	/**
	 * Center the anchor in the middle of the entity.
	 */
	function centerAnchor();

	/**
	 * Adds the Entity as a child at the end of the frame.
	 */
	@:generic
	public function add<E:Entity> (e:E) : E;

	/**
	 * Adds multiple Entities as children at the end of the frame.
	 */
	public function addMultiple (entities:Array<Entity>);

	/**
	 * Removes the Entity from this entity's children at the end of the frame.
	 */
	@:generic
	public function remove<E:Entity> (e:E) : E;

	/**
	 * Removes all children entities at the end of the frame.
	 */
	public function removeAll () : Int;

	/**
	 * Removes multiple children entities at the end of the frame.
	 */
	public function removeMultiple (entities:Array<Entity>) : Int;

	/**
	 * Get all the matching entities that collide with this.
	 * Can select based on a group, an array of group, a mask, a rectangle or a circle.
	 * You can pass an optional position to be used instead of the actual position of the entity.
	 */
	function collideInto (?e:Either<String,Array<String>/*group(s)*/,Mask,Rectangle,Circle>, ?position:Point) : Array<Entity>;

	/**
	 * Check if the entity collide with either a camera, a point, a rectangle, a line, a circle, an entity or a mask.
	 * You can pass an optional position to be used instead of the actual position of the entity.
	 */
	function collideWith (e:Either<Camera, Point, Rectangle, Line, Circle, Entity, Mask>, ?position:Point) : Bool;

	/**
	 * The distance between this entity and either an entity, a point or a rect.
	 * You can pass an optional position to be used instead of the actual position of the entity.
	 */
	function distanceTo (e:Either<Entity, Point, Rect>, ?position:Point) : Float;

	/**
	 * The quared distance between this entity and either an entity, a point or a rect.
	 * Faster than `distanceTo`.
	 * You can pass an optional position to be used instead of the actual position of the entity.
	 */
	function distanceToSquared (e:Either<Entity, Point, Rect>, ?position:Point) : Float;

	/**
	 * Moves at an angle by a certain amount with an optional set of groups to collide with.
	 */
	function moveAtAngle (angle:Angle, amount:Float, ?solid:Either<String,Array<String>>) : Bool;

	/**
	 * Moves the Entity by a certain amount with an optional set of groups to collide with.
	 */
	function moveBy (p:Point, ?solid:Either<String,Array<String>>) : Bool;

	/**
	 * Moves the Entity to the point [p] with an optional set of groups to collide with.
	 */
	function moveTo (p:Point, ?solid:Either<String,Array<String>>) : Bool;

	/**
	 * Moves the entity toward either an entity, a point or a rect by a certain amount with an optional set of groups to collide with.
	 */
	function moveToward (e:Either<Entity, Point, Rect>, amount:Float, ?solid:Either<String,Array<String>>) : Bool;

	/** The anchor around which the entity rotate. */
	var anchor : Point;

	/** The angle of the entity. */
	var angle : Angle;

	/**
	 * Rotates the entity by a certain angle.
	 */
	function rotateBy (angle:Angle) : Bool;

	// To override
	/**
	 * Override this, called when the entity is added to a scene.
	 */
	function added () : Void;

	/**
	 * Override this, called when a collision occur.
	 */
	function collided (info:Collision) : Bool;

	/**
	 * Override this, called at the beginning of the frame, before rendering.
	 */
	function update () : Void;

	/**
	 * Override this, called when the entity is removed from the scene.
	 */
	function removed () : Void;
}
