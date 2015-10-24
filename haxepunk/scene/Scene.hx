package haxepunk.scene;

import haxe.ds.StringMap;
import haxepunk.debug.Console;
import haxepunk.graphics.Graphic;
import haxepunk.graphics.Draw;
import haxepunk.masks.Mask;
import haxepunk.math.Matrix4;
import haxepunk.renderers.Renderer;
import haxepunk.graphics.SpriteBatch;

class Scene
{

	public var camera:Camera;

	public function new()
	{
		camera = new Camera();
		_added = new Array<Entity>();
		_entities = new Array<Entity>();
		_types = new StringMap<Array<Entity>>();
		_entityNames = new StringMap<Entity>();
		_frameList = new Array<Float>();
	}

	public function add(e:Entity)
	{
		_added.push(e);
	}

	public function remove(e:Entity)
	{
		e.remove = true;
	}

	/**
	 * Remove all entities in the scene
	 */
	public function clear()
	{
		for (i in 0..._entities.length)
		{
			_entities[i].remove = true;
		}
	}

	public function addMask(mask:Mask, layer:Int=0, x:Float=0, y:Float=0):Entity
	{
		var e = new Entity(x, y, layer);
		e.addMask(mask);
		add(e);
		return e;
	}

	public function addGraphic(graphic:Graphic, layer:Int=0, x:Float=0, y:Float=0):Entity
	{
		var e = new Entity(x, y, layer);
		e.addGraphic(graphic);
		add(e);
		return e;
	}

	public var count(get, never):Int;
	private inline function get_count():Int { return _entities.length; }

	public var entities(get, never):Iterator<Entity>;
	private inline function get_entities():Iterator<Entity>
	{
		return _entities.iterator();
	}

	/**
	 * A list of Entity objects of the type.
	 * @param	type 		The type to check.
	 * @return 	The Entity list.
	 */
	public inline function entitiesForType(type:String):Array<Entity>
	{
		return _types.exists(type) ? _types.get(type) : null;
	}

	/**
	 * Returns the amount of Entities of the type are in the Scene.
	 * @param	type		The type (or Class type) to count.
	 * @return	How many Entities of type exist in the Scene.
	 */
	public inline function typeCount(type:String):Int
	{
		return _types.exists(type) ? _types.get(type).length : 0;
	}

	/**
	 * How many different types have been added to the Scene.
	 */
	public var uniqueTypes(get, null):Int;
	private inline function get_uniqueTypes():Int
	{
		var i:Int = 0;
		for (type in _types) i++;
		return i;
	}

	/**
	 * Pushes all Entities in the Scene of the type into the Array or Vector. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	type		The type to check.
	 * @param	into		The Array or Vector to populate.
	 */
	public function getType<E:Entity>(type:String, into:Array<E>):Void
	{
		if (!_types.exists(type)) return;
		var n:Int = into.length;
		for (e in _types.get(type))
		{
			into[n++] = cast e;
		}
	}

	/** @private Adds Entity to the type list. */
	@:allow(haxepunk.scene.Entity)
	private function addType(e:Entity)
	{
		var list:Array<Entity>;
		// add to type list
		if (_types.exists(e.type))
		{
			list = _types.get(e.type);
		}
		else
		{
			list = new Array<Entity>();
			_types.set(e.type, list);
		}
		list.push(e);
	}

	/** @private Removes Entity from the type list. */
	@:allow(haxepunk.scene.Entity)
	private function removeType(e:Entity)
	{
		if (!_types.exists(e.type)) return;
		var list = _types.get(e.type);
		list.remove(e);
		if (list.length == 0)
		{
			_types.remove(e.type);
		}
	}

	/** @private Register the entities instance name. */
	@:allow(haxepunk.scene.Entity)
	private inline function registerName(e:Entity)
	{
		_entityNames.set(e.name, e);
	}

	/** @private Unregister the entities instance name. */
	@:allow(haxepunk.scene.Entity)
	private inline function unregisterName(e:Entity):Void
	{
		_entityNames.remove(e.name);
	}

	private function sortByLayer(a:Entity, b:Entity):Int
	{
		return Std.int(a.layer - b.layer);
	}

	public function draw()
	{
		Renderer.clear(camera.clearColor);
		// TODO: find a faster way to sort entities without coupling...
		_entities.sort(sortByLayer);
		for (i in 0..._entities.length)
		{
			_entities[i].draw();
		}
		if (Console.enabled) Console.instance.draw(this);
		SpriteBatch.flush();
		Renderer.present();

		var t = haxe.Timer.stamp() * 1000;
		_frameListSum += _frameList[_frameList.length] = Std.int(t - _frameLast);
		if (_frameList.length > 10) _frameListSum -= _frameList.shift();
		HXP.frameRate = 1000 / (_frameListSum / _frameList.length);
		_frameLast = t;
	}

	public function update(elapsed:Float)
	{
		updateEntities(elapsed);
		if (Console.enabled) Console.instance.update(this, elapsed);
		camera.update();
	}

	/**
	 * Adds, updates, and removes entities from the scene
	 */
	private inline function updateEntities(elapsed:Float=0)
	{
		var removed = new Array<Entity>(),
			e:Entity;

		// add any entities for this update
		for (e in _added)
		{
			_entities.push(e);
			e.scene = this;
			if (e.type != "") addType(e);
			if (e.name != "") registerName(e);
		}
		_added.splice(0, _added.length); // clear added array

		for (i in 0..._entities.length)
		{
			e = _entities[i];
			if (e.remove)
			{
				removed.push(e);
			}
			else
			{
				e.update(elapsed);
				if (e._graphic != null) e._graphic.update(elapsed);
			}
		}

		// remove any entities no longer used
		for (e in removed)
		{
			e.scene = null;
			_entities.remove(e);
			if (e.type != "") removeType(e);
			if (e.name != "") unregisterName(e);
		}
	}

	private var _frameLast:Float = 0;
	private var _frameListSum:Float = 0;
	private var _frameList:Array<Float>;

	private var _added:Array<Entity>;
	private var _entities:Array<Entity>;
	private var _types:StringMap<Array<Entity>>;
	private var _entityNames:StringMap<Entity>;

}
