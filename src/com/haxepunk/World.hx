package com.haxepunk;

import flash.geom.Point;
import flash.utils.Dictionary;
import com.haxepunk.utils.Input;

/**
 * Updated by Engine, main game container that holds all currently active Entities.
 * Useful for organization, eg. "Menu", "Level1", etc.
 */
class World extends Tweener
{
	/**
	 * If the render() loop is performed.
	 */
	public var visible:Bool;
	
	/**
	 * Point used to determine drawing offset in the render loop.
	 */
	public var camera:Point;
	
	// Flash equivalent: Number.MAX_VALUE
	public static inline var NUMBER_MAX_VALUE = untyped __global__["Number"].MAX_VALUE;
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		visible = true;
		camera = new Point();
		
		_layerList = new Array<Int>();
		_layerCount = new Array<Int>();
		
		_renderFirst = new Array<Entity>();
		_renderLast = new Array<Entity>();
		
		_typeFirst = new Hash<Entity>();
		
		_add = new Array<Entity>();
		_remove = new Array<Entity>();
		_classCount = new Hash<Int>();
		_recycled = new Hash<Entity>();
	}
	
	/**
	 * Override this; called when World is switch to, and set to the currently active world.
	 */
	public function begin()
	{
		
	}
	
	/**
	 * Override this; called when World is changed, and the active world is no longer this.
	 */
	public function end()
	{
		
	}
	
	/**
	 * Performed by the game loop, updates all contained Entities.
	 * If you override this to give your World update code, remember
	 * to call super.update() or your Entities will not be updated.
	 */
	override public function update() 
	{
		// update the entities
		var e:Entity = _updateFirst;
		while (e != null)
		{
			if (e.active)
			{
				if (e.tween != null) e.updateTweens();
				e.update();
			}
			if (e.graphic != null && e.graphic.active) e.graphic.update();
			e = e.updateNext;
		}
	}
	
	/**
	 * Performed by the game loop, renders all contained Entities.
	 * If you override this to give your World render code, remember
	 * to call super.render() or your Entities will not be rendered.
	 */
	public function render() 
	{
		// render the entities in order of depth
		var e:Entity,
			i:Int = _layerList.length;
		while (i-- > 0)
		{
			e = _renderLast[_layerList[i]];
			while (e != null)
			{
				if (e.visible) e.render();
				e = e.renderPrev;
			}
		}
	}
	
	/**
	 * X position of the mouse in the World.
	 */
	public var mouseX(getMouseX, null):Int;
	private function getMouseX():Int
	{
		return Std.int(HXP.screen.mouseX + HXP.camera.x);
	}
	
	/**
	 * Y position of the mouse in the world.
	 */
	public var mouseY(getMouseY, null):Int;
	private function getMouseY():Int
	{
		return Std.int(HXP.screen.mouseY + HXP.camera.y);
	}
	
	/**
	 * Adds the Entity to the World at the end of the frame.
	 * @param	e		Entity object you want to add.
	 * @return	The added Entity object.
	 */
	public function add(e:Entity):Entity
	{
		if (e._world != null) return e;
		_add.push(e);
		e._world = this;
		return e;
	}
	
	/**
	 * Removes the Entity from the World at the end of the frame.
	 * @param	e		Entity object you want to remove.
	 * @return	The removed Entity object.
	 */
	public function remove(e:Entity):Entity
	{
		if (e._world != this) return e;
		_remove.push(e);
		e._world = null;
		return e;
	}
	
	/**
	 * Removes all Entities from the World at the end of the frame.
	 */
	public function removeAll()
	{
		var e:Entity = _updateFirst;
		while (e != null)
		{
			_remove.push(e);
			e._world = null;
			e = e.updateNext;
		}
	}
	
	/**
	 * Adds multiple Entities to the world.
	 * @param	...list		Several Entities (as arguments) or an Array/Vector of Entities.
	 */
	public function addList(list:Array<Entity>)
	{
		var e:Entity;
		for (e in list) add(e);
	}
	
	/**
	 * Removes multiple Entities from the world.
	 * @param	...list		Several Entities (as arguments) or an Array/Vector of Entities.
	 */
	public function removeList(list:Array<Entity>)
	{
		var e:Entity;
		for (e in list) remove(e);
	}
	
	/**
	 * Adds an Entity to the World with the Graphic object.
	 * @param	graphic		Graphic to assign the Entity.
	 * @param	x			X position of the Entity.
	 * @param	y			Y position of the Entity.
	 * @param	layer		Layer of the Entity.
	 * @return	The Entity that was added.
	 */
	public function addGraphic(graphic:Graphic, layer:Int = 0, x:Int = 0, y:Int = 0):Entity
	{
		var e:Entity = new Entity(x, y, graphic);
		if (layer != 0) e.layer = layer;
		e.active = false;
		return add(e);
	}
	
	/**
	 * Adds an Entity to the World with the Mask object.
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
	 * @param	classType		The Class of the Entity you want to add.
	 * @param	addToWorld		Add it to the World immediately.
	 * @return	The new Entity object.
	 */
/*
	public function create(classType:String, addToWorld:Bool = true):Entity
	{
		var e:Entity = _recycled[String];
		if (e != null)
		{
			_recycled[classType] = e._recycleNext;
			e._recycleNext = null;
		}
		else e = new Type.createInstance();
		if (addToWorld) return add(e);
		return e;
	}
*/
	
	/**
	 * Removes the Entity from the World at the end of the frame and recycles it.
	 * The recycled Entity can then be fetched again by calling the create() function.
	 * @param	e		The Entity to recycle.
	 * @return	The recycled Entity.
	 */
	public function recycle(e:Entity):Entity
	{
		if (e._world != this) return e;
		e._recycleNext = _recycled.get(e._class);
		_recycled.set(e._class, e);
		return remove(e);
	}
	
	/**
	 * Clears stored reycled Entities of the Class type.
	 * @param	classType		The Class type to clear.
	 */
	public function clearRecycled(classType:String)
	{
		var e:Entity = _recycled.get(classType),
			n:Entity;
		while (e != null)
		{
			n = e._recycleNext;
			e._recycleNext = null;
			e = n;
		}
		_recycled.set(classType, null);
	}
	
	/**
	 * Clears stored recycled Entities of all Class types.
	 */
	public function clearRecycledAll()
	{
		var e:Entity;
		for (e in _recycled) clearRecycled(e._class);
	}
	
	/**
	 * Brings the Entity to the front of its contained layer.
	 * @param	e		The Entity to shift.
	 * @return	If the Entity changed position.
	 */
	public function bringToFront(e:Entity):Bool
	{
		if (e._world != this || e.renderPrev == null) return false;
		// pull from list
		e.renderPrev.renderNext = e.renderNext;
		if (e.renderNext != null) e.renderNext.renderPrev = e.renderPrev;
		else _renderLast[e._layer] = e.renderPrev;
		// place at the start
		e.renderNext = _renderFirst[e._layer];
		e.renderNext.renderPrev = e;
		_renderFirst[e._layer] = e;
		e.renderPrev = null;
		return true;
	}
	
	/**
	 * Sends the Entity to the back of its contained layer.
	 * @param	e		The Entity to shift.
	 * @return	If the Entity changed position.
	 */
	public function sendToBack(e:Entity):Bool
	{
		if (e._world != this || e.renderNext == null) return false;
		// pull from list
		e.renderNext.renderPrev = e.renderPrev;
		if (e.renderPrev != null) e.renderPrev.renderNext = e.renderNext;
		else _renderFirst[e._layer] = e.renderNext;
		// place at the end
		e.renderPrev = _renderLast[e._layer];
		e.renderPrev.renderNext = e;
		_renderLast[e._layer] = e;
		e.renderNext = null;
		return true;
	}
	
	/**
	 * Shifts the Entity one place towards the front of its contained layer.
	 * @param	e		The Entity to shift.
	 * @return	If the Entity changed position.
	 */
	public function bringForward(e:Entity):Bool
	{
		if (e._world != this || e.renderPrev == null) return false;
		// pull from list
		e.renderPrev.renderNext = e.renderNext;
		if (e.renderNext != null) e.renderNext.renderPrev = e.renderPrev;
		else _renderLast[e._layer] = e.renderPrev;
		// shift towards the front
		e.renderNext = e.renderPrev;
		e.renderPrev = e.renderPrev.renderPrev;
		e.renderNext.renderPrev = e;
		if (e.renderPrev != null) e.renderPrev.renderNext = e;
		else _renderFirst[e._layer] = e;
		return true;
	}
	
	/**
	 * Shifts the Entity one place towards the back of its contained layer.
	 * @param	e		The Entity to shift.
	 * @return	If the Entity changed position.
	 */
	public function sendBackward(e:Entity):Bool
	{
		if (e._world != this || e.renderNext == null) return false;
		// pull from list
		e.renderNext.renderPrev = e.renderPrev;
		if (e.renderPrev != null) e.renderPrev.renderNext = e.renderNext;
		else _renderFirst[e._layer] = e.renderNext;
		// shift towards the back
		e.renderPrev = e.renderNext;
		e.renderNext = e.renderNext.renderNext;
		e.renderPrev.renderNext = e;
		if (e.renderNext != null) e.renderNext.renderPrev = e;
		else _renderLast[e._layer] = e;
		return true;
	}
	
	/**
	 * If the Entity as at the front of its layer.
	 * @param	e		The Entity to check.
	 * @return	True or false.
	 */
	public function isAtFront(e:Entity):Bool
	{
		return e.renderPrev == null;
	}
	
	/**
	 * If the Entity as at the back of its layer.
	 * @param	e		The Entity to check.
	 * @return	True or false.
	 */
	public function isAtBack(e:Entity):Bool
	{
		return e.renderNext == null;
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
		var e:Entity = _typeFirst.get(type);
		while (e != null)
		{
			if (e.collideRect(e.x, e.y, rX, rY, rWidth, rHeight)) return e;
			e = e._typeNext;
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
		var e:Entity = _typeFirst.get(type);
		while (e != null)
		{
			if (e.collidePoint(e.x, e.y, pX, pY)) return e;
			e = e._typeNext;
		}
		return null;
	}
	
	/**
	 * Returns the first Entity found that collides with the line.
	 * @param	type		The Entity type to check for.
	 * @param	fromX		Start x of the line.
	 * @param	fromY		Start y of the line.
	 * @param	toX			End x of the line.
	 * @param	toY			End y of the line.
	 * @param	precision		
	 * @param	p
	 * @return
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
	public function collideRectInto(type:String, rX:Float, rY:Float, rWidth:Float, rHeight:Float, into:Array<Entity>)
	{
		var e:Entity = _typeFirst.get(type),
			n:Int = into.length;
		while (e != null)
		{
			if (e.collideRect(e.x, e.y, rX, rY, rWidth, rHeight)) into[n ++] = e;
			e = e._typeNext;
		}
	}
	
	/**
	 * Populates an array with all Entities that collide with the position. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	type		The Entity type to check for.
	 * @param	pX			X position.
	 * @param	pY			Y position.
	 * @param	into		The Array or Vector to populate with collided Entities.
	 * @return	The provided Array.
	 */
	public function collidePointInto(type:String, pX:Float, pY:Float, into:Array<Entity>)
	{
		var e:Entity = _typeFirst.get(type),
			n:Int = into.length;
		while (e != null)
		{
			if (e.collidePoint(e.x, e.y, pX, pY)) into[n ++] = e;
			e = e._typeNext;
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
		var n:Entity = _typeFirst.get(type),
			nearDist:Float = NUMBER_MAX_VALUE,
			near:Entity = null, dist:Float;
		while (n != null)
		{
			dist = squareRects(x, y, width, height, n.x - n.originX, n.y - n.originY, n.width, n.height);
			if (dist < nearDist)
			{
				nearDist = dist;
				near = n;
			}
			n = n._typeNext;
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
		var n:Entity = _typeFirst.get(type),
			nearDist:Float = NUMBER_MAX_VALUE,
			near:Entity = null,
			dist:Float,
			x:Float = e.x - e.originX,
			y:Float = e.y - e.originY;
		while (n != null)
		{
			dist = (x - n.x) * (x - n.x) + (y - n.y) * (y - n.y);
			if (dist < nearDist)
			{
				nearDist = dist;
				near = n;
			}
			n = n._typeNext;
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
		var n:Entity = _typeFirst.get(type),
			nearDist:Float = NUMBER_MAX_VALUE,
			near:Entity = null,
			dist:Float;
		if (useHitboxes)
		{
			while (n != null)
			{
				dist = squarePointRect(x, y, n.x - n.originX, n.y - n.originY, n.width, n.height);
				if (dist < nearDist)
				{
					nearDist = dist;
					near = n;
				}
				n = n._typeNext;
			}
			return near;
		}
		while (n != null)
		{
			dist = (x - n.x) * (x - n.x) + (y - n.y) * (y - n.y);
			if (dist < nearDist)
			{
				nearDist = dist;
				near = n;
			}
			n = n._typeNext;
		}
		return near;
	}
	
	/**
	 * How many Entities are in the World.
	 */
	public var count(getCount, null):Int;
	private function getCount():Int { return _count; }
	
	/**
	 * Returns the amount of Entities of the type are in the World.
	 * @param	type		The type (or Class type) to count.
	 * @return	How many Entities of type exist in the World.
	 */
	public function typeCount(type:String):Int
	{
		return 0; // _typeCount[type];
	}
	
	/**
	 * Returns the amount of Entities of the Class are in the World.
	 * @param	c		The Class type to count.
	 * @return	How many Entities of Class exist in the World.
	 */
	public function classCount(c:String):Int
	{
		return _classCount.get(c);
	}
	
	/**
	 * Returns the amount of Entities are on the layer in the World.
	 * @param	layer		The layer to count Entities on.
	 * @return	How many Entities are on the layer.
	 */
	public function layerCount(layer:Int):Int
	{
		return _layerCount[layer];
	}
	
	/**
	 * The first Entity in the World.
	 */
	public var first(getFirst, null):Entity;
	private function getFirst():Entity { return _updateFirst; }
	
	/**
	 * How many Entity layers the World has.
	 */
	public var layers(getLayers, null):Int;
	private function getLayers():Int { return _layerList.length; }
	
	/**
	 * The first Entity of the type.
	 * @param	type		The type to check.
	 * @return	The Entity.
	 */
	public function typeFirst(type:String):Entity
	{
		if (_updateFirst == null) return null;
		return _typeFirst.get(type);
	}
	
	/**
	 * The first Entity of the Class.
	 * @param	c		The Class type to check.
	 * @return	The Entity.
	 */
/*
	public function classFirst(c:Class):Entity
	{
		if (!_updateFirst) return null;
		var e:Entity = _updateFirst;
		while (e)
		{
			if (Std.is(e, c)) return e;
			e = e.updateNext;
		}
		return null;
	}
*/
	
	/**
	 * The first Entity on the Layer.
	 * @param	layer		The layer to check.
	 * @return	The Entity.
	 */
	public function layerFirst(layer:Int):Entity
	{
		if (_updateFirst == null) return null;
		return _renderFirst[layer];
	}
	
	/**
	 * The last Entity on the Layer.
	 * @param	layer		The layer to check.
	 * @return	The Entity.
	 */
	public function layerLast(layer:Int):Entity
	{
		if (_updateFirst == null) return null;
		return _renderLast[layer];
	}
	
	/**
	 * The Entity that will be rendered first by the World.
	 */
	public var farthest(getFarthest, null):Entity;
	private function getFarthest():Entity
	{
		if (_updateFirst == null) return null;
		return _renderLast[_layerList[_layerList.length - 1]];
	}
	
	/**
	 * The Entity that will be rendered last by the world.
	 */
	public var nearest(getNearest, null):Entity;
	private function getNearest():Entity
	{
		if (_updateFirst == null) return null;
		return _renderFirst[_layerList[0]];
	}
	
	/**
	 * The layer that will be rendered first by the World.
	 */
	public var layerFarthest(getLayerFarthest, null):Int;
	private function getLayerFarthest():Int
	{
		if (_updateFirst == null) return 0;
		return _layerList[_layerList.length - 1];
	}
	
	/**
	 * The layer that will be rendered last by the World.
	 */
	public var layerNearest(getLayerNearest, null):Int;
	private function getLayerNearest():Int
	{
		if (_updateFirst == null) return 0;
		return _layerList[0];
	}
	
	/**
	 * How many different types have been added to the World.
	 */
	public var uniqueTypes(getUniqueTypes, null):Int;
	private function getUniqueTypes():Int
	{
		var i:Int = 0;
		var type:String;
		for (type in _typeCount) i++;
		return i;
	}
	
	/**
	 * Pushes all Entities in the World of the type into the Array or Vector.
	 * @param	type		The type to check.
	 * @param	into		The Array or Vector to populate.
	 * @return	The same array, populated.
	 */
	public function getType(type:String, into:Array<Entity>)
	{
		var e:Entity = _typeFirst.get(type),
			n:Int = into.length;
		while (e != null)
		{
			into[n++] = e;
			e = e._typeNext;
		}
	}
	
	/**
	 * Pushes all Entities in the World of the Class into the Array or Vector.
	 * @param	c			The Class type to check.
	 * @param	into		The Array or Vector to populate.
	 * @return	The same array, populated.
	 */
/*
	public function getClass(c:Class, into:Array<Entity>)
	{
		var e:Entity = _updateFirst,
			n:Int = into.length;
		while (e != null)
		{
			if (Std.is(e, c)) into[n++] = e;
			e = e.updateNext;
		}
	}
*/
	
	/**
	 * Pushes all Entities in the World on the layer into the Array or Vector.
	 * @param	layer		The layer to check.
	 * @param	into		The Array or Vector to populate.
	 * @return	The same array, populated.
	 */
	public function getLayer(layer:Int, into:Array<Entity>)
	{
		var e:Entity = _renderLast[layer],
			n:Int = into.length;
		while (e != null)
		{
			into[n ++] = e;
			e = e.updatePrev;
		}
	}
	
	/**
	 * Pushes all Entities in the World into the array.
	 * @param	into		The Array or Vector to populate.
	 * @return	The same array, populated.
	 */
	public function getAll(into:Array<Entity>)
	{
		var e:Entity = _updateFirst,
			n:Int = into.length;
		while (e != null)
		{
			into[n ++] = e;
			e = e.updateNext;
		}
	}
	
	/**
	 * Updates the add/remove lists at the end of the frame.
	 */
	public function updateLists()
	{
		var e:Entity;
		
		// remove entities
		if (_remove.length > 0)
		{
			trace("remove");
			for (e in _remove)
			{
				if (e._added != true && _add.indexOf(e) >= 0)
				{
					_add.splice(_add.indexOf(e), 1);
					continue;
				}
				e._added = false;
				e.removed();
				removeUpdate(e);
				removeRender(e);
				if (e._type != "") removeType(e);
				if (e.autoClear && e.tween != null) e.clearTweens();
			}
			HXP.clear(_remove);
		}
		
		// add entities
		if (_add.length > 0)
		{
			for (e in _add)
			{
				e._added = true;
				addUpdate(e);
				addRender(e);
				if (e._type != "") addType(e);
				e.added();
			}
			HXP.clear(_add);
		}
		
		// sort the depth list
		if (_layerSort)
		{
			if (_layerList.length > 1) _layerList.sort(layerSort);// HXP.sort(_layerList, true);
			_layerSort = false;
		}
	}
	
	private function layerSort(a:Int, b:Int):Int
	{
		if (a > b)
			return 1;
		else if (a < b)
			return -1;
		
		return 0;
	}
	
	/** @private Adds Entity to the update list. */
	private function addUpdate(e:Entity)
	{
		// add to update list
		if (_updateFirst != null)
		{
			_updateFirst.updatePrev = e;
			e.updateNext = _updateFirst;
		}
		else e.updateNext = null;
		e.updatePrev = null;
		_updateFirst = e;
		_count ++;
		if (_classCount.get(e._class) != 0) _classCount.set(e._class, 0);
		_classCount.set(e._class, _classCount.get(e._class) + 1); // increment
	}
	
	/** @private Removes Entity from the update list. */
	private function removeUpdate(e:Entity)
	{
		// remove from the update list
		if (_updateFirst == e) _updateFirst = e.updateNext;
		if (e.updateNext != null) e.updateNext.updatePrev = e.updatePrev;
		if (e.updatePrev != null) e.updatePrev.updateNext = e.updateNext;
		e.updateNext = e.updatePrev = null;
		
		_count --;
		_classCount.set(e._class, _classCount.get(e._class) - 1); // decrement
	}
	
	/** @private Adds Entity to the render list. */
	public function addRender(e:Entity)
	{
		var f:Entity = _renderFirst[e._layer];
		if (f != null)
		{
			// Append entity to existing layer.
			e.renderNext = f;
			f.renderPrev = e;
			_layerCount[e._layer] ++;
		}
		else
		{
			// Create new layer with entity.
			_renderLast[e._layer] = e;
			_layerList[_layerList.length] = e._layer;
			_layerSort = true;
			e.renderNext = null;
			_layerCount[e._layer] = 1;
		}
		_renderFirst[e._layer] = e;
		e.renderPrev = null;
	}
	
	/** @private Removes Entity from the render list. */
	public function removeRender(e:Entity)
	{
		if (e.renderNext != null) e.renderNext.renderPrev = e.renderPrev;
		else _renderLast[e._layer] = e.renderPrev;
		if (e.renderPrev != null) e.renderPrev.renderNext = e.renderNext;
		else
		{
			// Remove this entity from the layer.
			_renderFirst[e._layer] = e.renderNext;
			if (e.renderNext == null)
			{
				// Remove the layer from the layer list if this was the last entity.
				if (_layerList.length > 1)
				{
					_layerList[_layerList.indexOf(e._layer)] = _layerList[_layerList.length - 1];
					_layerSort = true;
				}
				_layerList.pop();
			}
		}
		_layerCount[e._layer] --;
		e.renderNext = e.renderPrev = null;
	}
	
	/** @private Adds Entity to the type list. */
	public function addType(e:Entity)
	{
		// add to type list
		if (_typeFirst.get(e._type) != null)
		{
			_typeFirst.get(e._type)._typePrev = e;
			e._typeNext = _typeFirst.get(e._type);
//			_typeCount[e._type]++;
		}
		else
		{
			e._typeNext = null;
//			_typeCount[e._type] = 1;
		}
		e._typePrev = null;
		_typeFirst.set(e._type, e);
	}
	
	/** @private Removes Entity from the type list. */
	public function removeType(e:Entity)
	{
		// remove from the type list
		if (_typeFirst.get(e._type) == e) _typeFirst.set(e._type, e._typeNext);
		if (e._typeNext != null) e._typeNext._typePrev = e._typePrev;
		if (e._typePrev != null) e._typePrev._typeNext = e._typeNext;
		e._typeNext = e._typePrev = null;
//		_typeCount[e._type] --;
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
	
	// Update information.
	private var _updateFirst:Entity;
	private var _count:Int;
	
	// Render information.
	private var _renderFirst:Array<Entity>;
	private var _renderLast:Array<Entity>;
	private var _layerList:Array<Int>;
	private var _layerCount:Array<Int>;
	private var _layerSort:Bool;
	private var _tempArray:Array<Entity>;
	
	private var _classCount:Hash<Int>;
	public var _typeFirst:Hash<Entity>;
	private var _typeCount:Array<Int>;
	private var _recycled:Hash<Entity>;
}