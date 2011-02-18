package com.haxepunk;

import flash.display.BitmapData;

class Entity extends Tweener
{
	public var visible:Bool;
	public var collidable:Bool;
	
	public var x:Float;
	public var y:Float;
	
	public var width:Int;
	public var height:Int;
	
	public var originX:Int;
	public var originY:Int;
	
	public var renderTarget:BitmapData;
	
	public function new()
	{
		super();
		
		visible = true;
		collidable = true;
		x = y = 0;
	}
	
	public function added()
	{
		
	}
	
	public function removed()
	{
		
	}
	
	override public function update()
	{
		
	}
	
	public function render()
	{
		if (_graphic != null && _graphic.visible)
		{
			/*
			if (_graphic.relative)
			{
				_point.x = x;
				_point.y = y;
			}
			else _point.x = _point.y = 0;
			_camera.x = Flume.camera.x;
			_camera.y = Flume.camera.y;
			_graphic.render(renderTarget ? renderTarget : Flume.buffer, _point, _camera);
			*/
		}
	}
	
	public function collide(type:String, x:Float, y:Float):Entity
	{
		return null;
	}
	
	public function collideTypes(types:Array<String>, x:Float, y:Float):Entity
	{
		return null;
	}
	
	public function collideWith(e:Entity, x:Float, y:Float):Entity
	{
		return null;
	}
	
	public function collideRect(x:Float, y:Float, rX:Float, rY:Float, rW:Float, rH:Float):Bool
	{
		return false;
	}
	
	public function collidePoint(x:Float, y:Float, pX:Float, pY:Float):Bool
	{
		return false;
	}
	
	public var _graphic:Graphic;
	
	public var _updatePrev:Entity;
	public var _updateNext:Entity;
	public var _renderPrev:Entity;
	public var _renderNext:Entity;
}