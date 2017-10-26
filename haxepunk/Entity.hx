package haxepunk;

import flash.geom.Point;
import haxe.ds.Either.Left;
import haxe.ds.Either.Right;
import haxepunk.Signal.Signal0;
import haxepunk.ds.OneOf;
import haxepunk.graphics.Graphiclist;
import haxepunk.math.MathUtil;

typedef SolidType = OneOf<String, Array<String>>;

/**
 * Main game Entity class updated by `Scene`.
 */
@:allow(haxepunk.Mask)
@:allow(haxepunk.Scene)
class Entity extends Tweener
{
	@:dox(hide) @:to public static inline function toPosition(entity:Entity):Position return new Position(entity);

	/**
	 * The entity's parent, if any. This entity's position will be offset by
	 * the parent's position.
	 * @since 4.0.0
	 */
	public var parent:Null<Entity>;

	/**
	 * If set, skip every N update frames.
	 */
	public var skipFrames:Int = 0;

	/**
	 * If the Entity should render.
	 */
	@:isVar public var visible(get, set):Bool = true;
	function get_visible() return visible && (parent == null || parent.visible);
	function set_visible(v:Bool) return visible = v;

	override function get_active() return active && (parent == null || parent.active);

	/**
	 * If the Entity should respond to collision checks.
	 */
	@:isVar public var collidable(get, set):Bool = true;
	function get_collidable() return collidable && (parent == null || parent.collidable);
	function set_collidable(v:Bool) return collidable = v;

	public var enabled(get, set):Bool;
	inline function get_enabled() return active && visible && collidable;
	inline function set_enabled(v:Bool) return active = visible = collidable = v;

	/**
	 * X position of the Entity in the Scene.
	 */
	@:isVar public var x(get, set):Float = 0;
	function get_x():Float
	{
		var parentX:Float = (parent == null) ? 0 : parent.x;
		return parentX + x + (followCamera == null ? 0 : followCamera.x);
	}
	function set_x(v:Float):Float
	{
		var parentX:Float = (parent == null) ? 0 : parent.x;
		return x = (v - parentX);
	}

	/**
	 * Y position of the Entity in the Scene.
	 */
	@:isVar public var y(get, set):Float = 0;
	function get_y():Float
	{
		var parentY:Float = (parent == null) ? 0 : parent.y;
		return parentY + y + (followCamera == null ? 0 : followCamera.y);
	}
	function set_y(v:Float):Float
	{
		var parentY:Float = (parent == null) ? 0 : parent.y;
		return y = (v - parentY);
	}

	/**
	 * Local X position. If this entity has a parent, this value is relative
	 * to the parent's position.
	 * @since 4.0.0
	 */
	public var localX(get, set):Float;
	function get_localX() return x - (parent == null ? 0 : parent.x);
	function set_localX(v:Float) return x = (parent == null ? 0 : parent.x) + v;

	/**
	 * Local Y position. If this entity has a parent, this value is relative
	 * to the parent's position.
	 * @since 4.0.0
	 */
	public var localY(get, set):Float;
	function get_localY() return y - (parent == null ? 0 : parent.y);
	function set_localY(v:Float) return y = (parent == null ? 0 : parent.y) + v;

	/**
	 * Set to the camera the entity should follow. If null it won't follow any camera.
	 */
	public var followCamera:Null<Camera> = null;

	/**
	 * Width of the Entity's hitbox.
	 */
	@:isVar public var width(get, set):Int = 0;
	function get_width() return width;
	function set_width(w:Int) return width = w;

	/**
	 * Height of the Entity's hitbox.
	 */
	@:isVar public var height(get, set):Int = 0;
	function get_height() return height;
	function set_height(h:Int) return height = h;

	/**
	 * X origin of the Entity's hitbox.
	 */
	public var originX:Int = 0;

	/**
	 * Y origin of the Entity's hitbox.
	 */
	public var originY:Int = 0;

	public var preUpdate:Signal0 = new Signal0();
	public var postUpdate:Signal0 = new Signal0();

	/**
	 * Constructor. Can be used to place the Entity and assign a graphic and mask.
	 * @param	x			X position to place the Entity.
	 * @param	y			Y position to place the Entity.
	 * @param	graphic		Graphic to assign to the Entity.
	 * @param	mask		Mask to assign to the Entity.
	 */
	public function new(x:Float = 0, y:Float = 0, ?graphic:Graphic, ?mask:Mask)
	{
		super();
		this.x = x;
		this.y = y;

		originX = originY = 0;
		width = height = 0;
		_moveX = _moveY = 0;
		_type = "";
		_name = "";

		HITBOX = new Mask();
		_point = HXP.point;

		layer = 0;

		if (graphic != null) this.graphic = graphic;
		if (mask != null) this.mask = mask;
		HITBOX.parent = this;
		_class = Type.getClassName(Type.getClass(this));
	}

	/**
	 * Override this, called when the Entity is added to a Scene.
	 */
	public function added():Void {}

	/**
	 * Override this, called when the Entity is removed from a Scene.
	 */
	public function removed():Void {}

	/**
	 * Override this, called when the Scene is resized.
	 */
	public function resized():Void {}

	public function shouldUpdate():Bool
	{
		if (skipFrames == 0) return true;
		else if (++_frames % skipFrames == 0)
		{
			_frames %= skipFrames;
			return true;
		}
		else return false;
	}

	/**
	 * Updates the Entity.
	 */
	override public function update():Void {}

	/**
	 * Renders the Entity. If you override this for special behaviour,
	 * remember to call super.render() to render the Entity's graphic.
	 */
	public function render(camera:Camera):Void
	{
		if (graphic != null && graphic.visible)
		{
			if (graphic.relative)
			{
				_point.x = x;
				_point.y = y;
			}
			else
			{
				_point.x = _point.y = 0;
			}
			graphic.doRender(_point, camera);
		}
	}

	public function debugDraw(camera:Camera, selected:Bool=false)
	{
		if (mask == null && width > 0 && height > 0 && collidable)
		{
			Mask.drawContext.lineThickness = 2;
			Mask.drawContext.setColor(0xff0000, 0.25);
			Mask.drawContext.rectFilled((x - camera.x - originX) * camera.fullScaleX, (y - camera.y - originY) * camera.fullScaleY, width * camera.fullScaleX, height * camera.fullScaleY);
			Mask.drawContext.setColor(0xff0000, 0.5);
			Mask.drawContext.rect((x - camera.x - originX) * camera.fullScaleX, (y - camera.y - originY) * camera.fullScaleY, width * camera.fullScaleX, height * camera.fullScaleY);
		}
		else if (mask != null)
		{
			mask.debugDraw(camera);
		}
		Mask.drawContext.setColor(selected ? 0x00ff00 : 0xffffff, 1);
		Mask.drawContext.circle((x - camera.x) * camera.fullScaleX, (y - camera.y) * camera.fullScaleY, 3, 8);
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

		var entities = _scene.entitiesForType(type);
		if (!collidable || entities == null) return null;

		_x = this.x; _y = this.y;
		this.x = x; this.y = y;

		if (_mask == null)
		{
			for (e in entities)
			{
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
			}
		}
		else
		{
			for (e in entities)
			{
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
			}
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
	public function collideTypes(types:SolidType, x:Float, y:Float):Entity
	{
		switch (types)
		{
			case Left(s):
				return collide(s, x, y);
			case Right(a):
				var e:Entity;
				for (type in a)
				{
					e = collide(type, x, y);
					if (e != null) return e;
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
	public function collideInto<E:Entity>(type:String, x:Float, y:Float, array:Array<E>):Void
	{
		if (_scene == null) return;

		var entities = _scene.entitiesForType(type);
		if (!collidable || entities == null) return;

		_x = this.x; _y = this.y;
		this.x = x; this.y = y;
		var n:Int = array.length;

		if (_mask == null)
		{
			for (e in entities)
			{
				e = cast e;
				if (e.collidable && e != this
					&& x - originX + width > e.x - e.originX
					&& y - originY + height > e.y - e.originY
					&& x - originX < e.x - e.originX + e.width
					&& y - originY < e.y - e.originY + e.height)
				{
					if ((untyped e._mask) == null || (untyped e._mask).collide(HITBOX)) array[n++] = cast e;
				}
			}
		}
		else
		{
			for (e in entities)
			{
				e = cast e;
				if (e.collidable && e != this
					&& x - originX + width > e.x - e.originX
					&& y - originY + height > e.y - e.originY
					&& x - originX < e.x - e.originX + e.width
					&& y - originY < e.y - e.originY + e.height)
				{
					if (_mask.collide((untyped e._mask) != null ? (untyped e._mask) : (untyped e.HITBOX))) array[n++] = cast e;
				}
			}
		}
		this.x = _x; this.y = _y;
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
	 * The Scene object this Entity has been added to.
	 */
	public var scene(get, never):Scene;
	inline function get_scene():Scene
	{
		return _scene;
	}

	/**
	 * Half the Entity's width.
	 */
	public var halfWidth(get, null):Float;
	inline function get_halfWidth():Float return width / 2;

	/**
	 * Half the Entity's height.
	 */
	public var halfHeight(get, null):Float;
	inline function get_halfHeight():Float return height / 2;

	/**
	 * The center x position of the Entity's hitbox.
	 */
	public var centerX(get, null):Float;
	inline function get_centerX():Float return left + halfWidth;

	/**
	 * The center y position of the Entity's hitbox.
	 */
	public var centerY(get, null):Float;
	inline function get_centerY():Float return top + halfHeight;

	/**
	 * The leftmost position of the Entity's hitbox.
	 */
	public var left(get, null):Float;
	inline function get_left():Float return x - originX;

	/**
	 * The rightmost position of the Entity's hitbox.
	 */
	public var right(get, null):Float;
	inline function get_right():Float return left + width;

	/**
	 * The topmost position of the Entity's hitbox.
	 */
	public var top(get, null):Float;
	inline function get_top():Float return y - originY;

	/**
	 * The bottommost position of the Entity's hitbox.
	 */
	public var bottom(get, null):Float;
	inline function get_bottom():Float return top + height;

	/**
	 * The rendering layer of this Entity. Higher layers are rendered first.
	 */
	public var layer(get, set):Int;
	inline function get_layer():Int return _layer;
	function set_layer(value:Int):Int
	{
		if (_layer == value) return _layer;
		if (_scene == null)
		{
			return _layer = value;
		}
		_scene.removeRender(this);
		_layer = value;
		_scene.addRender(this);
		return _layer;
	}

	/**
	 * The collision type, used for collision checking.
	 */
	public var type(get, set):String;
	inline function get_type():String return _type;
	function set_type(value:String):String
	{
		if (_type == value) return _type;
		if (_scene == null)
		{
			return _type = value;
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
	public var mask(get, set):Mask;
	inline function get_mask():Mask return _mask;
	function set_mask(value:Mask):Mask
	{
		if (_mask == value) return value;
		if (_mask != null) _mask.parent = null;
		_mask = value;
		if (value != null) _mask.parent = this;
		return _mask;
	}

	/**
	 * Graphical component to render to the screen.
	 */
	public var graphic:Graphic;

	/**
	 * An optional name for the entity.
	 */
	public var name(get, set):String;
	inline function get_name():String return _name;
	function set_name(value:String):String
	{
		if (_name == value) return _name;
		if (_scene == null)
		{
			return _name = value;
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
		inline function getInt(o:Dynamic, prop:String, defaultValue:Int=0):Int
		{
			return try
			{
				Std.int(Reflect.getProperty(o, prop));
			}
			catch (e:Dynamic)
			{
				defaultValue;
			}
		};

		width = getInt(o, "width");
		height = getInt(o, "height");

		originX = getInt(o, "originX", -getInt(o, "x"));
		originY = getInt(o, "originY", -getInt(o, "y"));
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
		else return MathUtil.distanceRects(x - originX, y - originY, width, height, e.x - e.originX, e.y - e.originY, e.width, e.height);
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
		else return MathUtil.distanceRectPoint(px, py, x - originX, y - originY, width, height);
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
		return MathUtil.distanceRects(rx, ry, rwidth, rheight, x - originX, y - originY, width, height);
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
	public function moveBy(x:Float, y:Float, ?solidType:SolidType, sweep:Bool = false):Void
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
	public inline function moveTo(x:Float, y:Float, ?solidType:SolidType, sweep:Bool = false)
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
	public inline function moveTowards(x:Float, y:Float, amount:Float, ?solidType:SolidType, sweep:Bool = false)
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
	public inline function moveAtAngle(angle:Float, amount:Float, ?solidType:SolidType, sweep:Bool = false):Void
	{
		angle *= MathUtil.RAD;
		moveBy(Math.cos(angle) * amount, Math.sin(angle) * amount, solidType, sweep);
	}

	/**
	 * When you collide with an Entity on the x-axis with moveTo() or moveBy()
	 * the engine call this function. Override it to detect and change the
	 * behaviour of collisions.
	 *
	 * @param	e		The Entity you collided with.
	 *
	 * @return	If there was a collision.
	 */
	public function moveCollideX(e:Entity):Bool
	{
		return true;
	}

	/**
	 * When you collide with an Entity on the y-axis with moveTo() or moveBy()
	 * the engine call this function. Override it to detect and change the
	 * behaviour of collisions.
	 *
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
	var _class:String;
	var _scene:Scene;
	var _type:String;
	var _layer:Int = 0;
	var _name:String;
	var _frames:Int = -1;

	var _recycleNext:Entity;

	// Collision information.
	var HITBOX:Mask;
	var _mask:Mask;
	var _x:Float = 0;
	var _y:Float = 0;
	var _moveX:Float = 0;
	var _moveY:Float = 0;

	// Rendering information.
	var _point:Point;

	static var _EMPTY:Entity = new Entity();
}
