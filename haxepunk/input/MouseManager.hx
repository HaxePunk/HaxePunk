package haxepunk.input;

import haxepunk.HXP;
import haxepunk.Entity;

typedef MouseCallback = Void -> Void;

/**
 * Allow Entities to register callbacks on mouse interaction. Based on
 * FlxMouseEventManager by TiagoLr.
 *
 * To use a MouseManager, add it to the scene, then call the `add` method to add
 * Entities with mouse event callbacks. Multiple MouseManagers can be added to
 * the same scene. All entities within one MouseManager must be the same
 * collision type.
 */
class MouseManager extends Entity
{
	var _registeredObjects:Map<Entity, MouseData> = new Map();
	var _collisions:Array<Entity> = new Array();
	var _lastCollisions:Array<Entity> = new Array();
	var _default:MouseData;
	var _lastFallthrough:Bool = false;

	public function new()
	{
		super();
		width = height = 0;
		collidable = false;
		visible = false;
	}

	/**
	 * Adds an object to the MouseManager registry.
	 *
	 * @param	entity
	 * @param	onPress			Callback when mouse is pressed down over this object.
	 * @param	onRelease		Callback when mouse is released over this object.
	 * @param	onEnter			Callback when mouse is this object.
	 * @param	onExit			Callback when mouse moves out of this object.
	 * @param	fallThrough		If true, other objects overlaped by this will still receive mouse events.
	 */
	public function add(
		entity:Entity,
		?onPress:MouseCallback,
		?onRelease:MouseCallback,
		?onEnter:MouseCallback,
		?onExit:MouseCallback,
		fallThrough = false):Entity
	{
		if (this.type == "")
		{
			this.type = entity.type;
		}
		else if (this.type != entity.type)
		{
			throw "Entities added to a MouseManager must all be the same type.";
		}

		var data:MouseData = new MouseData(entity, onPress, onRelease, onEnter, onExit, fallThrough);
		_registeredObjects[entity] = data;
		return entity;
	}

	/**
	 * Default callbacks to use when no other entities collide.
	 */
	public function addDefault(
		?onPress:MouseCallback,
		?onRelease:MouseCallback,
		?onEnter:MouseCallback,
		?onExit:MouseCallback):Void
	{
		_default = new MouseData(null, onPress, onRelease, onEnter, onExit, false);
	}

	/**
	 * Removes a registered object from the registry.
	 */
	public function remove(entity:Entity):Entity
	{
		if (_registeredObjects.exists(entity))
		{
			_registeredObjects.remove(entity);
		}
		return entity;
	}

	/**
	 * Removes all registered objects from the registry.
	 */
	public function clear():Void
	{
		for (key in _registeredObjects.keys())
		{
			_registeredObjects.remove(key);
		}
		while (_lastCollisions.length > 0)
		{
			_lastCollisions.pop();
		}
		_default = null;
	}

	public function getData(entity:Entity):Null<MouseData>
	{
		return _registeredObjects.exists(entity) ? _registeredObjects[entity] : null;
	}

	override public function update():Void
	{
		super.update();

		var collisions:Array<Entity> = _collisions;
		// make sure the mouse is onscreen before checking for collisions
		if (HXP.stage.mouseX >= HXP.screen.x &&
			HXP.stage.mouseY >= HXP.screen.y &&
			HXP.stage.mouseX <= HXP.screen.x + HXP.screen.width &&
			HXP.stage.mouseY <= HXP.screen.y + HXP.screen.height)
		{
			scene.collidePointInto(type, scene.mouseX, scene.mouseY, collisions);
		}

		var fallthrough:Bool = true;
		for (i in 0 ... collisions.length)
		{
			var current = getData(collisions[i]);
			if (current != null && !current.fallThrough)
			{
				while (collisions.length > i + 1)
				{
					collisions.pop();
				}
				fallthrough = false;
				break;
			}
		}

		// onEnter
		for (entity in collisions)
		{
			var current = getData(entity);
			if (current == null) continue;
			if (current.onEnter != null)
			{
				if (_lastCollisions.indexOf(entity) == -1)
				{
					current.onEnter();
				}
			}
		}

		// onPress
		if (Mouse.mousePressed)
		{
			for (entity in collisions)
			{
				var current = getData(entity);
				if (current == null) continue;
				if (current.onPress != null)
				{
					current.onPress();
				}
			}
		}

		// onRelease
		if (Mouse.mouseReleased)
		{
			for (entity in collisions)
			{
				var current = getData(entity);
				if (current == null) continue;
				if (current.onRelease != null)
				{
					current.onRelease();
				}
			}
		}

		// onExit
		for (entity in _lastCollisions)
		{
			var current = getData(entity);
			if (current == null) continue;
			if (current.onExit != null)
			{
				if (collisions.indexOf(entity) == -1)
				{
					current.onExit();
				}
			}
		}

		if (fallthrough)
		{
			if (_default != null)
			{
				if (_default.onEnter != null && !_lastFallthrough) _default.onEnter();
				if (_default.onPress != null && Mouse.mousePressed) _default.onPress();
				if (_default.onRelease != null && Mouse.mouseReleased) _default.onRelease();
			}
		}
		else if (_lastFallthrough)
		{
			if (_default != null)
			{
				if (_default.onExit != null) _default.onExit();
			}
		}

		_collisions = _lastCollisions;
		if (_collisions.length > 0) _collisions.splice(0, _collisions.length);
		_lastCollisions = collisions;
		_lastFallthrough = fallthrough;
	}
}

class MouseData
{
	public var entity:Entity;
	public var onPress:MouseCallback;
	public var onRelease:MouseCallback;
	public var onEnter:MouseCallback;
	public var onExit:MouseCallback;
	public var fallThrough:Bool;

	public function new(
		entity:Entity,
		onPress:MouseCallback,
		onRelease:MouseCallback,
		onEnter:MouseCallback,
		onExit:MouseCallback,
		fallThrough:Bool)
	{
		this.entity = entity;
		this.onPress = onPress;
		this.onRelease = onRelease;
		this.onEnter = onEnter;
		this.onExit = onExit;
		this.fallThrough = fallThrough;
	}
}
