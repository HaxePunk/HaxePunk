package haxepunk.scene;

import haxepunk.HXP;
import haxepunk.graphics.Color;
import haxepunk.math.Vector3;
import haxepunk.math.Matrix4;
import haxepunk.math.Math;

class Camera extends SceneNode
{

	public var transform(default, null):Matrix4;
	public var up:Vector3;
	public var clearColor:Color;

	public function new()
	{
		super();
		transform = new Matrix4();
		up = new Vector3();
		clearColor = new Color(0.117, 0.117, 0.117, 1.0);

		// make2D(HXP.window.width, HXP.window.height);
		make2D(800, 600);
	}

	public function make2D(width:Float, height:Float):Void
	{
		_projection = Matrix4.createOrtho(0, width, height, 0, 500, -500);
	}

	public function make3D(fov:Float, width:Float, height:Float):Void
	{
		_projection = Matrix4.createPerspective(fov * Math.RAD, width / height, -100, 100);
	}

	public function lookAt(target:Vector3):Void
	{
		transform.lookAt(position, target, up);
	}

	public function update():Void
	{
		transform.identity();
		transform.translate(-position.x, -position.y, -position.z);
		transform.multiply(_projection);
	}

	public function beginDraw()
	{
		HXP.renderer.setViewport(0, 0, HXP.window.width, HXP.window.height);
		HXP.renderer.setDepthTest(false);
	}

	private var _projection:Matrix4;

}
