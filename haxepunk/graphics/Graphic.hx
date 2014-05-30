package haxepunk.graphics;

import lime.utils.Matrix3D;

interface Graphic
{
	public function draw(projectionMatrix:Matrix3D, modelViewMatrix:Matrix3D):Void;
}
