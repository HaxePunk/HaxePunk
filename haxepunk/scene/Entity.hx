package haxepunk.scene;

import haxepunk.graphics.Graphic;
import haxepunk.masks.Mask;
import haxepunk.masks.AABB;
import haxepunk.math.Matrix3D;
import haxepunk.math.Vector3D;

class Entity
{

	public var position:Vector3D;

	public var x(get, set):Float;
	private inline function get_x():Float { return position.x; }
	private inline function set_x(value:Float) { return position.x = value; }

	public var y(get, set):Float;
	private inline function get_y():Float { return position.y; }
	private inline function set_y(value:Float) { return position.y = value; }

	public var z(get, set):Float;
	private inline function get_z():Float { return position.z; }
	private inline function set_z(value:Float) { return position.z = value; }

	public var layer(get, set):Float;
	private inline function get_layer():Float { return position.z; }
	private inline function set_layer(value:Float) { return position.z = value; }

	@:allow(haxepunk.scene.Scene)
	public var scene(default, null):Scene;

	public var hitbox:AABB;
	public var collidable:Bool = true;

	/**
	 * The collision type, used for collision checking.
	 */
	public var type(get, set):String;
	private inline function get_type():String { return _type; }
	private function set_type(value:String):String
	{
		if (_type == value) return _type;
		if (scene != null)
		{
			if (_type != "") scene.removeType(this);
			if (value != "") scene.addType(this);
		}
		return _type = value;
	}

	public function new(x:Float = 0, y:Float = 0, z:Float = 0)
	{
		position = new Vector3D(x, y, z);
		hitbox = new AABB();
		modelViewMatrix = new Matrix3D();
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

	public function draw(camera:Camera)
	{
		modelViewMatrix.identity();
		modelViewMatrix.translateVector3D(position);

		if (_graphic != null)
		{
			_graphic.draw(camera, modelViewMatrix);
		}
	}

	/**
	 * Checks for a collision against an Entity type.
	 * @param	type		The Entity type to check for.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @return	The first Entity collided with, or null if none were collided.
	 */
	public function collide(type:String, x:Float, y:Float):Entity
	{
		// check that the entity has been added to a scene
		if (scene == null) return null;

		var entities = scene.entitiesForType(type);
		if (!collidable || entities == null) return null;

		var _x = this.x, _y = this.y;
		this.x = x; this.y = y;

		for (e in entities)
		{
			if (e.collidable && e != this && e.hitbox.intersectsAABB(hitbox))
			{
				if (_mask == null || e._mask != null && _mask.intersects(e._mask))
				{
					this.x = _x; this.y = _y;
					return e;
				}
			}
		}

		this.x = _x; this.y = _y;
		return null;
	}

	/**
	 * Updates the Entity.
	 */
	public function update(elapsed:Float):Void { }

	private var _graphic:Graphic;
	private var _mask:Mask;
	private var _type:String = "";

	private var modelViewMatrix:Matrix3D;

}
