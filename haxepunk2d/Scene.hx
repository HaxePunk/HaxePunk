package haxepunk2d;

/**
 * A scene holds entities and cameras.
 */
class Scene
{
	/** The cameras of the scene. */
	public var cameras : Array<Camera>;

	/** The pool of entity of the scene. */
	public var pool : EntityPool;

	/** The bounds of the scene. This is not updated but recalculated when needed, reading this variable might be slow. */
	public var bounds(get,never):Rectangle;

	/** If the scene should render. */
	public var visible : Bool;

	/**
	 * Hide the scene.
	 */
	public function hide();

	/**
	 * Show the scene.
	 */
	public function show();

	/** If the scene, and its entities, should update. */
	public var active:Bool;

	/**
	 * Pause updating this scene.
	 */
	public function pause():Void;

	/**
	 * Resume updating this scene.
	 */
	public function resume();

	/** The number of entity currently in the scene. */
	public var entityCount:Int;

	/** The number of group currently in the scene. */
	public var uniqueGroups:Int;

	/** The number of class currently in the scene. */
	public var uniqueClasses:Int;
	/**
	 * The number of entity of a specific class currently in the scene.
	 */
	public function classCount(c:Class<Entity>):Int;

	/**
	 * The number of entity of a specific group or groups currently in the scene.
	 * The entity does not need to belongs to all groups by default, unless [matchAll] is set to true.
	 * An entity is never counted twice.
	 */
	public function groupCount(e:Either<String,Array<String>>, matchAll:Bool=false):Int;

	/**
	 * If the layer is visible.
	 */
	public function getLayerVisibility(layer:Int):Bool;

	/**
	 * Set the layer visibility.
	 */
	public function setLayerVisibility(layer:Int, value:Bool):Bool;

	/**
	 * Get the nearest entity to either a class, an entity, a point or a rectangle.
	 * You can limit the search to a single or multiple groups.
	 * The entity does not need to belongs to all groups by default, unless [matchAll] is set to true.
	 */
	public function nearestTo(e:Either<Class<Entity>,Entity,Point,Rectangle>, ?groups:Either<String,Array<String>, matchAll:Bool=false):Entity

	/** If there is at least a tween in the scene. */
	public var hasTween(get, never):Bool;

	/** The number of tween in the scene. */
	public var tweenCount:Int;

	/** If the tweens should be updated. */
	public var tweening:Bool;

	/**
	 * Pause updating the tweens of this scene.
	 */
	public function pauseTweening();

	/**
	 * Resume updating the tweens of this scene.
	 */
	public function resumeTweening();

	/**
	 * Cancel all tweens of this scene.
	 */
	public function cancelAllTweens();

	/**
	 * Returns all the entity added to the scene.
	 */
	public function getAll():Array<Entity>;

	/**
	 * Returns all the entity added to the scene from a certain class.
	 */
	public function getAllOfClass(c:Class<Entity>):Array<Entity>;

	/**
	 * Returns all the entity added to the scene from a single or multiple groups.
	 * The entities do not need to belong to all groups by default, unless [matchAll] is set to true.
	 * An entity is never included twice.
	 */
	public function getAllOfGroup(groups:Either<String,Array<String>>, matchAll:Bool=false):Array<Entity>;

	/**
	 * Get the entity from its ID.
	 * If no entity have this ID returns null.
	 */
	public function getByID(name:String):Entity;

	/**
	 * Get the entity from its name.
	 * If no entity have this name returns null.
	 * If more than one entity are found returns the first one (undeterministic).
	 */
	public function getByName(name:String):Entity;

	/**
	 * Returns whether an entity with the name [name] exists.
	 */
	public function exists(name:String):Bool;

	/**
	 * Adds the Entity to the Scene at the end of the frame.
	 */
	public function add<E:Entity> (e:E) : E;

	/**
	 * Adds multiple Entities to the scene at the end of the frame.
	 */
	public function addMultiple (entities:Array<Entity>);

	/**
	 * Adds an Entity to the Scene with the Graphic object.
	 * If no position is specified the default value will be (0, 0).
	 */
	public function addGraphic (g:Graphic, ?position:Point) : Entity;

	/**
	 * Adds an Entity to the Scene with the Mask object.
	 * If no position is specified the default value will be (0, 0).
	 */
	public function addMask (m:Mask, position:Point) : Entity;

	/**
	 * Removes the Entity from the Scene at the end of the frame.
	 */
	public function remove<E:Entity> (e:E) : E;

	/**
	 * Removes all Entities from the Scene at the end of the frame.
	 */
	public function removeAll () : Int;

	/**
	 * Removes multiple Entities from the scene at the end of the frame.
	 */
	public function removeMultiple (entities:Array<Entity>) : Int;

	/**
	 * Return all entities that collide with either the circle, rectangle or mask.
	 */
	public function collideInto (?e:Either<Circle, Rectangle, Mask>) : Array<Entity>;

	/**
	 * Return the first entity that collide with either the point, rectangle, line, circle or entity.
	 * An entity layer equals the minimal layer value of its graphics' layer.
	 */
	public function collideWith (e:Either<Point, Rectangle, Line, Circle, Entity>) : Entity;

	// To override
	/**
	 * Override this, called when the scene becomes the active scene.
	 */
	public function begin () : Void;

	/**
	 * Override this, called at the beginning of the scene, before rendering and entities update.
	 */
	public function update () : Void;

	/**
	 * Override this, called when the scene is no longer the active scene.
	 */
	public function end () : Void;
}
