package haxepunk.scene;

import haxepunk.math.Vector3;

class SceneNode
{

	public var position:Vector3;

	@:allow(haxepunk.scene.Scene)
	public var scene(default, null):Scene;

	public var x(get, set):Float;
	private inline function get_x():Float { return position.x; }
	private inline function set_x(value:Float) { return position.x = value; }

	public var y(get, set):Float;
	private inline function get_y():Float { return position.y; }
	private inline function set_y(value:Float) { return position.y = value; }

	public var z(get, set):Float;
	private inline function get_z():Float { return position.z; }
	private inline function set_z(value:Float) { return position.z = value; }

	public function new(x:Float = 0, y:Float = 0, z:Float = 0)
	{
		position = new Vector3(x, y, z);
	}

}
