package haxepunk.gui;

import haxepunk.scene.Camera;
import haxepunk.scene.Scene;

class ControlGroup extends Control
{

	public function new(x:Float=0, y:Float=0, width:Float=1, height:Float=1)
	{
		super(x, y, width, height);
		_children = new Array<Control>();
	}

	public function add(child:Control):Void
	{
		child.scene = scene;
		_children.push(child);
	}

	public function remove(child:Control):Void
	{
		child.scene = null;
		_children.remove(child);
	}

	override public function draw(camera:Camera):Void
	{
		super.draw(camera);
		for (i in 0..._children.length)
		{
			var child = _children[i];
			child.position += position;
			child.draw(camera);
			child.position -= position;
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		for (i in 0..._children.length)
		{
			var child = _children[i];
			child.position += position;
			child.update(elapsed);
			child.position -= position;
		}
	}

	private var _children:Array<Control>;

}
