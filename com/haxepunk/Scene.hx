package com.haxepunk;

import com.haxepunk.graphics.atlas.AtlasData;
import flash.display.Sprite;
import flash.geom.Point;
import com.haxepunk.Entity;
import com.haxepunk.Tweener;
import flash.geom.Rectangle;
import haxe.ds.IntMap;

/**
 * Updated by Engine, main game container that holds all currently active Entities.
 * Useful for organization, eg. "Menu", "Level1", etc.
 */
class Scene extends Tweener
{
	/**
	 * If the render() loop is performed.
	 */
	public var visible:Bool;

	/**
	 * Point used to determine drawing offset in the render loop.
	 */
	public var camera:Point;

	/**
	 * Constructor.
	 */
	public function new()
	{
		super();
		visible = true;
		camera = new Point();
		_count = 0;

		_layerList = new Array<Int>();
		_layerCount = new Map<Int, Int>();
		_sprite = new Sprite();

		_add = new Array<Entity>();
		_remove = new Array<Entity>();
		_recycle = new Array<Entity>();

		_layerDisplay = new Map<Int,Bool>();
		_renderFirst = new Map<Int,FriendEntity>();
		_renderLast = new Map<Int,FriendEntity>();
		_typeFirst = new Map<String,FriendEntity>();

		_classCount = new Map<String,Int>();
		_typeCount = new Map<String,Int>();
		_recycled = new Map<String,Entity>();
		_entityNames = new Map<String,Entity>();
	}

	/**
	 * Override this; called when Scene is switch to, and set to the currently active scene.
	 */
	public function begin() { }

	/**
	 * Override this; called when Scene is changed, and the active scene is no longer this.
	 */
	public function end() { }

	/**
	 * Override this, called when game gains focus
	 */
	public function focusGained() { }

	/**
	 * Override this, called when game loses focus
	 */
	public function focusLost() { }

	/**
	 * Performed by the game loop, updates all contained Entities.
	 * If you override this to give your Scene update code, remember
	 * to call super.update() or your Entities will not be updated.
	 */
	override public function update()
	{
		// update the entities
		var e:Entity,
			fe:FriendEntity = _updateFirst;
		while (fe != null)
		{
			e = cast(fe, Entity);
			if (e.active)
			{
				if (e.hasTween) e.updateTweens();
				e.update();
			}
			if (e.graphic != null && e.graphic.active) e.graphic.update();
			fe = fe._updateNext;
		}
	}

	/**
	 * Toggles the visibility of a layer
	 * @param layer the layer to show/hide
	 * @param show whether to show the layer (default: true)
	 */
	public inline function showLayer(layer:Int, show:Bool=true):Void
	{
		_layerDisplay.set(layer, show);
	}

	/**
	 * Checks if a layer is visible or not
	 */
	public inline function layerVisible(layer:Int):Bool
	{
		return !_layerDisplay.exists(layer) || _layerDisplay.get(layer);
	}

	/**
	 * Sorts layer from highest value to lowest
	 */
	private function layerSort(a:Int, b:Int):Int
	{
		return b - a;
	}

	/**
	 * Performed by the game loop, renders all contained Entities.
	 * If you override this to give your Scene render code, remember
	 * to call super.render() or your Entities will not be rendered.
	 */
	public function render()
	{
		// sort the depth list
		if (_layerSort)
		{
			if (_layerList.length > 1) _layerList.sort(layerSort);
			_layerSort = false;
		}

		if (HXP.renderMode == RenderMode.HARDWARE)
			AtlasData.startScene(this);

		// render the entities in order of depth
		var e:Entity,
			fe:FriendEntity;
		for (layer in _layerList)
		{
			if (!layerVisible(layer)) continue;
			fe = _renderLast.get(layer);
			while (fe != null)
			{
				e = cast(fe, Entity);
				if (e.visible) e.render();
				fe = fe._renderPrev;
			}
		}

		if (HXP.renderMode == RenderMode.HARDWARE)
			AtlasData.endScene();
	}

	/**
	 * X position of the mouse in the Scene.
	 */
	public var mouseX(get, null):Int;
	private inline function get_mouseX():Int
	{
		return Std.int(HXP.screen.mouseX + camera.x);
	}

	/**
	 * Y position of the mouse in the scene.
	 */
	public var mouseY(get, null):Int;
	private inline function get_mouseY():Int
	{
		return Std.int(HXP.screen.mouseY + camera.y);
	}

	/**
	 * Sprite used to store layer sprites when RenderMode.HARDWARE is set.
	 */
	public var sprite(get, null):Sprite;
	private inline function get_sprite():Sprite
	{
		return _sprite;
	}

	/**
	 * Adds the Entity to the Scene at the end of the frame.
	 * @param	e		Entity object you want to add.
	 * @return	The added Entity object.
	 */
	public function add<E:Entity>(e:E):E
	{
		_add[_add.length] = e;
		return e;
	}

	/**
	 * Removes the Entity from the Scene at the end of the frame.
	 * @param	e		Entity object you want to remove.
	 * @return	The removed Entity object.
	 */
	public function remove<E:Entity>(e:E):E
	{
		_remove[_remove.length] = e;
		return e;
	}

	/**
	 * Removes all Entities from the Scene at the end of the frame.
	 */
	public function removeAll()
	{
		var fe:FriendEntity = _updateFirst;
		while (fe != null)
		{
			_remove[_remove.length] = cast(fe, Entity);
			fe = fe._updateNext;
		}
	}

	/**
	 * Adds multiple Entities to the scene.
	 * @param	...list		Several Entities (as arguments) or an Array/Vector of Entities.
	 */
	public function addList<E:Entity>(list:Iterable<E>)
	{
		for (e in list) add(e);
	}

	/**
	 * Removes multiple Entities from the scene.
	 * @param	...list		Several Entities (as arguments) or an Array/Vector of Entities.
	 */
	public function removeList<E:Entity>(list:Iterable<E>)
	{
		for (e in list) remove(e);
	}

	/**
	 * Adds an Entity to the Scene with the Graphic object.
	 * @param	graphic		Graphic to assign the Entity.
	 * @param	x			X position of the Entity.
	 * @param	y			Y position of the Entity.
	 * @param	layer		Layer of the Entity.
	 * @return	The Entity that was added.
	 */
	public function addGraphic(graphic:Graphic, layer:Int = 0, x:Float = 0, y:Float = 0):Entity
	{
		var e:Entity = new Entity(x, y, graphic);
		e.layer = layer;
		e.active = false;
		return add(e);
	}

	/**
	 * Adds an Entity to the Scene with the Mask object.
	 * @param	mask	Mask to assign the Entity.
	 * @param	type	Collision type of the Entity.
	 * @param	x		X position of the Entity.
	 * @param	y		Y position of the Entity.
	 * @return	The Entity that was added.
	 */
	public function addMask(mask:Mask, type:String, x:Int = 0, y:Int = 0):Entity
	{
		var e:Entity = new Entity(x, y, null, mask);
		if (type != "") e.type = type;
		e.active = e.visible = false;
		return add(e);
	}

	/**
	 * Returns a new Entity, or a stored recycled Entity if one exists.
	 * @param	classType			The Class of the Entity you want to add.
	 * @param	addToScene			Add it to the Scene immediately.
	 * @param	constructorsArgs	List of the entity constructor arguments (optional).
	 * @return	The new Entity object.
	 */
	public function create<E:Entity>(classType:Class<E>, addToScene:Bool = true, ?constructorsArgs:Array<Dynamic>):E
	{
		var className:String = Type.getClassName(classType);
		var fe:FriendEntity = _recycled.get(className);
		if (fe != null)
		{
			_recycled.set(className, fe._recycleNext);
			fe._recycleNext = null;
		}
		else
		{
			if (constructorsArgs != null)
				fe = Type.createInstance(classType, constructorsArgs);
			else
				fe = Type.createInstance(classType, []);
		}
		var e:E = cast fe;

		if (addToScene)
			return add(e);

		return e;
	}

	/**
	 * Removes the Entity from the Scene at the end of the frame and recycles it.
	 * The recycled Entity can then be fetched again by calling the create() function.
	 * @param	e		The Entity to recycle.
	 * @return	The recycled Entity.
	 */
	public function recycle<E:Entity>(e:E):E
	{
		_recycle[_recycle.length] = e;
		return remove(e);
	}

	/**
	 * Clears stored reycled Entities of the Class type.
	 * @param	classType		The Class type to clear.
	 */
	public function clearRecycled(classType:String)
	{
		var e:Entity = _recycled.get(classType),
			fe:FriendEntity,
			n:Entity;
		while (e != null)
		{
			fe = e;
			n = fe._recycleNext;
			fe._recycleNext = null;
			e = n;
		}
		_recycled.set(classType, null);
	}

	/**
	 * Clears stored recycled Entities of all Class types.
	 */
	public function clearRecycledAll()
	{
		var e:Entity,
			fe:FriendEntity;
		for (e in _recycled)
		{
			fe = e;
			clearRecycled(fe._class);
		}
	}

	/**
	 * Brings the Entity to the front of its contained layer.
	 * @param	e		The Entity to shift.
	 * @return	If the Entity changed position.
	 */
	public function bringToFront(e:Entity):Bool
	{
		var fe:FriendEntity = e;
		if (fe._scene != this || fe._renderPrev == null) return false;
		// pull from list
		fe._renderPrev._renderNext = fe._renderNext;
		if (fe._renderNext != null) fe._renderNext._renderPrev = fe._renderPrev;
		else _renderLast.set(fe._layer, fe._renderPrev);
		// place at the start
		fe._renderNext = _renderFirst.get(fe._layer);
		fe._renderNext._renderPrev = e;
		_renderFirst.set(fe._layer, e);
		fe._renderPrev = null;
		return true;
	}

	/**
	 * Sends the Entity to the back of its contained layer.
	 * @param	e		The Entity to shift.
	 * @return	If the Entity changed position.
	 */
	public function sendToBack(e:Entity):Bool
	{
		var fe:FriendEntity = e;
		if (fe._scene != this || fe._renderNext == null) return false;
		// pull from list
		fe._renderNext._renderPrev = fe._renderPrev;
		if (fe._renderPrev != null) fe._renderPrev._renderNext = fe._renderNext;
		else _renderFirst.set(fe._layer, fe._renderNext);
		// place at the end
		fe._renderPrev = _renderLast.get(fe._layer);
		fe._renderPrev._renderNext = e;
		_renderLast.set(fe._layer, e);
		fe._renderNext = null;
		return true;
	}

	/**
	 * Shifts the Entity one place towards the front of its contained layer.
	 * @param	e		The Entity to shift.
	 * @return	If the Entity changed position.
	 */
	public function bringForward(e:Entity):Bool
	{
		var fe:FriendEntity = e;
		if (fe._scene != this || fe._renderPrev == null) return false;
		// pull from list
		fe._renderPrev._renderNext = fe._renderNext;
		if (fe._renderNext != null) fe._renderNext._renderPrev = fe._renderPrev;
		else _renderLast.set(fe._layer, fe._renderPrev);
		// shift towards the front
		fe._renderNext = fe._renderPrev;
		fe._renderPrev = fe._renderPrev._renderPrev;
		fe._renderNext._renderPrev = e;
		if (fe._renderPrev != null) fe._renderPrev._renderNext = e;
		else _renderFirst.set(fe._layer, e);
		return true;
	}

	/**
	 * Shifts the Entity one place towards the back of its contained layer.
	 * @param	e		The Entity to shift.
	 * @return	If the Entity changed position.
	 */
	public function sendBackward(e:Entity):Bool
	{
		var fe:FriendEntity = e;
		if (fe._scene != this || fe._renderNext == null) return false;
		// pull from list
		fe._renderNext._renderPrev = fe._renderPrev;
		if (fe._renderPrev != null) fe._renderPrev._renderNext = fe._renderNext;
		else _renderFirst.set(fe._layer, fe._renderNext);
		// shift towards the back
		fe._renderPrev = fe._renderNext;
		fe._renderNext = fe._renderNext._renderNext;
		fe._renderPrev._renderNext = e;
		if (fe._renderNext != null) fe._renderNext._renderPrev = e;
		else _renderLast.set(fe._layer, e);
		return true;
	}

	/**
	 * If the Entity as at the front of its layer.
	 * @param	e		The Entity to check.
	 * @return	True or false.
	 */
	public inline function isAtFront(e:Entity):Bool
	{
		var fe:FriendEntity = e;
		return fe._renderPrev == null;
	}

	/**
	 * If the Entity as at the back of its layer.
	 * @param	e		The Entity to check.
	 * @return	True or false.
	 */
	public inline function isAtBack(e:Entity):Bool
	{
		var fe:FriendEntity = e;
		return fe._renderNext == null;
	}

	/**
	 * Returns the first Entity that collides with the rectangular area.
	 * @param	type		The Entity type to check for.
	 * @param	rX			X position of the rectangle.
	 * @param	rY			Y position of the rectangle.
	 * @param	rWidth		Width of the rectangle.
	 * @param	rHeight		Height of the rectangle.
	 * @return	The first Entity to collide, or null if none collide.
	 */
	public function collideRect(type:String, rX:Float, rY:Float, rWidth:Float, rHeight:Float):Entity
	{
		var e:Entity,
			fe:FriendEntity = _typeFirst.get(type);
		while (fe != null)
		{
			e = cast(fe, Entity);
			if (e.collidable && e.collideRect(e.x, e.y, rX, rY, rWidth, rHeight)) return e;
			fe = fe._typeNext;
		}
		return null;
	}

	/**
	 * Returns the first Entity found that collides with the position.
	 * @param	type		The Entity type to check for.
	 * @param	pX			X position.
	 * @param	pY			Y position.
	 * @return	The collided Entity, or null if none collide.
	 */
	public function collidePoint(type:String, pX:Float, pY:Float):Entity
	{
		var e:Entity,
			fe:FriendEntity = _typeFirst.get(type),
			result:Entity = null;
		while (fe != null)
		{
			e = cast(fe, Entity);
			// only look for entities that collide
			if (e.collidable && e.collidePoint(e.x, e.y, pX, pY)) {
				// the first one might be the front one
				if (result == null) {
					result = e;
				// compare if the new collided entity is above the former one (lower valuer is toward, higher value is backward)
				} else if(e.layer < result.layer){
					result = e;
				}
			}
			fe = fe._typeNext;
		}
		return result;
	}

	/**
	 * Returns the first Entity found that collides with the line.
	 * @param	type		The Entity type to check for.
	 * @param	fromX		Start x of the line.
	 * @param	fromY		Start y of the line.
	 * @param	toX			End x of the line.
	 * @param	toY			End y of the line.
	 * @param	precision   Distance between consecutive tests. Higher values are faster but increase the chance of missing collisions.
	 * @param	p           If non-null, will have its x and y values set to the point of collision.
	 * @return	The first Entity to collide, or null if none collide.
	 */
	public function collideLine(type:String, fromX:Int, fromY:Int, toX:Int, toY:Int, precision:Int = 1, p:Point = null):Entity
	{
		// If the distance is less than precision, do the short sweep.
		if (precision < 1) precision = 1;
		if (HXP.distance(fromX, fromY, toX, toY) < precision)
		{
			if (p != null)
			{
				if (fromX == toX && fromY == toY)
				{
					p.x = toX; p.y = toY;
					return collidePoint(type, toX, toY);
				}
				return collideLine(type, fromX, fromY, toX, toY, 1, p);
			}
			else return collidePoint(type, fromX, toY);
		}

		// Get information about the line we're about to raycast.
		var xDelta:Int = Std.int(Math.abs(toX - fromX)),
			yDelta:Int = Std.int(Math.abs(toY - fromY)),
			xSign:Float = toX > fromX ? precision : -precision,
			ySign:Float = toY > fromY ? precision : -precision,
			x:Float = fromX, y:Float = fromY, e:Entity;

		// Do a raycast from the start to the end point.
		if (xDelta > yDelta)
		{
			ySign *= yDelta / xDelta;
			if (xSign > 0)
			{
				while (x < toX)
				{
					if ((e = collidePoint(type, x, y)) != null)
					{
						if (p == null) return e;
						if (precision < 2)
						{
							p.x = x - xSign; p.y = y - ySign;
							return e;
						}
						return collideLine(type, Std.int(x - xSign), Std.int(y - ySign), toX, toY, 1, p);
					}
					x += xSign; y += ySign;
				}
			}
			else
			{
				while (x > toX)
				{
					if ((e = collidePoint(type, x, y)) != null)
					{
						if (p == null) return e;
						if (precision < 2)
						{
							p.x = x - xSign; p.y = y - ySign;
							return e;
						}
						return collideLine(type, Std.int(x - xSign), Std.int(y - ySign), toX, toY, 1, p);
					}
					x += xSign; y += ySign;
				}
			}
		}
		else
		{
			xSign *= xDelta / yDelta;
			if (ySign > 0)
			{
				while (y < toY)
				{
					if ((e = collidePoint(type, x, y)) != null)
					{
						if (p == null) return e;
						if (precision < 2)
						{
							p.x = x - xSign; p.y = y - ySign;
							return e;
						}
						return collideLine(type, Std.int(x - xSign), Std.int(y - ySign), toX, toY, 1, p);
					}
					x += xSign; y += ySign;
				}
			}
			else
			{
				while (y > toY)
				{
					if ((e = collidePoint(type, x, y)) != null)
					{
						if (p == null) return e;
						if (precision < 2)
						{
							p.x = x - xSign; p.y = y - ySign;
							return e;
						}
						return collideLine(type, Std.int(x - xSign), Std.int(y - ySign), toX, toY, 1, p);
					}
					x += xSign; y += ySign;
				}
			}
		}

		// Check the last position.
		if (precision > 1)
		{
			if (p == null) return collidePoint(type, toX, toY);
			if (collidePoint(type, toX, toY) != null) return collideLine(type, Std.int(x - xSign), Std.int(y - ySign), toX, toY, 1, p);
		}

		// No collision, return the end point.
		if (p != null)
		{
			p.x = toX;
			p.y = toY;
		}
		return null;
	}

	/**
	 * Populates an array with all Entities that collide with the rectangle. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	type		The Entity type to check for.
	 * @param	rX			X position of the rectangle.
	 * @param	rY			Y position of the rectangle.
	 * @param	rWidth		Width of the rectangle.
	 * @param	rHeight		Height of the rectangle.
	 * @param	into		The Array or Vector to populate with collided Entities.
	 */
	public function collideRectInto<E:Entity>(type:String, rX:Float, rY:Float, rWidth:Float, rHeight:Float, into:Array<E>)
	{
		var e:E,
			fe:FriendEntity = _typeFirst.get(type),
			n:Int = into.length;
		while (fe != null)
		{
			e = cast fe;
			if (e.collidable && e.collideRect(e.x, e.y, rX, rY, rWidth, rHeight)) into[n ++] = e;
			fe = fe._typeNext;
		}
	}

	/**
	 * Populates an array with all Entities that collide with the circle. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	type 		The Entity type to check for.
	 * @param	circleX		X position of the circle.
	 * @param	circleY		Y position of the circle.
	 * @param	radius		The radius of the circle.
	 * @param	into		The Array or Vector to populate with collided Entities.
	 */
	public function collideCircleInto<E:Entity>(type:String, circleX:Float, circleY:Float, radius:Float , into:Array<E>)
	{
		var e:Entity,
			fe:FriendEntity = _typeFirst.get(type),
			n:Int = into.length;

		radius *= radius;//Square it to avoid the square root
		while (fe != null)
		{
			e = cast fe;
			if (HXP.distanceSquared(circleX, circleY, e.x, e.y) < radius) into[n ++] = cast e;
			fe = fe._typeNext;
		}
	}

	/**
	 * Populates an array with all Entities that collide with the position. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	type		The Entity type to check for.
	 * @param	pX			X position.
	 * @param	pY			Y position.
	 * @param	into		The Array or Vector to populate with collided Entities.
	 */
	public function collidePointInto<E:Entity>(type:String, pX:Float, pY:Float, into:Array<E>)
	{
		var e:E,
			fe:FriendEntity = _typeFirst.get(type),
			n:Int = into.length;
		while (fe != null)
		{
			e = cast fe;
			if (e.collidable && e.collidePoint(e.x, e.y, pX, pY)) into[n ++] = e;
			fe = fe._typeNext;
		}
	}

	/**
	 * Finds the Entity nearest to the rectangle.
	 * @param	type		The Entity type to check for.
	 * @param	x			X position of the rectangle.
	 * @param	y			Y position of the rectangle.
	 * @param	width		Width of the rectangle.
	 * @param	height		Height of the rectangle.
	 * @return	The nearest Entity to the rectangle.
	 */
	public function nearestToRect(type:String, x:Float, y:Float, width:Float, height:Float):Entity
	{
		var n:Entity,
			fe:FriendEntity = _typeFirst.get(type),
			nearDist:Float = HXP.NUMBER_MAX_VALUE,
			near:Entity = null, dist:Float;
		while (fe != null)
		{
			n = cast(fe, Entity);
			dist = squareRects(x, y, width, height, n.x - n.originX, n.y - n.originY, n.width, n.height);
			if (dist < nearDist)
			{
				nearDist = dist;
				near = n;
			}
			fe = fe._typeNext;
		}
		return near;
	}

	/**
	 * Finds the Entity nearest to another.
	 * @param	type		The Entity type to check for.
	 * @param	e			The Entity to find the nearest to.
	 * @param	useHitboxes	If the Entities' hitboxes should be used to determine the distance. If false, their x/y coordinates are used.
	 * @return	The nearest Entity to e.
	 */
	public function nearestToEntity(type:String, e:Entity, useHitboxes:Bool = false):Entity
	{
		if (useHitboxes) return nearestToRect(type, e.x - e.originX, e.y - e.originY, e.width, e.height);
		var n:Entity,
			fe:FriendEntity = _typeFirst.get(type),
			nearDist:Float = HXP.NUMBER_MAX_VALUE,
			near:Entity = null,
			dist:Float,
			x:Float = e.x - e.originX,
			y:Float = e.y - e.originY;
		while (fe != null)
		{
			n = cast(fe, Entity);
			dist = (x - n.x) * (x - n.x) + (y - n.y) * (y - n.y);
			if (dist < nearDist)
			{
				nearDist = dist;
				near = n;
			}
			fe = fe._typeNext;
		}
		return near;
	}


	/**
	 * Finds the Entity nearest to another.
	 * @param	type		The Entity type to check for.
	 * @param	e			The Entity to find the nearest to.
	 * @param	classType	The Entity class to check for.
	 * @param	useHitboxes	If the Entities' hitboxes should be used to determine the distance. If false, their x/y coordinates are used.
	 * @return	The nearest Entity to e.
	 */
	public function nearestToClass(type:String, e:Entity, classType:Dynamic, useHitboxes:Bool = false):Entity
	{
		if (useHitboxes) return nearestToRect(type, e.x - e.originX, e.y - e.originY, e.width, e.height);
		var n:Entity,
			fe:FriendEntity = _typeFirst.get(type),
			nearDist:Float = HXP.NUMBER_MAX_VALUE,
			near:Entity = null,
			dist:Float,
			x:Float = e.x - e.originX,
			y:Float = e.y - e.originY;
		while (fe != null)
		{
			n = cast(fe, Entity);
			dist = (x - n.x) * (x - n.x) + (y - n.y) * (y - n.y);
			if (dist < nearDist && Std.is(e, classType))
			{
				nearDist = dist;
				near = n;
			}
			fe = fe._typeNext;
		}
		return near;
	}

	/**
	 * Finds the Entity nearest to the position.
	 * @param	type		The Entity type to check for.
	 * @param	x			X position.
	 * @param	y			Y position.
	 * @param	useHitboxes	If the Entities' hitboxes should be used to determine the distance. If false, their x/y coordinates are used.
	 * @return	The nearest Entity to the position.
	 */
	public function nearestToPoint(type:String, x:Float, y:Float, useHitboxes:Bool = false):Entity
	{
		var n:Entity,
			fe:FriendEntity = _typeFirst.get(type),
			nearDist:Float = HXP.NUMBER_MAX_VALUE,
			near:Entity = null,
			dist:Float;
		if (useHitboxes)
		{
			while (fe != null)
			{
				n = cast(fe, Entity);
				dist = squarePointRect(x, y, n.x - n.originX, n.y - n.originY, n.width, n.height);
				if (dist < nearDist)
				{
					nearDist = dist;
					near = n;
				}
				fe = fe._typeNext;
			}
			return near;
		}
		while (fe != null)
		{
			n = cast(fe, Entity);
			dist = (x - n.x) * (x - n.x) + (y - n.y) * (y - n.y);
			if (dist < nearDist)
			{
				nearDist = dist;
				near = n;
			}
			fe = fe._typeNext;
		}
		return near;
	}

	/**
	 * How many Entities are in the Scene.
	 */
	public var count(get, never):Int;
	private inline function get_count():Int { return _count; }

	/**
	 * Returns the amount of Entities of the type are in the Scene.
	 * @param	type		The type (or Class type) to count.
	 * @return	How many Entities of type exist in the Scene.
	 */
	public inline function typeCount(type:String):Int
	{
		return _typeCount.get(type);
	}

	/**
	 * Returns the amount of Entities of the Class are in the Scene.
	 * @param	c		The Class type to count.
	 * @return	How many Entities of Class exist in the Scene.
	 */
	public inline function classCount(c:String):Int
	{
		return _classCount.get(c);
	}

	/**
	 * Returns the amount of Entities are on the layer in the Scene.
	 * @param	layer		The layer to count Entities on.
	 * @return	How many Entities are on the layer.
	 */
	public inline function layerCount(layer:Int):Int
	{
		return _layerCount[layer];
	}

	/**
	 * The first Entity in the Scene.
	 */
	public var first(get, null):Entity;
	private inline function get_first():Entity { return cast(_updateFirst, Entity); }

	/**
	 * How many Entity layers the Scene has.
	 */
	public var layers(get, null):Int;
	private inline function get_layers():Int { return _layerList.length; }

	/**
	 * The first Entity of the type.
	 * @param	type		The type to check.
	 * @return	The Entity.
	 */
	public function typeFirst(type:String):Entity
	{
		if (_updateFirst == null) return null;
		return cast(_typeFirst.get(type), Entity);
	}

	/**
	 * The first Entity of the Class.
	 * @param	c		The Class type to check.
	 * @return	The Entity.
	 */
	public function classFirst<E:Entity>(c:Class<E>):E
	{
		if (_updateFirst == null) return null;
		var fe:FriendEntity = _updateFirst;
		while (fe != null)
		{
			if (Std.is(fe, c)) return cast fe;
			fe = fe._updateNext;
		}
		return null;
	}

	/**
	 * The first Entity on the Layer.
	 * @param	layer		The layer to check.
	 * @return	The Entity.
	 */
	public function layerFirst(layer:Int):Entity
	{
		if (_updateFirst == null) return null;
		return cast(_renderFirst.get(layer), Entity);
	}

	/**
	 * The last Entity on the Layer.
	 * @param	layer		The layer to check.
	 * @return	The Entity.
	 */
	public function layerLast(layer:Int):Entity
	{
		if (_updateFirst == null) return null;
		return cast(_renderLast.get(layer), Entity);
	}

	/**
	 * The Entity that will be rendered first by the Scene.
	 */
	public var farthest(get, null):Entity;
	private function get_farthest():Entity
	{
		if (_updateFirst == null) return null;
		return cast(_renderLast.get(_layerList[_layerList.length - 1]), Entity);
	}

	/**
	 * The Entity that will be rendered last by the scene.
	 */
	public var nearest(get, null):Entity;
	private function get_nearest():Entity
	{
		if (_updateFirst == null) return null;
		return cast(_renderFirst.get(_layerList[0]), Entity);
	}

	/**
	 * The layer that will be rendered first by the Scene.
	 */
	public var layerFarthest(get, null):Int;
	private function get_layerFarthest():Int
	{
		if (_updateFirst == null) return 0;
		return _layerList[_layerList.length - 1];
	}

	/**
	 * The layer that will be rendered last by the Scene.
	 */
	public var layerNearest(get, null):Int;
	private function get_layerNearest():Int
	{
		if (_updateFirst == null) return 0;
		return _layerList[0];
	}

	/**
	 * How many different types have been added to the Scene.
	 */
	public var uniqueTypes(get, null):Int;
	private inline function get_uniqueTypes():Int
	{
		var i:Int = 0;
		for (type in _typeCount) i++;
		return i;
	}

	/**
	 * Pushes all Entities in the Scene of the type into the Array or Vector. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	type		The type to check.
	 * @param	into		The Array or Vector to populate.
	 */
	public function getType<E:Entity>(type:String, into:Array<E>)
	{
		var fe:FriendEntity = _typeFirst.get(type),
			n:Int = into.length;
		while (fe != null)
		{
			into[n++] = cast fe;
			fe = fe._typeNext;
		}
	}

	/**
	 * Pushes all Entities in the Scene of the Class into the Array or Vector. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	c			The Class type to check.
	 * @param	into		The Array or Vector to populate.
	 */
	public function getClass<E:Entity>(c:Class<Dynamic>, into:Array<E>)
	{
		var fe:FriendEntity = _updateFirst,
			n:Int = into.length;
		while (fe != null)
		{
			if (Std.is(fe, c))
				into[n++] = cast fe;
			fe = fe._updateNext;
		}
	}

	/**
	 * Pushes all Entities in the Scene on the layer into the Array or Vector. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	layer		The layer to check.
	 * @param	into		The Array or Vector to populate.
	 */
	public function getLayer<E:Entity>(layer:Int, into:Array<E>)
	{
		var e:E,
			fe:FriendEntity = _renderLast.get(layer),
			n:Int = into.length;
		while (fe != null)
		{
			e = cast fe;
			into[n ++] = e;
			fe = fe._updatePrev;
		}
	}

	/**
	 * Pushes all Entities in the Scene into the array. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	into		The Array or Vector to populate.
	 */
	public function getAll<E:Entity>(into:Array<E>)
	{
		var e:E,
			fe:FriendEntity = _updateFirst,
			n:Int = into.length;
		while (fe != null)
		{
			e = cast fe;
			into[n ++] = e;
			fe = fe._updateNext;
		}
	}

	/**
	 * Returns the Entity with the instance name, or null if none exists
	 * @param	name
	 * @return	The Entity.
	 */
	public function getInstance(name:String):Entity
	{
		return _entityNames.get(name);
	}

	/**
	 * Updates the add/remove lists at the end of the frame.
	 * @param	shouldAdd	If new Entities should be added to the scene.
	 */
	public function updateLists(shouldAdd:Bool = true)
	{
		var e:Entity;
		var fe:FriendEntity;

		// remove entities
		if (_remove.length > 0)
		{
			for (e in _remove)
			{
				fe = e;
				if (fe._scene == null)
				{
					var idx = HXP.indexOf(_add, e);
					if (idx >= 0) _add.splice(idx, 1);
					continue;
				}
				if (fe._scene != this)
					continue;
				e.removed();
				fe._scene = null;
				removeUpdate(e);
				removeRender(e);
				if (fe._type != "") removeType(e);
				if (fe._name != "") unregisterName(e);
				if (e.autoClear && e.hasTween) e.clearTweens();
			}
			HXP.clear(_remove);
		}

		// add entities
		if (shouldAdd && _add.length > 0)
		{
			for (e in _add)
			{
				fe = e;
				if (fe._scene != null) continue;
				fe._scene = this;
				addUpdate(e);
				addRender(e);
				if (fe._type != "") addType(e);
				if (fe._name != "") registerName(e);
				e.added();
			}
			HXP.clear(_add);
		}

		// recycle entities
		if (_recycle.length > 0)
		{
			for (e in _recycle)
			{
				fe = e;
				if (fe._scene != null || fe._recycleNext != null)
					continue;

				fe._recycleNext = _recycled.get(fe._class);
				_recycled.set(fe._class, e);
			}
			HXP.clear(_recycle);
		}
	}

	/** @private Adds Entity to the update list. */
	private function addUpdate(e:Entity)
	{
		var fe:FriendEntity = e;

		// add to update list
		if (_updateFirst != null)
		{
			_updateFirst._updatePrev = e;
			fe._updateNext = _updateFirst;
		}
		else fe._updateNext = null;
		fe._updatePrev = null;
		_updateFirst = e;
		_count ++;
		if (_classCount.get(fe._class) != 0) _classCount.set(fe._class, 0);
		_classCount.set(fe._class, _classCount.get(fe._class) + 1); // increment
	}

	/** @private Removes Entity from the update list. */
	private function removeUpdate(e:Entity)
	{
		var fe:FriendEntity = e;

		// remove from the update list
		if (_updateFirst == e) _updateFirst = fe._updateNext;
		if (fe._updateNext != null) fe._updateNext._updatePrev = fe._updatePrev;
		if (fe._updatePrev != null) fe._updatePrev._updateNext = fe._updateNext;
		fe._updateNext = fe._updatePrev = null;
		_count --;
		_classCount.set(fe._class, _classCount.get(fe._class) - 1); // decrement
	}

	/** @private Adds Entity to the render list. */
	public function addRender(e:Entity)
	{
		var fe:FriendEntity = e;
		var f:FriendEntity = _renderFirst.get(fe._layer);
		if (f != null)
		{
			// Append entity to existing layer.
			fe._renderNext = f;
			f._renderPrev = e;
			_layerCount[fe._layer] = _layerCount[fe._layer] + 1;
		}
		else
		{
			// Create new layer with entity.
			_renderLast.set(fe._layer, e);
			_layerList[_layerList.length] = fe._layer;
			_layerSort = true;
			fe._renderNext = null;
			_layerCount[fe._layer] = 1;
		}
		_renderFirst.set(fe._layer, e);
		fe._renderPrev = null;
	}

	/** @private Removes Entity from the render list. */
	public function removeRender(e:Entity)
	{
		var fe:FriendEntity = e;
		if (fe._renderNext != null) fe._renderNext._renderPrev = fe._renderPrev;
		else _renderLast.set(fe._layer, fe._renderPrev);
		if (fe._renderPrev != null) fe._renderPrev._renderNext = fe._renderNext;
		else
		{
			// Remove this entity from the layer.
			_renderFirst.set(fe._layer, fe._renderNext);
			if (fe._renderNext == null)
			{
				// Remove the layer from the layer list if this was the last entity.
				if (_layerList.length > 1)
				{
					_layerList[HXP.indexOf(_layerList, fe._layer)] = _layerList[_layerList.length - 1];
					_layerSort = true;
				}
				_layerList.pop();
			}
		}
		var newLayerCount:Int = _layerCount[fe._layer] - 1;
		if (newLayerCount > 0) {
			_layerCount[fe._layer] = newLayerCount;
		} else {
			// Remove layer from maps if it contains 0 entities.
			_layerCount.remove(fe._layer);
			_renderFirst.remove(fe._layer);
			_renderLast.remove(fe._layer);
		}
		fe._renderNext = fe._renderPrev = null;
	}

	/** @private Adds Entity to the type list. */
	public function addType(e:Entity)
	{
		var fe:FriendEntity = e;
		// add to type list
		if (_typeFirst.get(fe._type) != null)
		{
			_typeFirst.get(fe._type)._typePrev = e;
			fe._typeNext = _typeFirst.get(fe._type);
			_typeCount.set(fe._type, _typeCount.get(fe._type) + 1);
		}
		else
		{
			fe._typeNext = null;
			_typeCount.set(fe._type, 1);
		}
		fe._typePrev = null;
		_typeFirst.set(fe._type, e);
	}

	/** @private Removes Entity from the type list. */
	public function removeType(e:Entity)
	{
		var fe:FriendEntity = e;
		// remove from the type list
		if (_typeFirst.get(fe._type) == e) _typeFirst.set(fe._type, fe._typeNext);
		if (fe._typeNext != null) fe._typeNext._typePrev = fe._typePrev;
		if (fe._typePrev != null) fe._typePrev._typeNext = fe._typeNext;
		fe._typeNext = fe._typePrev = null;
		_typeCount.set(fe._type, _typeCount.get(fe._type) - 1);
	}

	/** @private Register the entities instance name. */
	public function registerName(e:Entity)
	{
		var fe:FriendEntity = e;
		_entityNames.set(fe._name, e);
	}

	/** @private Unregister the entities instance name. */
	public function unregisterName(e:Entity):Void
	{
		var fe:FriendEntity = e;
		_entityNames.remove(fe._name);
	}

	/** @private Calculates the squared distance between two rectangles. */
	private static function squareRects(x1:Float, y1:Float, w1:Float, h1:Float, x2:Float, y2:Float, w2:Float, h2:Float):Float
	{
		if (x1 < x2 + w2 && x2 < x1 + w1)
		{
			if (y1 < y2 + h2 && y2 < y1 + h1) return 0;
			if (y1 > y2) return (y1 - (y2 + h2)) * (y1 - (y2 + h2));
			return (y2 - (y1 + h1)) * (y2 - (y1 + h1));
		}
		if (y1 < y2 + h2 && y2 < y1 + h1)
		{
			if (x1 > x2) return (x1 - (x2 + w2)) * (x1 - (x2 + w2));
			return (x2 - (x1 + w1)) * (x2 - (x1 + w1));
		}
		if (x1 > x2)
		{
			if (y1 > y2) return squarePoints(x1, y1, (x2 + w2), (y2 + h2));
			return squarePoints(x1, y1 + h1, x2 + w2, y2);
		}
		if (y1 > y2) return squarePoints(x1 + w1, y1, x2, y2 + h2);
		return squarePoints(x1 + w1, y1 + h1, x2, y2);
	}

	/** @private Calculates the squared distance between two points. */
	private static function squarePoints(x1:Float, y1:Float, x2:Float, y2:Float):Float
	{
		return (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2);
	}

	/** @private Calculates the squared distance between a rectangle and a point. */
	private static function squarePointRect(px:Float, py:Float, rx:Float, ry:Float, rw:Float, rh:Float):Float
	{
		if (px >= rx && px <= rx + rw)
		{
			if (py >= ry && py <= ry + rh) return 0;
			if (py > ry) return (py - (ry + rh)) * (py - (ry + rh));
			return (ry - py) * (ry - py);
		}
		if (py >= ry && py <= ry + rh)
		{
			if (px > rx) return (px - (rx + rw)) * (px - (rx + rw));
			return (rx - px) * (rx - px);
		}
		if (px > rx)
		{
			if (py > ry) return squarePoints(px, py, rx + rw, ry + rh);
			return squarePoints(px, py, rx + rw, ry);
		}
		if (py > ry) return squarePoints(px, py, rx, ry + rh);
		return squarePoints(px, py, rx, ry);
	}

	// Adding and removal.
	private var _add:Array<Entity>;
	private var _remove:Array<Entity>;
	private var _recycle:Array<Entity>;

	// Update information.
	private var _updateFirst:FriendEntity;
	private var _count:Int;

	// Render information.
	private var _sprite:Sprite;
	private var _layerSort:Bool;
	private var _layerList:Array<Int>;
	private var _layerDisplay:Map<Int,Bool>;
	private var _layerCount:Map<Int, Int>;
	private var _renderFirst:Map<Int,FriendEntity>;
	private var _renderLast:Map<Int,FriendEntity>;

	private var _classCount:Map<String,Int>;
	public var _typeFirst:Map<String,FriendEntity>;
	private var _typeCount:Map<String,Int>;
	private var _recycled:Map<String,Entity>;
	private var _entityNames:Map<String,Entity>;
}
