package haxepunk.scene;

import lime.utils.Matrix3D;
import lime.utils.Vector3D;
import haxepunk.graphics.Graphic;

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

	public function new(x:Float = 0, y:Float = 0, z:Float = 0)
	{
		position = new Vector3D(x, y, z);
		modelViewMatrix = new Matrix3D();
	}

	public function draw(projectionMatrix:Matrix3D)
	{
		modelViewMatrix.identity();
		modelViewMatrix.appendTranslation(position.x, position.y, position.z);

		if (graphic != null) graphic.draw(projectionMatrix, modelViewMatrix);
	}

	public function update()
	{

	}

	private var graphic:Graphic;
	private var modelViewMatrix:Matrix3D;

}
