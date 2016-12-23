package haxepunk;

/**
 * A group of entities which can be added to or removed from the Scene and
 * moved together. Also supports object pooling.
 * @since	2.6.0
 */
class EntityList<T:Entity> extends Entity
{
	public var entities:Array<T>;

	public var count(get, never):Int;
	function get_count()
	{
		return entities.length;
	}

	public function new()
	{
		entities = new Array();
		_recycled = new List();
		super();
	}

	/**
	 * Add an Entity to this EntityList and its Scene.
	 * @param	entity		The Entity to be added.
	 * @return	The Entity.
	 */
	public function add(entity:T):T
	{
		entities.push(entity);
		if (type != "") entity.type = type;
		if (scene != null) scene.add(entity);
		return entity;
	}

	/**
	 * Remove an Entity from this EntityList and its Scene.
	 * @param	entity		The Entity to be removed.
	 * @return	The Entity.
	 */
	public function remove(entity:T):T
	{
		entities.remove(entity);
		if (scene != null) scene.remove(entity);
		return entity;
	}

	/**
	 * Call a function on all Entities in an EntityList.
	 */
	public function apply(f:(T->Void)):Void
	{
		for (entity in entities) f(entity);
	}

	/**
	 * Call a function on all Entities in an EntityList and return its value.
	 */
	public function map<R>(f:(T->R)):Array<R>
	{
		return [for (entity in entities) f(entity)];
	}

	override public function added()
	{
		super.added();
		if (scene != null)
		{
			for (entity in entities)
			{
				scene.add(entity);
			}
		}
	}

	override public function removed()
	{
		if (scene != null)
		{
			for (entity in entities)
			{
				scene.remove(entity);
			}
		}
		super.removed();
	}

	override function set_x(v:Float):Float
	{
		var diff = v - x;
		for (entity in entities) entity.x += diff;
		return x = v;
	}

	override function set_y(v:Float):Float
	{
		var diff = v - y;
		for (entity in entities) entity.y += diff;
		return y = v;
	}

	override function set_type(value:String):String
	{
		if (value != "") for (entity in entities) entity.type = value;
		return _type = value;
	}

	/**
	 * Returns a new Entity, or a stored recycled Entity if one exists.
	 * @param	addToScene			Add it to the Scene immediately.
	 * @param	constructorArgs		List of the entity constructor arguments (optional).
	 * @return	The new Entity object.
	 */
	public function create(cls:Class<T>, ?constructorArgs:Array<Dynamic>):T
	{
		var entity:T = _recycled.pop();
		if (entity == null || entity.scene != null)
		{
			if (entity != null)
			{
				recycle(entity);
			}

			if (constructorArgs != null)
			{
				entity = Type.createInstance(cls, constructorArgs);
			}
			else
			{
				entity = Type.createInstance(cls, []);
			}
		}
		entity.active = true;

		return add(entity);
	}

	/**
	 * Removes the Entity from the EntityList at the end of the frame and
	 * recycles it. The recycled Entity can then be fetched again by calling the
	 * create() function.
	 * @param	e		The Entity to recycle.
	 * @return	The recycled Entity.
	 */
	public function recycle(entity:T):T
	{
		remove(entity);
		entity.active = false;
		return remove(entity);
	}

	/**
	 * Clears stored reycled Entities of the Class type.
	 */
	public function clearRecycled()
	{
		_recycled.clear();
	}

	var _recycled:List<T>;
}
