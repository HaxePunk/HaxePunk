package haxepunk.graphics.hardware;

import haxepunk.graphics.hardware.opengl.GL;
import haxepunk.graphics.hardware.opengl.GLFramebuffer;
import haxepunk.graphics.hardware.opengl.GLUtils;
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

	static inline function ortho(x0:Float, x1:Float, y0:Float, y1:Float)
	{
		var sx = 1.0 / (x1 - x0);
		var sy = 1.0 / (y1 - y0);
		_ortho[0] = 2.0 * sx;
		_ortho[5] = 2.0 * sy;
		_ortho[12] = -(x0 + x1) * sx;
		_ortho[13] = -(y0 + y1) * sy;
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

	static var _ortho:Float32Array;

	// for render to texture
	var fb:FrameBuffer;
	var backFb:FrameBuffer;

	var buffer:RenderBuffer;
	var defaultFramebuffer:GLFramebuffer = null;

	var screenWidth:Int;
	var screenHeight:Int;
	var screenScaleX:Float;
	var screenScaleY:Float;

	public function new()
	{
		#if (ios && (lime && lime < 3))
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
	public function render(drawCommand:DrawCommand):Void
	{
		GLUtils.checkForErrors();

		var x = this.x,
			y = this.y,
			width = this.width,
			height = this.height,
			screen = HXP.screen;

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

				GL.scissor(x, screenHeight - y - height, width, height);
				GL.enable(GL.SCISSOR_TEST);

				GL.drawArrays(GL.TRIANGLES, 0, triangles * 3);

				GLUtils.checkForErrors();

				GL.disable(GL.SCISSOR_TEST);

				GL.bindBuffer(GL.ARRAY_BUFFER, null);
				shader.unbind();

				GLUtils.checkForErrors();
			}
		}
	}

	@:access(haxepunk.Screen)
	public function startScene(scene:Scene)
	{
		GLUtils.checkForErrors();
		_tracking = scene.trackDrawCalls;

		if (buffer == null || GLUtils.invalid(buffer.glBuffer))
		{
			destroy();
			init();
			GLUtils.checkForErrors();
		}

		var screen = HXP.screen;

		screenWidth = screen.width;
		screenHeight = screen.height;
		screenScaleX = screen.scaleX;
		screenScaleY = screen.scaleY;

		var postProcess:Array<SceneShader> = scene.shaders;
		var firstShader:SceneShader = null;
		if (postProcess != null) for (p in postProcess)
		{
			if (p.active)
			{
				firstShader = p;
				break;
			}
		}
		if (firstShader != null)
		{
			fb.bindFrameBuffer();
			var p = firstShader;
			if (p.width != null || p.height != null)
			{
				var w = p.textureWidth,
					h = p.textureHeight;
				screen.scaleX *= w / screenWidth;
				screen.scaleY *= h / screenHeight;
				screen.width = w;
				screen.height = h;
			}
		}
		else
		{
			bindDefaultFramebuffer();
		}

		x = Std.int(screen.x + Math.max(scene.x, 0));
		y = Std.int(screen.y + Math.max(scene.y, 0));
		width = scene.width;
		height = scene.height;

		ortho(-x, screenWidth - x, screenHeight - y, -y);
	}

	@:access(haxepunk.Screen)
	public function flushScene(scene:Scene)
	{
		var screen = HXP.screen;
		screen.width = screenWidth;
		screen.height = screenHeight;
		screen.scaleX = screenScaleX;
		screen.scaleY = screenScaleY;

		var postProcess:Array<SceneShader> = scene.shaders;
		var hasPostProcess = false;
		if (postProcess != null) for (p in postProcess)
		{
			if (p.active)
			{
				hasPostProcess = true;
				break;
			}
		}
		if (hasPostProcess)
		{
			var l = postProcess.length;
			while (!postProcess[l - 1].active) --l;
			for (i in 0 ... l)
			{
				var last = i == l - 1;
				var shader = postProcess[i];
				if (!shader.active) continue;
				var renderTexture = fb.texture;

				var scaleX:Float, scaleY:Float;
				if (last)
				{
					// scale up to screen size
					scaleX = screenWidth / shader.textureWidth;
					scaleY = screenHeight / shader.textureHeight;
					bindDefaultFramebuffer();
				}
				else
				{
					// render to texture
					var next = postProcess[i + 1];
					scaleX = next.textureWidth / shader.textureWidth;
					scaleY = next.textureHeight / shader.textureHeight;
					var oldFb = fb;
					fb = backFb;
					backFb = oldFb;
					fb.bindFrameBuffer();
					GLUtils.checkForErrors();
				}
				shader.setScale(shader.textureWidth, shader.textureHeight, scaleX, scaleY);
				shader.bind();
				GLUtils.checkForErrors();

				GL.activeTexture(GL.TEXTURE0);
				GL.bindTexture(GL.TEXTURE_2D, renderTexture);

				if (shader.smooth)
				{
					GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
					GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
				}
				else
				{
					GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
					GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
				}

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

	var x:Int = 0;
	var y:Int = 0;
	var width:Int = 0;
	var height:Int = 0;
}
