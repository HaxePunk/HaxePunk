package haxepunk.scene;

import haxepunk.HXP;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GLRenderbuffer;
import haxepunk.math.Vector3D;
import haxepunk.math.Matrix3D;

class Camera
{

	public var transform:Matrix3D;
	public var position:Vector3D;

	public function new()
	{
		// var width = 512, height = 512;
		// _framebuffer = GL.createFramebuffer();
		// GL.bindFramebuffer(GL.FRAMEBUFFER, _framebuffer);

		// _renderbuffer = GL.createRenderbuffer();
		// GL.bindRenderbuffer(GL.RENDERBUFFER, _renderbuffer);
		// GL.renderbufferStorage(GL.RENDERBUFFER, GL.RGBA, width, height);
		// GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.RENDERBUFFER, _renderbuffer);

		// var texture = GL.createTexture();
		// GL.bindTexture(GL.TEXTURE_2D, texture);
		// GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		// GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA,  width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, null);
		// GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture, 0);
	}

	public function make2D()
	{
		transform = Matrix3D.createOrtho(0, HXP.window.width, HXP.window.height, 0, 500, -500);
	}

	public function make3D()
	{
		transform = Matrix3D.createOrtho(-5, 5, -5, 5, 500, -500);
	}

	public function setup()
	{
		make2D();
		// GL.bindFramebuffer(GL.FRAMEBUFFER, null);
		// GL.bindRenderbuffer(GL.RENDERBUFFER, null);
#if !neko
		GL.viewport(0, 0, HXP.window.width, HXP.window.height);
#end
		GL.disable(GL.DEPTH_TEST);
		GL.depthFunc(GL.EQUAL);

		// TODO: move this to texture?
		GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
		GL.enable(GL.BLEND);

		// TODO: set option for clear color per camera?
		GL.clearColor(0.117, 0.117, 0.117, 1.0);
		GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
	}

	public function lookAt(target:Vector3D):Void
	{

	}

	private var _framebuffer:GLFramebuffer;
	private var _renderbuffer:GLRenderbuffer;

}
