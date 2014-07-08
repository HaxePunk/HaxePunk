package haxepunk.scene;

import haxepunk.HXP;
import lime.graphics.GL;
import haxepunk.graphics.Color;
import haxepunk.math.Vector3D;
import haxepunk.math.Matrix3D;
import haxepunk.math.Math;

class Camera extends SceneNode
{

	public var transform(default, null):Matrix3D;
	public var up:Vector3D;
	public var clearColor:Color;

	public function new()
	{
		super();
		transform = new Matrix3D();
		up = new Vector3D();
		clearColor = new Color(0.117, 0.117, 0.117, 1.0);

		// make2D(HXP.window.width, HXP.window.height);
		make2D(800, 600);
	}

	public function make2D(width:Float, height:Float):Void
	{
		_projection = Matrix3D.createOrtho(0, width, height, 0, 500, -500);
	}

	public function make3D(fov:Float, width:Float, height:Float):Void
	{
		_projection = Matrix3D.createPerspective(fov * Math.RAD, width / height, -100, 100);
	}

	public function lookAt(target:Vector3D):Void
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
#if !neko
		GL.viewport(0, 0, HXP.window.width, HXP.window.height);
#end
		GL.disable(GL.DEPTH_TEST);
		GL.depthFunc(GL.LEQUAL);

		// TODO: move this to texture?
		GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
		GL.enable(GL.BLEND);
	}

	private var _projection:Matrix3D;

}
