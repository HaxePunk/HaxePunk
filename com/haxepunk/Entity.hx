package com.haxepunk;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Graphiclist;

/**
 * Friend class used by Scene
 */
typedef FriendEntity = {
	private var _class:String;
	private var _scene:Scene;
	private var _type:String;
	private var _layer:Int;
	private var _name:String;

	private var _updatePrev:FriendEntity;
	private var _updateNext:FriendEntity;
	private var _renderPrev:FriendEntity;
	private var _renderNext:FriendEntity;

	private var _typePrev:FriendEntity;
	private var _typeNext:FriendEntity;
	private var _recycleNext:Entity;
}

/**
 * Main game Entity class updated by Scene.
 */
class Entity extends Tweener
{
	/**
	 * If the Entity should render.
	 */
	public var visible:Bool;

	/**
	 * If the Entity should respond to collision checks.
	 */
	public var collidable:Bool;

	/**
	 * X position of the Entity in the Scene.
	 */
	@:isVar public var x(get_x, set_x):Float;
	private inline function get_x():Float
	{
		if (followCamera)
			return x + HXP.camera.x;
		else
			return x;
	}
	private inline function set_x(v:Float):Float
	{
		return x = v;
	}

	/**
	 * Y position of the Entity in the Scene.
	 */
	@:isVar public var y(get_y, set_y):Float;
	private inline function get_y():Float
	{
		if (followCamera)
			return y + HXP.camera.y;
		else
			return y;
	}
	private inline function set_y(v:Float):Float
	{
		return y = v;
	}

	/**
	 * If the entity should follow the camera.
	 */
	public var followCamera:Bool;

	/**
	 * Width of the Entity's hitbox.
	 */
	public var width:Int;

	/**
	 * Height of the Entity's hitbox.
	 */
	public var height:Int;

	/**
	 * X origin of the Entity's hitbox.
	 */
	public var originX:Int;

	/**
	 * Y origin of the Entity's hitbox.
	 */
	public var originY:Int;

	/**
	 * The BitmapData target to draw the Entity to. Leave as null to render to the current screen buffer (default).
	 */
	public var renderTarget:BitmapData;

	/**
	 * Constructor. Can be usd to place the Entity and assign a graphic and mask.
	 * @param	x			X position to place the Entity.
	 * @param	y			Y position to place the Entity.
	 * @param	graphic		Graphic to assign to the Entity.
	 * @param	mask		Mask to assign to the Entity.
	 */
	public function new(x:Float = 0, y:Float = 0, graphic:Graphic = null, mask:Mask = null)
	{
		super();
		visible = true;
		collidable = true;
		followCamera = false;
		this.x = x;
		this.y = y;

		originX = originY = 0;
		width = height = 0;
		_moveX = _moveY = 0;
		_type = "";
		_name = "";

		HITBOX = new Mask();
		_point = HXP.point;
		_camera = HXP.point2;

		layer = HXP.BASELAYER;

		if (graphic != null) this.graphic = graphic;
		if (mask != null) this.mask = mask;
		HITBOX.assignTo(this);
		_class = Type.getClassName(Type.getClass(this));
	}

	/**
	 * Override this, called when the Entity is added to a Scene.
	 */
	public function added():Void
	{

	}

	/**
	 * Override this, called when the Entity is removed from a Scene.
	 */
	public function removed():Void
	{

	}

	/**
	 * Updates the Entity.
	 */
	override public function update():Void
	{

	}

	/**
	 * Renders the Entity. If you override this for special behaviour,
	 * remember to call super.render() to render the Entity's graphic.
	 */
	public function render():Void
	{
		if (_graphic != null && _graphic.visible)
		{
			if (_graphic.relative)
			{
				_point.x = x;
				_point.y = y;
			}
			else _point.x = _point.y = 0;
			_camera.x = _scene == null ? HXP.camera.x : _scene.camera.x;
			_camera.y = _scene == null ? HXP.camera.y : _scene.camera.y;
			_graphic.render((renderTarget != null) ? renderTarget : HXP.buffer, _point, _camera);
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
		if (_scene == null) return null;

		var e:Entity,
			fe:FriendEntity = _scene._typeFirst.get(type);
		if (!collidable || fe == null) return null;

		_x = this.x; _y = this.y;
		this.x = x; this.y = y;

		if (_mask == null)
		{
			while (fe != null)
			{
				e = cast(fe, Entity);
				if (e.collidable && e != this
					&& x - originX + width > e.x - e.originX
					&& y - originY + height > e.y - e.originY
					&& x - originX < e.x - e.originX + e.width
					&& y - originY < e.y - e.originY + e.height)
				{
					if (e._mask == null || e._mask.collide(HITBOX))
					{
						this.x = _x; this.y = _y;
						return e;
					}
				}
				fe = fe._typeNext;
			}
			this.x = _x; this.y = _y;
			return null;
		}

		while (fe != null)
		{
			e = cast(fe, Entity);
			if (e.collidable && e != this
				&& x - originX + width > e.x - e.originX
				&& y - originY + height > e.y - e.originY
				&& x - originX < e.x - e.originX + e.width
				&& y - originY < e.y - e.originY + e.height)
			{
				if (_mask.collide(e._mask != null ? e._mask : e.HITBOX))
				{
					this.x = _x; this.y = _y;
					return e;
				}
			}
			fe = fe._typeNext;
		}
		this.x = _x; this.y = _y;
		return null;
	}

	/**
	 * Checks for collision against multiple Entity types.
	 * @param	types		An Array or Vector of Entity types to check for.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @return	The first Entity collided with, or null if none were collided.
	 */
	public function collideTypes(types:Dynamic, x:Float, y:Float):Entity
	{
		if (_scene == null) return null;

		if (Std.is(types, String))
		{
			return collide(types, x, y);
		}
		else
		{
			var a:Array<String> = cast types;
			if (a != null)
			{
				var e:Entity;
				for (type in a)
				{
					e = collide(type, x, y);
					if (e != null) return e;
				}
			}
		}

		return null;
	}

	/**
	 * Checks if this Entity collides with a specific Entity.
	 * @param	e		The Entity to collide against.
	 * @param	x		Virtual x position to place this Entity.
	 * @param	y		Virtual y position to place this Entity.
	 * @return	The Entity if they overlap, or null if they don't.
	 */
	public function collideWith<E:Entity>(e:E, x:Float, y:Float):E
	{
		_x = this.x; _y = this.y;
		this.x = x; this.y = y;

		if (collidable && e.collidable
			&& x - originX + width > e.x - e.originX
			&& y - originY + height > e.y - e.originY
			&& x - originX < e.x - e.originX + e.width
			&& y - originY < e.y - e.originY + e.height)
		{
			if (_mask == null)
			{
				if ((untyped e._mask) == null || (untyped e._mask).collide(HITBOX))
				{
					this.x = _x; this.y = _y;
					return e;
				}
				this.x = _x; this.y = _y;
				return null;
			}
			if (_mask.collide((untyped e._mask) != null ? (untyped e._mask) : (untyped e.HITBOX)))
			{
				this.x = _x; this.y = _y;
				return e;
			}
		}
		this.x = _x; this.y = _y;
		return null;
	}

	/**
	 * Checks if this Entity overlaps the specified rectangle.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @param	rX			X position of the rectangle.
	 * @param	rY			Y position of the rectangle.
	 * @param	rWidth		Width of the rectangle.
	 * @param	rHeight		Height of the rectangle.
	 * @return	If they overlap.
	 */
	public function collideRect(x:Float, y:Float, rX:Float, rY:Float, rWidth:Float, rHeight:Float):Bool
	{
		if (x - originX + width >= rX &&
			y - originY + height >= rY &&
			x - originX <= rX + rWidth &&
			y - originY <= rY + rHeight)
		{
			if (_mask == null) return true;
			_x = this.x; _y = this.y;
			this.x = x; this.y = y;
			HXP.entity.x = rX;
			HXP.entity.y = rY;
			HXP.entity.width = Std.int(rWidth);
			HXP.entity.height = Std.int(rHeight);
			if (_mask.collide(HXP.entity.HITBOX))
			{
				this.x = _x; this.y = _y;
				return true;
			}
			this.x = _x; this.y = _y;
			return false;
		}
		return false;
	}

	/**
	 * Checks if this Entity overlaps the specified position.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @param	pX			X position.
	 * @param	pY			Y position.
	 * @return	If the Entity intersects with the position.
	 */
	public function collidePoint(x:Float, y:Float, pX:Float, pY:Float):Bool
	{
		if (pX >= x - originX &&
			pY >= y - originY &&
			pX < x - originX + width &&
			pY < y - originY + height)
		{
			if (_mask == null) return true;
			_x = this.x; _y = this.y;
			this.x = x; this.y = y;
			HXP.entity.x = pX;
			HXP.entity.y = pY;
			HXP.entity.width = 1;
			HXP.entity.height = 1;
			if (_mask.collide(HXP.entity.HITBOX))
			{
				this.x = _x; this.y = _y;
				return true;
			}
			this.x = _x; this.y = _y;
			return false;
		}
		return false;
	}

	/**
	 * Populates an array with all collided Entities of a type. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	type		The Entity type to check for.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @param	array		The Array or Vector object to populate.
	 */
	public function collideInto<E:Entity>(type:String, x:Float, y:Float, array:Array<E>)
	{
		if (_scene == null) return;

		var e:E,
			fe:FriendEntity = _scene._typeFirst.get(type);
		if (!collidable || fe == null) return;

		_x = this.x; _y = this.y;
		this.x = x; this.y = y;
		var n:Int = array.length;

		if (_mask == null)
		{
			while (fe != null)
			{
				e = cast fe;
				if (e.collidable && e != this
					&& x - originX + width > e.x - e.originX
					&& y - originY + height > e.y - e.originY
					&& x - originX < e.x - e.originX + e.width
					&& y - originY < e.y - e.originY + e.height)
				{
					if ((untyped e._mask) == null || (untyped e._mask).collide(HITBOX)) array[n++] = e;
				}
				fe = fe._typeNext;
			}
			this.x = _x; this.y = _y;
			return;
		}

		while (fe != null)
		{
			e = cast fe;
			if (e.collidable && e != this
				&& x - originX + width > e.x - e.originX
				&& y - originY + height > e.y - e.originY
				&& x - originX < e.x - e.originX + e.width
				&& y - originY < e.y - e.originY + e.height)
			{
				if (_mask.collide((untyped e._mask) != null ? (untyped e._mask) : (untyped e.HITBOX))) array[n++] = e;
			}
			fe = fe._typeNext;
		}
		this.x = _x; this.y = _y;
		return;
	}

	/**
	 * Populates an array with all collided Entities of multiple types. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	types		An array of Entity types to check for.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @param	array		The Array or Vector object to populate.
	 */
	public function collideTypesInto<E:Entity>(types:Array<String>, x:Float, y:Float, array:Array<E>)
	{
		if (_scene == null) return;
		for (type in types) collideInto(type, x, y, array);
	}

	/**
	 * If the Entity collides with the camera rectangle.
	 */
	public var onCamera(get_onCamera, null):Bool;
	private inline function get_onCamera():Bool
	{
		if (_scene == null)
		{
			return false;
		}
		else
		{
			return collideRect(x, y, _scene.camera.x, _scene.camera.y, HXP.width, HXP.height);
		}
	}

	/**
	 * The World object is deprecated
	 */
	public var world(get_world, never):Scene;
	private inline function get_world():Scene
	{
		HXP.log('Entity.world is deprecated, please use scene instead');
		return _scene;
	}

	/**
	 * The Scene object this Entity has been added to.
	 */
	public var scene(get_scene, never):Scene;
	private inline function get_scene():Scene
	{
		return _scene;
	}

	/**
	 * Half the Entity's width.
	 */
	public var halfWidth(get_halfWidth, null):Float;
	private inline function get_halfWidth():Float { return width / 2; }

	/**
	 * Half the Entity's height.
	 */
	public var halfHeight(get_halfHeight, null):Float;
	private inline function get_halfHeight():Float { return height / 2; }

	/**
	 * The center x position of the Entity's hitbox.
	 */
	public var centerX(get_centerX, null):Float;
	private inline function get_centerX():Float { return x - originX + width / 2; }

	/**
	 * The center y position of the Entity's hitbox.
	 */
	public var centerY(get_centerY, null):Float;
	private inline function get_centerY():Float { return y - originY + height / 2; }

	/**
	 * The leftmost position of the Entity's hitbox.
	 */
	public var left(get_left, null):Float;
	private inline function get_left():Float { return x - originX; }

	/**
	 * The rightmost position of the Entity's hitbox.
	 */
	public var right(get_right, null):Float;
	private inline function get_right():Float { return x - originX + width; }

	/**
	 * The topmost position of the Entity's hitbox.
	 */
	public var top(get_top, null):Float;
	private inline function get_top():Float { return y - originY; }

	/**
	 * The bottommost position of the Entity's hitbox.
	 */
	public var bottom(get_bottom, null):Float;
	private inline function get_bottom():Float { return y - originY + height; }

	/**
	 * The rendering layer of this Entity. Higher layers are rendered first.
	 */
	public var layer(get_layer, set_layer):Int;
	private inline function get_layer():Int { return _layer; }
	private function set_layer(value:Int):Int
	{
		if (_layer == value) return _layer;
		#if debug
		if (value < 0)
		{
			trace("Negative layers may not work properly if you aren't using flash");
		}
		#end
		if (_graphic != null)
		{
			_graphic.setEntity(this); // reset layer
		}
		if (_scene == null)
		{
			_layer = value;
			return _layer;
		}
		_scene.removeRender(this);
		_layer = value;
		_scene.addRender(this);
		return _layer;
	}

	/**
	 * The collision type, used for collision checking.
	 */
	public var type(get_type, set_type):String;
	private inline function get_type():String { return _type; }
	private function set_type(value:String):String
	{
		if (_type == value) return _type;
		if (_scene == null)
		{
			_type = value;
			return _type;
		}
		if (_type != "") _scene.removeType(this);
		_type = value;
		if (value != "") _scene.addType(this);
		return _type;
	}

	/**
	 * An optional Mask component, used for specialized collision. If this is
	 * not assigned, collision checks will use the Entity's hitbox by default.
	 */
	public var mask(get_mask, set_mask):Mask;
	private inline function get_mask():Mask { return _mask; }
	private function set_mask(value:Mask):Mask
	{
		if (_mask == value) return value;
		if (_mask != null) _mask.assignTo(null);
		_mask = value;
		if (value != null) _mask.assignTo(this);
		return _mask;
	}

	/**
	 * Graphical component to render to the screen.
	 */
	public var graphic(get_graphic, set_graphic):Graphic;
	private inline function get_graphic():Graphic { return _graphic; }
	private function set_graphic(value:Graphic):Graphic
	{
		if (_graphic == value) return value;
		if (_graphic != null)
		{
			_graphic.setEntity(null);
			_graphic.destroy();
		}
		if (value != null)
		{
			value.setEntity(this);
		}
		_graphic = value;
		return _graphic;
	}

	public var name(get_name, set_name):String;
	private inline function get_name():String { return _name; }
	private function set_name(value:String):String
	{
		if (_name == value) return _name;
		if (_scene == null)
		{
			_name = value;
			return _name;
		}
		if (_name != "") _scene.unregisterName(this);
		_name = value;
		if (value != "") _scene.registerName(this);
		return _name;
	}

	/**
	 * Adds the graphic to the Entity via a Graphiclist.
	 * @param	g		Graphic to add.
	 *
	 * @return	The added graphic.
	 */
	public function addGraphic(g:Graphic):Graphic
	{
		if (graphic == null)
		{
			graphic = g;
		}
		else if (Std.is(graphic, Graphiclist))
		{
			cast(graphic, Graphiclist).add(g);
		}
		else
		{
			var list:Graphiclist = new Graphiclist();
			list.add(graphic);
			list.add(g);
			graphic = list;
		}
		return g;
	}

	/**
	 * Sets the Entity's hitbox properties.
	 * @param	width		Width of the hitbox.
	 * @param	height		Height of the hitbox.
	 * @param	originX		X origin of the hitbox.
	 * @param	originY		Y origin of the hitbox.
	 */
	public inline function setHitbox(width:Int = 0, height:Int = 0, originX:Int = 0, originY:Int = 0)
	{
		this.width = width;
		this.height = height;
		this.originX = originX;
		this.originY = originY;
	}

	/**
	 * Sets the Entity's hitbox to match that of the provided object.
	 * @param	o		The object defining the hitbox (eg. an Image or Rectangle).
	 */
	public function setHitboxTo(o:Dynamic)
	{
		width = Reflect.getProperty(o, "width");
		height = Reflect.getProperty(o, "height");

		if (Reflect.hasField(o, "originX") && Reflect.hasField(o, "originY"))
		{
			originX = Reflect.getProperty(o, "originX");
			originY = Reflect.getProperty(o, "originY");
		}
		else
		{
			originX = Reflect.getProperty(o, "x");
			originY = Reflect.getProperty(o, "y");

			originX = -originX;
			originY = -originY;
		}
	}

	/**
	 * Sets the origin of the Entity.
	 * @param	x		X origin.
	 * @param	y		Y origin.
	 */
	public inline function setOrigin(x:Int = 0, y:Int = 0)
	{
		originX = x;
		originY = y;
	}

	/**
	 * Center's the Entity's origin (half width & height).
	 */
	public inline function centerOrigin()
	{
		originX = Std.int(halfWidth);
		originY = Std.int(halfHeight);
	}

	/**
	 * Calculates the distance from another Entity.
	 * @param	e				The other Entity.
	 * @param	useHitboxes		If hitboxes should be used to determine the distance. If not, the Entities' x/y positions are used.
	 * @return	The distance.
	 */
	public inline function distanceFrom(e:Entity, useHitboxes:Bool = false):Float
	{
		if (!useHitboxes) return Math.sqrt((x - e.x) * (x - e.x) + (y - e.y) * (y - e.y));
		else return HXP.distanceRects(x - originX, y - originY, width, height, e.x - e.originX, e.y - e.originY, e.width, e.height);
	}

	/**
	 * Calculates the distance from this Entity to the point.
	 * @param	px				X position.
	 * @param	py				Y position.
	 * @param	useHitboxes		If hitboxes should be used to determine the distance. If not, the Entities' x/y positions are used.
	 * @return	The distance.
	 */
	public inline function distanceToPoint(px:Float, py:Float, useHitbox:Bool = false):Float
	{
		if (!useHitbox) return Math.sqrt((x - px) * (x - px) + (y - py) * (y - py));
		else return HXP.distanceRectPoint(px, py, x - originX, y - originY, width, height);
	}

	/**
	 * Calculates the distance from this Entity to the rectangle.
	 * @param	rx			X position of the rectangle.
	 * @param	ry			Y position of the rectangle.
	 * @param	rwidth		Width of the rectangle.
	 * @param	rheight		Height of the rectangle.
	 * @return	The distance.
	 */
	public inline function distanceToRect(rx:Float, ry:Float, rwidth:Float, rheight:Float):Float
	{
		return HXP.distanceRects(rx, ry, rwidth, rheight, x - originX, y - originY, width, height);
	}

	/**
	 * Gets the class name as a string.
	 * @return	A string representing the class name.
	 */
	public function toString():String
	{
		return _class;
	}

	/**
	 * Moves the Entity by the amount, retaining integer values for its x and y.
	 * @param	x			Horizontal offset.
	 * @param	y			Vertical offset.
	 * @param	solidType	An optional collision type to stop flush against upon collision.
	 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
	 */
	public function moveBy(x:Float, y:Float, solidType:Dynamic = null, sweep:Bool = false)
	{
		_moveX += x;
		_moveY += y;
		x = Math.round(_moveX);
		y = Math.round(_moveY);
		_moveX -= x;
		_moveY -= y;
		if (solidType != null)
		{
			var sign:Int, e:Entity;
			if (x != 0)
			{
				if (collidable && (sweep || collideTypes(solidType, this.x + x, this.y) != null))
				{
					sign = x > 0 ? 1 : -1;
					while (x != 0)
					{
						if ((e = collideTypes(solidType, this.x + sign, this.y)) != null)
						{
							if (moveCollideX(e)) break;
							else this.x += sign;
						}
						else
						{
							this.x += sign;
						}
						x -= sign;
					}
				}
				else this.x += x;
			}
			if (y != 0)
			{
				if (collidable && (sweep || collideTypes(solidType, this.x, this.y + y) != null))
				{
					sign = y > 0 ? 1 : -1;
					while (y != 0)
					{
						if ((e = collideTypes(solidType, this.x, this.y + sign)) != null)
						{
							if (moveCollideY(e)) break;
							else this.y += sign;
						}
						else
						{
							this.y += sign;
						}
						y -= sign;
					}
				}
				else this.y += y;
			}
		}
		else
		{
			this.x += x;
			this.y += y;
		}
	}

	/**
	 * Moves the Entity to the position, retaining integer values for its x and y.
	 * @param	x			X position.
	 * @param	y			Y position.
	 * @param	solidType	An optional collision type to stop flush against upon collision.
	 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
	 */
	public inline function moveTo(x:Float, y:Float, solidType:Dynamic = null, sweep:Bool = false)
	{
		moveBy(x - this.x, y - this.y, solidType, sweep);
	}

	/**
	 * Moves towards the target position, retaining integer values for its x and y.
	 * @param	x			X target.
	 * @param	y			Y target.
	 * @param	amount		Amount to move.
	 * @param	solidType	An optional collision type to stop flush against upon collision.
	 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
	 */
	public inline function moveTowards(x:Float, y:Float, amount:Float, solidType:Dynamic = null, sweep:Bool = false)
	{
		_point.x = x - this.x;
		_point.y = y - this.y;
		if (_point.x * _point.x + _point.y * _point.y > amount * amount)
		{
			_point.normalize(amount);
		}
		moveBy(_point.x, _point.y, solidType, sweep);
	}

	/**
	 * Moves at an angle by a certain amount, retaining integer values for its x and y.
	 * @param	angle		Angle to move at in degrees.
	 * @param	amount		Amount to move.
	 * @param	solidType	An optional collision type to stop flush against upon collision.
	 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
	 */
	public inline function moveAtAngle(angle:Float, amount:Float, solidType:Dynamic = null, sweep:Bool = false):Void
	{
		angle *= HXP.RAD;
		moveBy(Math.cos(angle) * amount, Math.sin(angle) * amount, solidType, sweep);
	}

	/**
	 * When you collide with an Entity on the x-axis with moveTo() or moveBy().
	 * @param	e		The Entity you collided with.
	 *
	 * @return	If there was a collision.
	 */
	public function moveCollideX(e:Entity):Bool
	{
		return true;
	}

	/**
	 * When you collide with an Entity on the y-axis with moveTo() or moveBy().
	 * @param	e		The Entity you collided with.
	 *
	 * @return	If there was a collision.
	 */
	public function moveCollideY(e:Entity):Bool
	{
		return true;
	}

	/**
	 * Clamps the Entity's hitbox on the x-axis.
	 * @param	left		Left bounds.
	 * @param	right		Right bounds.
	 * @param	padding		Optional padding on the clamp.
	 */
	public inline function clampHorizontal(left:Float, right:Float, padding:Float = 0)
	{
		if (x - originX < left + padding) x = left + originX + padding;
		if (x - originX + width > right - padding) x = right - width + originX - padding;
	}

	/**
	 * Clamps the Entity's hitbox on the y axis.
	 * @param	top			Min bounds.
	 * @param	bottom		Max bounds.
	 * @param	padding		Optional padding on the clamp.
	 */
	public inline function clampVertical(top:Float, bottom:Float, padding:Float = 0)
	{
		if (y - originY < top + padding) y = top + originY + padding;
		if (y - originY + height > bottom - padding) y = bottom - height + originY - padding;
	}

	/**
	 * Center graphic inside bounding rect.
	 */
	public function centerGraphicInRect():Void
	{
		if (graphic != null)
		{
			graphic.x = halfWidth;
			graphic.y = halfHeight;
		}
	}

	// Entity information.
	private var _class:String;
	private var _scene:Scene;
	private var _type:String;
	private var _layer:Int;
	private var _name:String;

	private var _updatePrev:FriendEntity;
	private var _updateNext:FriendEntity;
	private var _renderPrev:FriendEntity;
	private var _renderNext:FriendEntity;

	private var _typePrev:FriendEntity;
	private var _typeNext:FriendEntity;
	private var _recycleNext:Entity;

	// Collision information.
	private var HITBOX:Mask;
	private var _mask:Mask;
	private var _x:Float;
	private var _y:Float;
	private var _moveX:Float;
	private var _moveY:Float;

	// Rendering information.
	private var _graphic:Graphic;
	private var _point:Point;
	private var _camera:Point;
}
