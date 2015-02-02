package haxepunk.scene;

import haxepunk.graphics.Graphic;
import haxepunk.masks.Mask;
import haxepunk.masks.AABB;
import haxepunk.math.Matrix4;
import haxepunk.math.Vector3;

class Entity extends SceneNode
{

	public var hitbox(default, null):AABB;
	public var mask(default, null):Mask;
	public var collidable:Bool = true;

	public var layer(get, set):Float;
	private inline function get_layer():Float { return position.z; }
	private inline function set_layer(value:Float) { return position.z = value; }

	/**
	 * The collision type, used for collision checking.
	 */
	public var type(get, set):String;
	private inline function get_type():String { return _type; }
	private function set_type(value:String):String
	{
		if (_type != value)
		{
			if (scene == null)
			{
				_type = value;
			}
			else
			{
				if (_type != "") scene.removeType(this);
				_type = value;
				if (value != "") scene.addType(this);
			}
		}
		return _type;
	}

	/**
	 * The entity name
	 */
	public var name(get, set):String;
	private inline function get_name():String { return _name; }
	private function set_name(value:String):String
	{
		if (_name != value)
		{
			if (scene == null)
			{
				_name = value;
			}
			else
			{
				if (_name != "") scene.unregisterName(this);
				_name = value;
				if (value != "") scene.registerName(this);
			}
		}
		return _name;
	}

	public function new(x:Float = 0, y:Float = 0, z:Float = 0)
	{
		super(x, y, z);
		mask = hitbox = new AABB();
	}

	public function toString():String
	{
		return _name;
	}

	public function addGraphic(graphic:Graphic):Graphic
	{
		if (_graphic == null)
		{
			_graphic = graphic;
		}
		else if (Std.is(_graphic, GraphicList))
		{
			cast(_graphic, GraphicList).add(graphic);
		}
		else
		{
			_graphic = new GraphicList([_graphic, graphic]);
		}
		return _graphic;
	}

	public function draw()
	{
		if (_graphic != null)
		{
			_graphic.draw(position);
		}
	}

	/**
	 * TODO: change to 3d?
	 */
	public function collidePoint(x1:Float, y1:Float, x2:Float, y2:Float):Bool
	{
		hitbox.x += x1; hitbox.y += y1;
		var vec = new Vector3(x2, y2);
		var result = hitbox.intersectsPoint(vec);
		hitbox.x -= x1; hitbox.y -= y1;
		return result;
	}

	/**
	 * Checks for a collision against an Entity type.
	 * @param	type		The Entity type to check for.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @return	The first Entity collided with, or null if none were collided.
	 */
	public function collide(type:String, ?offset:Vector3):Entity
	{
		// check that the entity has been added to a scene
		if (scene == null) return null;

		var entities = scene.entitiesForType(type);
		if (!collidable || entities == null) return null;

		var _x = hitbox.x, _y = hitbox.x;
		offset = (offset == null ? position : offset + position);
		hitbox.min += offset;
		hitbox.max += offset;

		for (e in entities)
		{
			if (e.collidable && e != this)
			{
				e.hitbox.min += e.position;
				e.hitbox.max += e.position;
				var result = e.hitbox.intersectsAABB(hitbox);
				e.hitbox.min -= e.position;
				e.hitbox.max -= e.position;

				if (result && (mask == null || e.mask != null && mask.intersects(e.mask)))
				{
					hitbox.min -= offset;
					hitbox.max -= offset;
					return e;
				}
			}
		}

		hitbox.min -= offset;
		hitbox.max -= offset;
		return null;
	}

	/**
	 * Updates the Entity.
	 */
	public function update(elapsed:Float):Void { }

	@:allow(haxepunk.scene.Scene)
	private var _graphic:Graphic;

	private var _type:String = "";
	private var _name:String = "";

}
