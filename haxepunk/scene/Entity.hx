package haxepunk.scene;

import lime.utils.Matrix3D;
import lime.utils.Vector3D;
import haxepunk.graphics.Graphic;

class Entity
{

	public var position:Vector3D;
	public var angle:Float = 0;

	public function new()
	{
		position = new Vector3D();
		modelViewMatrix = new Matrix3D();
	}

	public function draw(projectionMatrix:Matrix3D)
	{
		modelViewMatrix.identity();
		modelViewMatrix.appendTranslation(position.x, position.y, position.z);
		modelViewMatrix.appendRotation(angle, Vector3D.X_AXIS);
		modelViewMatrix.appendRotation(angle++, Vector3D.Y_AXIS);

		if (graphic != null) graphic.draw(projectionMatrix, modelViewMatrix);
	}

	private var graphic:Graphic;
	private var modelViewMatrix:Matrix3D;

}
