package haxepunk.scene;

import haxe.ds.StringMap;
import haxepunk.debug.Console;
import haxepunk.graphics.Graphic;
import haxepunk.math.Matrix4;
import haxepunk.renderers.Renderer;
import haxepunk.graphics.SpriteBatch;

class Scene
{

	public var camera:Camera;

	public function new()
	{
		camera = new Camera();
		_entities = new Array<Entity>();
		_types = new StringMap<Array<Entity>>();
		_entityNames = new StringMap<Entity>();
		_frameList = new Array<Float>();

		HXP.spriteBatch = _spriteBatch = new SpriteBatch();
	}

	public function add(e:Entity)
	{
		e.scene = this;
		_entities.push(e);
		if (e.type != "") addType(e);
		if (e.name != "") registerName(e);
	}

	public function remove(e:Entity)
	{
		e.scene = null;
		_entities.remove(e);
		if (e.type != "") removeType(e);
		if (e.name != "") unregisterName(e);
	}

	public function addGraphic(graphic:Graphic, layer:Int=0, x:Float=0, y:Float=0)
	{
		var e = new Entity(x, y, layer);
		e.addGraphic(graphic);
		add(e);
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

	public function draw()
	{
		Renderer.clear(camera.clearColor);
		_spriteBatch.begin();
		for (i in 0..._entities.length)
		{
			_entities[i].draw(camera);
		}
		_spriteBatch.end(camera);
		if (Console.enabled) Console.instance.draw(camera);
		Renderer.present();

		var t = haxe.Timer.stamp() * 1000;
		_frameListSum += _frameList[_frameList.length] = Std.int(t - _frameLast);
		if (_frameList.length > 10) _frameListSum -= _frameList.shift();
		HXP.frameRate = 1000 / (_frameListSum / _frameList.length);
		_frameLast = t;
	}

	public function update(elapsed:Float)
	{
		for (i in 0..._entities.length)
		{
			var e = _entities[i];
			e.update(elapsed);
			if (e._graphic != null) e._graphic.update(elapsed);
		}
		if (Console.enabled) Console.instance.update(elapsed);
		camera.update();
	}

	private var _frameLast:Float = 0;
	private var _frameListSum:Float = 0;
	private var _frameList:Array<Float>;

	private var _spriteBatch:SpriteBatch;
	private var _entities:Array<Entity>;
	private var _types:StringMap<Array<Entity>>;
	private var _entityNames:StringMap<Entity>;

}
