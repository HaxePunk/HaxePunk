package haxepunk.graphics.hardware;

import haxe.PosInfos;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.gl.GL;
import flash.gl.GLFramebuffer;
import haxepunk.HXP;
import haxepunk.graphics.shader.SceneShader;
import haxepunk.utils.BlendMode;

/**
 * OpenGL-based renderer. Based on work by @Yanrishatum and @Beeblerox.
 * @since	2.6.0
 */
@:dox(hide)
@:access(haxepunk.Scene)
@:access(haxepunk.Engine)
class HardwareRenderer
{
	public static var drawCallLimit:Int = -1;

	public static inline var UNIFORM_MATRIX:String = "uMatrix";

	static var triangleCount:Int = 0;
	static var drawCallCount:Int = 0;
	static var _tracking:Bool = true;

	static inline function checkForGLErrors(?pos:PosInfos)
	{
		#if gl_debug
		var error = GL.getError();
		if (error != GL.NO_ERROR)
			throw "GL Error found at " + pos.fileName + ":" + pos.lineNumber + ": " + error;
		#elseif debug
		var error = GL.getError();
		if (error != GL.NO_ERROR)
			trace("GL Error found at " + pos.fileName + ":" + pos.lineNumber + ": " + error);
		#end
	}

	static inline function ortho(x0:Float, x1:Float, y0:Float, y1:Float, zNear:Float, zFar:Float)
	{
		var sx = 1.0 / (x1 - x0);
		var sy = 1.0 / (y1 - y0);
		var sz = 1.0 / (zFar - zNear);
		_ortho[0] = 2.0 * sx;
		_ortho[5] = 2.0 * sy;
		_ortho[10] = -2.0 * sz;
		_ortho[12] = -(x0 + x1) * sx;
		_ortho[13] = -(y0 + y1) * sy;
		_ortho[14] = -(zNear + zFar) * sz;
	}

	static inline function setBlendMode(blend:BlendMode)
	{
		switch (blend)
		{
			case BlendMode.Add:
				GL.blendEquation(GL.FUNC_ADD);
				GL.blendFuncSeparate(GL.ONE, GL.ONE, GL.ZERO, GL.ONE);
			case BlendMode.Multiply:
				GL.blendEquation(GL.FUNC_ADD);
				GL.blendFuncSeparate(GL.DST_COLOR, GL.ONE_MINUS_SRC_ALPHA, GL.ZERO, GL.ONE);
			case BlendMode.Screen:
				GL.blendEquation(GL.FUNC_ADD);
				GL.blendFuncSeparate(GL.ONE, GL.ONE_MINUS_SRC_COLOR, GL.ZERO, GL.ONE);
			case BlendMode.Subtract:
				GL.blendEquationSeparate(GL.FUNC_REVERSE_SUBTRACT, GL.FUNC_ADD);
				GL.blendFuncSeparate(GL.ONE, GL.ONE, GL.ZERO, GL.ONE);
			case BlendMode.Alpha:
				GL.blendEquation(GL.FUNC_ADD);
				GL.blendFunc(GL.ONE, GL.ONE_MINUS_SRC_ALPHA);
		}
	}

	static var _point:Point = new Point();
	static var _ortho:Float32Array;

	// for render to texture
	var fb:FrameBuffer;
	var backFb:FrameBuffer;

	var buffer:RenderBuffer;
	var defaultFramebuffer:GLFramebuffer = null;

	public function new()
	{
		#if ios
		defaultFramebuffer = new GLFramebuffer(GL.version, GL.getParameter(GL.FRAMEBUFFER_BINDING));
		#end
		if (_ortho == null)
		{
			_ortho = new Float32Array(16);
			for (i in 0 ... 15)
			{
				_ortho[i] = 0;
			}
			_ortho[15] = 1;
		}
	}

	@:access(haxepunk.graphics.hardware.DrawCommand)
	public function render(drawCommand:DrawCommand, scene:Scene, rect:Rectangle):Void
	{
		#if (gl_debug || debug) checkForGLErrors(); #end

		if (drawCommand != null && drawCommand.triangleCount > 0)
		{
			if (_tracking)
			{
				triangleCount += drawCommand.triangleCount;
				++drawCallCount;
				if (drawCallLimit > -1 && drawCallCount > drawCallLimit) return;
			}

			var x:Int = Std.int(HXP.screen.x),
				y:Int = Std.int(HXP.screen.y);
			var width:Int = HXP.screen.width,
				height:Int = HXP.screen.height,
				clipRect = drawCommand.clipRect;
			if (clipRect != null)
			{
				width -= Std.int(clipRect.x);
				height -= Std.int(clipRect.y);
				width = Std.int(Math.min(width, clipRect.width));
				height = Std.int(Math.min(height, clipRect.height));
			}

			if (width > 0 && height > 0)
			{
				var shader = drawCommand.shader;
				shader.bind();

				// expand arrays if necessary
				var triangles:Int = drawCommand.triangleCount;
				var floatsPerTriangle:Int = shader.floatsPerVertex * 3;
				buffer.ensureSize(triangles, floatsPerTriangle);

				ortho(-x, -x + HXP.windowWidth, -y + HXP.windowHeight, -y, 1000, -1000);
				#if (lime >= "4.0.0")
				GL.uniformMatrix4fv(shader.uniformIndex(UNIFORM_MATRIX), 1, false, _ortho);
				#else
				GL.uniformMatrix4fv(shader.uniformIndex(UNIFORM_MATRIX), false, _ortho);
				#end

				#if (gl_debug || debug) checkForGLErrors(); #end

				var texture:Texture = drawCommand.texture;
				if (texture.bitmap != null) GLUtils.bindTexture(texture, drawCommand.smooth);

				#if (gl_debug || debug) checkForGLErrors(); #end

				GL.bindBuffer(GL.ARRAY_BUFFER, buffer.glBuffer);
				shader.prepare(drawCommand, buffer);

				#if (gl_debug || debug) checkForGLErrors(); #end

				setBlendMode(drawCommand.blend);

				if (clipRect != null)
				{
					x += Std.int(Math.max(clipRect.x, 0));
					y += Std.int(Math.max(clipRect.y, 0));
				}

				GL.scissor(x, HXP.windowHeight - y - height, width, height);
				GL.enable(GL.SCISSOR_TEST);

				GL.drawArrays(GL.TRIANGLES, 0, triangles * 3);

				#if (gl_debug || debug) checkForGLErrors(); #end

				GL.disable(GL.SCISSOR_TEST);

				GL.bindBuffer(GL.ARRAY_BUFFER, null);
				shader.unbind();

				#if (gl_debug || debug) checkForGLErrors(); #end
			}
		}
	}

	public function startScene(scene:Scene)
	{
		_tracking = scene != HXP.engine.console;

		if (buffer == null || GLUtils.invalid(buffer.glBuffer))
		{
			destroy();
			init();
		}

		var postProcess:Array<SceneShader> = scene.shaders;
		if (postProcess != null && postProcess.length > 0)
		{
			fb.bindFrameBuffer();
		}
		else
		{
			bindDefaultFramebuffer();
		}
	}

	public function flushScene(scene:Scene)
	{
		var postProcess:Array<SceneShader> = scene.shaders;
		if (postProcess != null)
		{
			for (i in 0 ... postProcess.length)
			{
				var last = i == postProcess.length - 1;
				var shader = postProcess[i];
				var renderTexture = fb.texture;

				if (last)
				{
					bindDefaultFramebuffer();
				}
				else
				{
					// render to texture
					var oldFb = fb;
					fb = backFb;
					backFb = oldFb;
					fb.bindFrameBuffer();
				}
				shader.bind();

				GL.activeTexture(GL.TEXTURE0);
				GL.bindTexture(GL.TEXTURE_2D, renderTexture);

				GL.blendEquation(GL.FUNC_ADD);
				GL.blendFunc(GL.ONE, GL.ONE_MINUS_SRC_ALPHA);
				GL.drawArrays(GL.TRIANGLES, 0, 6);

				GL.bindBuffer(GL.ARRAY_BUFFER, null);
				GL.bindTexture(GL.TEXTURE_2D, null);

				shader.unbind();

				GL.bindFramebuffer(GL.FRAMEBUFFER, null);
			}
		}
	}

	public function startFrame()
	{
		triangleCount = 0;
		drawCallCount = 0;
		bindDefaultFramebuffer();
	}
	public function endFrame() {}

	inline function init()
	{
		if (buffer == null)
		{
			buffer = new RenderBuffer();
		}
		if (fb == null)
		{
			fb = new FrameBuffer();
			backFb = new FrameBuffer();
		}
	}

	inline function bindDefaultFramebuffer()
	{
		GL.bindFramebuffer(GL.FRAMEBUFFER, defaultFramebuffer);
	}

	inline function destroy() {}
}
