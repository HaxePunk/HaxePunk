package com.haxepunk;
import flash.geom.Point;

class State extends Tweener
{
	
	public var visible:Bool;
	public var camera:Point;
	
	public function new()
	{
		super();
		camera = new Point();
		visible = true;
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
	
	override public function update()
	{
		var e:Entity = _updateFirst;
		while (e != null)
		{
			if (e.active)
			{
				e.update();
			}
			if (e._graphic != null && e._graphic.active) e._graphic.update();
			e = e._updateNext;
		}
	}
	
	public function render()
	{
		var e:Entity;
		var i:Int = _layerList.length;
		while (i-- > 0)
		{
			e = _renderLast[_layerList[i]];
			while (e != null)
			{
				if (e.visible) e.render();
				e = e._renderPrev;
			}
		}
	}
	
	/**
	 * How many Entities are in the World.
	 */
	public var count(getCount, null):Int;
	private function getCount():Int { return _count; }
	
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
	
	public function updateLists()
	{
		var e:Entity;
		
		/*
		if (_remove.length != 0)
		{
			for (e in _remove)
			{
				if (e._added != true && _add.indexOff(e) >= 0)
				{
					_add.splice(_add.indexOf(e), 1);
					continue;
				}
				e._added = false;
				e.removed();
				removeUpdate(e);
				removeRender(e);
				if (e._type) removeType(e);
				if (e.autoClear && e._tween) e.clearTweens();
			}
			_remove.length = 0;
		}
		
		if (_add.length != 0)
		{
			for (e in _add)
			{
				e._added = true;
				addUpdate(e);
				addRender(e);
				if (e._type) addType(e);
				e.added();
			}
			_add.length = 0;
		}
		
		if (_layerSort)
		{
			if (_layerList.length > 1) FP.sort(_layerList, true);
			_layerSort = false;
		}
		*/
	}
	
	private var _add:Array<Entity>;
	private var _remove:Array<Entity>;
	
	private var _updateFirst:Entity;
	private var _count:Int;
	
	private var _renderFirst:Array<Entity>;
	private var _renderLast:Array<Entity>;
	private var _layerList:Array<Int>;
	
}