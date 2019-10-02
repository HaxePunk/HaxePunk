package haxepunk.graphics.hardware;

import kha.Canvas;
import kha.Image;
import kha.graphics4.BlendingFactor;
import kha.graphics4.BlendingOperation;

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

	static var _ortho:Float32Array;

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
		#if 0
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
		#end
	}

	// for render to texture
	var fb:Image;
	var backFb:Image;

	// var buffer:RenderBuffer;
	var defaultFramebuffer:Canvas;

	public function new()
	{
#if 0
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
#end
	}

	@:access(haxepunk.graphics.hardware.DrawCommand)
	public function render(drawCommand:DrawCommand):Void
	{
		#if 0
		GLUtils.checkForErrors();

		var x = this.x,
			y = this.y,
			width = this.width,
			height = this.height;

		if (drawCommand != null && drawCommand.triangleCount > 0)
		{
			if (_tracking)
			{
				triangleCount += drawCommand.triangleCount;
				++drawCallCount;
				if (drawCallLimit > -1 && drawCallCount > drawCallLimit) return;
			}

			var clipRect = drawCommand.clipRect;
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

				GLUtils.checkForErrors();

				var texture:Texture = drawCommand.texture;
				if (texture != null) GLUtils.bindTexture(texture, drawCommand.smooth);
				GLUtils.checkForErrors();

				shader.prepare(drawCommand, buffer);

				GLUtils.checkForErrors();

				setBlendMode(drawCommand.blend);

				if (clipRect != null)
				{
					x += Std.int(Math.max(clipRect.x, 0));
					y += Std.int(Math.max(clipRect.y, 0));
				}

				GL.scissor(x, HXP.windowHeight - y - height, width, height);
				GL.enable(GL.SCISSOR_TEST);

				GL.drawArrays(GL.TRIANGLES, 0, triangles * 3);

				GLUtils.checkForErrors();

				GL.disable(GL.SCISSOR_TEST);

				GL.bindBuffer(GL.ARRAY_BUFFER, null);
				shader.unbind();

				GLUtils.checkForErrors();
			}
		}
		#end
	}

	public function startScene(scene:Scene) : Canvas
	{
		// _tracking = scene.trackDrawCalls;
		
		x = Std.int(HXP.screen.x + Math.max(scene.x, 0));
		y = Std.int(HXP.screen.y + Math.max(scene.y, 0));
		width = Std.int(scene.width);
		height = Std.int(scene.height);

		var postProcess = scene.shaders;
		return postProcess != null && postProcess.length > 0 ? fb : defaultFramebuffer;
	}

	public function flushScene(scene:Scene)
	{
		var postProcess:Array<SceneShader> = scene.shaders;
		if (postProcess != null)
		{
			var g2 = defaultFramebuffer.g2;
			g2.begin();
			g2.drawImage(fb, 0, 0);
			g2.end();
			
			// TODO : apply scene shaders
			
			/*
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
			*/
		}
	}

	public function startFrame(framebuffer:Canvas)
	{
		// triangleCount = 0;
		// drawCallCount = 0;
		// bindDefaultFramebuffer();
		defaultFramebuffer = framebuffer;
	}
	public function endFrame() {}

	inline function init()
	{
		/*
		if (buffer == null)
		{
			buffer = new RenderBuffer();
		}
		*/
		if (fb == null)
		{
			fb = Image.createRenderTarget(width, height);
			backFb = Image.createRenderTarget(width, height);
		}
	}

	inline function bindDefaultFramebuffer()
	{
		// GL.bindFramebuffer(GL.FRAMEBUFFER, defaultFramebuffer);
	}

	inline function destroy() {}

	var x:Int = 0;
	var y:Int = 0;
	var width:Int = 0;
	var height:Int = 0;
}
