package haxepunk.scene;

import lime.utils.Matrix3D;
import lime.utils.Vector3D;
import haxepunk.graphics.Graphic;

class Entity
{

	public var x:Float = 0;
	public var y:Float = 0;
	public var z:Float = 0;

	public var angle:Float = 0; // TODO: remove this!!

	public function new()
	{
		modelViewMatrix = new Matrix3D();
	}

	public function draw(projectionMatrix:Matrix3D)
	{
		modelViewMatrix.identity();
		modelViewMatrix.appendTranslation(x, y, z);
		modelViewMatrix.appendRotation(angle, Vector3D.X_AXIS);
		modelViewMatrix.appendRotation(angle++, Vector3D.Y_AXIS);

		if (graphic != null) graphic.draw(projectionMatrix, modelViewMatrix);
	}

	private var graphic:Graphic;
	private var modelViewMatrix:Matrix3D;

}
