package haxepunk.gui;

import haxepunk.scene.Entity;
import haxepunk.inputs.Mouse;

class Control extends Entity
{
	public static var defaultSkin:String = "graphics/gui/defaultSkin.png";

	public var width:Float;
	public var height:Float;

	public function new(x:Float=0, y:Float=0, width:Float=1, height:Float=1)
	{
		super(x, y);
		this.width = width;
		this.height = height;
	}

	override public function update(elapsed:Float):Void
	{
		if (scene != null && collidePoint(scene.camera.x + Mouse.x, scene.camera.y + Mouse.y))
		{
			// trace("hover", Type.getClass(this));
		}
		super.update(elapsed);
	}

}
