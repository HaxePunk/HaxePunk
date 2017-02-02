package haxepunk.graphics.atlas;

#if hardware_render
import flash.geom.Rectangle;
import flash.display.BlendMode;
import flash.geom.Point;
import flash.gl.GL;
import flash.gl.GLBuffer;
#if lime
import lime.utils.Float32Array;
#if !flash
import openfl._internal.renderer.opengl.GLRenderer;
#end
#elseif nme
import nme.utils.Float32Array;
#end
import haxepunk.HXP;

@:dox(hide)
private class TextureShader extends BaseShader
{
	public static inline var VERTEX_SHADER =
"// HaxePunk HardwareRenderer texture vertex shader
#ifdef GL_ES
precision mediump float;
#endif

attribute vec4 aPosition;
attribute vec4 aColor;
attribute vec2 aTexCoord;
varying vec2 vTexCoord;
varying vec4 vColor;
uniform mat4 uMatrix;

void main(void) {
	vColor = aColor;
	vTexCoord = aTexCoord;
	gl_Position = uMatrix * aPosition;
}";

	public static inline var FRAGMENT_SHADER =
"// HaxePunk HardwareRenderer texture fragment shader
#ifdef GL_ES
precision mediump float;
#endif

varying vec4 vColor;
varying vec2 vTexCoord;
uniform sampler2D uImage0;

void main(void) {
	vec4 color = texture2D(uImage0, vTexCoord);
	if (color.a == 0.0) {
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		gl_FragColor = color * vec4(vColor.rgb * vColor.a, vColor.a);
	}
}";

	public function new()
	{
		super(VERTEX_SHADER, FRAGMENT_SHADER);
		bufferChunkSize = 8;
	}

	override public function bind()
	{
		super.bind();
		GL.enableVertexAttribArray(attributeIndex("aPosition"));
		GL.enableVertexAttribArray(attributeIndex("aTexCoord"));
		GL.enableVertexAttribArray(attributeIndex("aColor"));
	}

	override public function unbind()
	{
		super.unbind();
		GL.disableVertexAttribArray(attributeIndex("aPosition"));
		GL.disableVertexAttribArray(attributeIndex("aTexCoord"));
		GL.disableVertexAttribArray(attributeIndex("aColor"));
	}
}

@:dox(hide)
private class ColorShader extends BaseShader
{
	public static inline var VERTEX_SHADER =
"// HaxePunk HardwareRenderer color vertex shader
#ifdef GL_ES
precision mediump float;
#endif

attribute vec4 aPosition;
attribute vec4 aColor;
varying vec4 vColor;
uniform mat4 uMatrix;

void main(void) {
	vColor = aColor;
	gl_Position = uMatrix * aPosition;
}";

	public static inline var FRAGMENT_SHADER =
"// HaxePunk HardwareRenderer color fragment shader
#ifdef GL_ES
precision mediump float;
#endif

varying vec4 vColor;

void main(void) {
	gl_FragColor = vColor;
}";

	public function new()
	{
		super(VERTEX_SHADER, FRAGMENT_SHADER);
		bufferChunkSize = 6;
	}

	override public function bind()
	{
		super.bind();
		GL.enableVertexAttribArray(attributeIndex("aPosition"));
		GL.enableVertexAttribArray(attributeIndex("aColor"));
	}

	override public function unbind()
	{
		super.unbind();
		GL.disableVertexAttribArray(attributeIndex("aPosition"));
		GL.disableVertexAttribArray(attributeIndex("aColor"));
	}
}

/**
 * OpenGL-based renderer. Based on work by @Yanrishatum and @Beeblerox.
 * @since	2.6.0
 */
#if lime
@:access(openfl.display.Stage)
@:access(openfl._internal.renderer.opengl.GLRenderer)
#end
@:access(haxepunk.Scene)
@:dox(hide)
class HardwareRenderer
{
	static inline var FLOAT32_BYTES:Int = #if lime Float32Array.BYTES_PER_ELEMENT #else Float32Array.SBYTES_PER_ELEMENT #end;

	static inline function resize(length:Int, minChunks:Int, chunkSize:Int)
	{
		return Std.int(Math.max(
			Std.int(length * 2 / chunkSize),
			minChunks
		) * chunkSize);
	}

	static var _vertices:Array<Float> = [
		-1.0, -1.0, 0, 0,
		1.0, -1.0, 1, 0,
		-1.0,  1.0, 0, 1,
		1.0, -1.0, 1, 0,
		1.0,  1.0, 1, 1,
		-1.0,  1.0, 0, 1
	];

	static inline function checkForGLErrors()
	{
		var error = GL.getError();
		if (error != GL.NO_ERROR)
			trace("GL Error: " + error);
	}

	static inline function ortho(x0:Float, x1:Float, y0:Float, y1:Float, zNear:Float, zFar:Float):Float32Array
	{
		var sx = 1.0 / (x1 - x0);
		var sy = 1.0 / (y1 - y0);
		var sz = 1.0 / (zFar - zNear);

		var _data = _f32;
		_data[0] = 2.0 * sx;
		_data[1] = 0;
		_data[2] = 0;
		_data[3] = 0;
		_data[4] = 0;
		_data[5] = 2.0 * sy;
		_data[6] = 0;
		_data[7] = 0;
		_data[8] = 0;
		_data[9] = 0;
		_data[10] = -2.0 * sz;
		_data[11] = 0;
		_data[12] = -(x0 + x1) * sx;
		_data[13] = -(y0 + y1) * sy;
		_data[14] = -(zNear + zFar) * sz;
		_data[15] = 1;

		return _f32;
	}

	static var _point:Point = new Point();
	static var _f32:Float32Array = new Float32Array(16);

	// builtin shaders used to render DrawCommands
	var colorShader:ColorShader;
	var textureShader:TextureShader;

	// for render to texture
	var fb:FrameBuffer;
	var backFb:FrameBuffer;
	var postProcessBuffer:GLBuffer;

	var buffer:Float32Array;
	var glBuffer:GLBuffer;

	public function new() {}

	@:access(haxepunk.graphics.atlas.DrawCommand)
	@:access(haxepunk.graphics.atlas.RenderData)
	public function render(drawCommand:DrawCommand, scene:Scene, rect:Rectangle):Void
	{
		if (drawCommand != null && drawCommand.dataCount > 0)
		{
			var shader:BaseShader;
			if (drawCommand.texture == null)
			{
				shader = colorShader;
			}
			else
			{
				shader = textureShader;
			}
			shader.bind();

			var bufferChunkSize = shader.bufferChunkSize;

			var blend:BlendMode = drawCommand.blend;
			var smooth:Bool = drawCommand.smooth;

			var tx:Float, ty:Float, rx:Float, ry:Float, rw:Float, rh:Float, a:Float, b:Float, c:Float, d:Float,
				uvx:Float = 0, uvy:Float = 0, uvx2:Float = 0, uvy2:Float = 0,
				red:Float, green:Float, blue:Float, alpha:Float;

			// expand arrays if necessary
			var bufferLength:Int = buffer == null ? 0 : buffer.length;
			var items = drawCommand.dataCount;
			if (bufferLength < items * bufferChunkSize * 3)
			{
				buffer = new Float32Array(resize(bufferLength, items, bufferChunkSize * 3));

				GL.bindBuffer(GL.ARRAY_BUFFER, glBuffer);
				GL.bufferData(GL.ARRAY_BUFFER, buffer, GL.DYNAMIC_DRAW);
			}

			var bufferPos:Int = 0;
			var texture = drawCommand.texture;
			var data = drawCommand.data;
			var x0:Float, y0:Float;

			var dataCount:Int = 0;
			while (data != null)
			{
				buffer[bufferPos++] = data.tx1;
				buffer[bufferPos++] = data.ty1;
				buffer[bufferPos++] = data.red;
				buffer[bufferPos++] = data.green;
				buffer[bufferPos++] = data.blue;
				buffer[bufferPos++] = data.alpha;
				if (texture != null)
				{
					buffer[bufferPos++] = data.rx1;
					buffer[bufferPos++] = data.ry1;
				}

				buffer[bufferPos++] = data.tx2;
				buffer[bufferPos++] = data.ty2;
				buffer[bufferPos++] = data.red;
				buffer[bufferPos++] = data.green;
				buffer[bufferPos++] = data.blue;
				buffer[bufferPos++] = data.alpha;
				if (texture != null)
				{
					buffer[bufferPos++] = data.rx2;
					buffer[bufferPos++] = data.ry2;
				}

				buffer[bufferPos++] = data.tx3;
				buffer[bufferPos++] = data.ty3;
				buffer[bufferPos++] = data.red;
				buffer[bufferPos++] = data.green;
				buffer[bufferPos++] = data.blue;
				buffer[bufferPos++] = data.alpha;
				if (texture != null)
				{
					buffer[bufferPos++] = data.rx3;
					buffer[bufferPos++] = data.ry3;
				}

				data = data._next;
				dataCount++;
			}

			var x0 = HXP.screen.x + rect.x, y0 = HXP.screen.y + rect.y;
			var transformation = ortho(-x0, -x0 + HXP.screen.width, -y0 + HXP.screen.height, -y0, 1000, -1000);
			GL.uniformMatrix4fv(shader.uniformIndex("uMatrix"), false, transformation);

			if (texture != null)
			{
				#if (lime && !flash)
				var renderer:GLRenderer = cast HXP.stage.__renderer;
				var renderSession = renderer.renderSession;
				GL.bindTexture(GL.TEXTURE_2D, texture.getTexture(renderSession.gl));
				#elseif nme
				if (!texture.premultipliedAlpha) texture.premultipliedAlpha = true;
				GL.bindBitmapDataTexture(texture);
				#end
				if (smooth)
				{
					GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
					GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
				}
				else
				{
					GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
					GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
				}
				GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
				GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
			}

			GL.bindBuffer(GL.ARRAY_BUFFER, glBuffer);
			GL.bufferSubData(GL.ARRAY_BUFFER, 0, buffer);

			var blend = drawCommand.blend;
			if (blend == null) blend = BlendMode.ALPHA;
			switch (blend)
			{
				case BlendMode.ADD:
					GL.blendEquationSeparate(GL.FUNC_ADD, GL.FUNC_ADD);
					GL.blendFuncSeparate(GL.ONE, GL.ONE, GL.ZERO, GL.ONE);
				case BlendMode.MULTIPLY:
					GL.blendEquationSeparate(GL.FUNC_ADD, GL.FUNC_ADD);
					GL.blendFuncSeparate(GL.DST_COLOR, GL.ONE_MINUS_SRC_ALPHA, GL.ZERO, GL.ONE);
				case BlendMode.SCREEN:
					GL.blendEquationSeparate(GL.FUNC_ADD, GL.FUNC_ADD);
					GL.blendFuncSeparate(GL.ONE, GL.ONE_MINUS_SRC_COLOR, GL.ZERO, GL.ONE);
				case BlendMode.SUBTRACT:
					GL.blendEquationSeparate(GL.FUNC_REVERSE_SUBTRACT, GL.FUNC_ADD);
					GL.blendFuncSeparate(GL.ONE, GL.ONE, GL.ZERO, GL.ONE);
				default:
					GL.blendEquation(GL.FUNC_ADD);
					GL.blendFunc(GL.ONE, GL.ONE_MINUS_SRC_ALPHA);
			}

			var stride = bufferChunkSize * FLOAT32_BYTES;
			GL.vertexAttribPointer(shader.attributeIndex("aPosition"), 2, GL.FLOAT, false, stride, 0);
			GL.vertexAttribPointer(shader.attributeIndex("aColor"), 4, GL.FLOAT, false, stride, 2 * FLOAT32_BYTES);
			if (texture != null)
			{
				GL.vertexAttribPointer(shader.attributeIndex("aTexCoord"), 2, GL.FLOAT, false, stride, 6 * FLOAT32_BYTES);
			}

			GL.scissor(Std.int(x0), Std.int(HXP.screen.height - y0 - rect.height), Std.int(rect.width), Std.int(rect.height));
			GL.enable(GL.SCISSOR_TEST);
			GL.drawArrays(GL.TRIANGLES, 0, items * 3);
			GL.disable(GL.SCISSOR_TEST);

			GL.bindBuffer(GL.ARRAY_BUFFER, null);

			shader.unbind();
		}

#if debug
		checkForGLErrors();
#end
	}

	public function startScene(scene:Scene)
	{
		if (GLUtils.invalid(glBuffer) || GLUtils.invalid(postProcessBuffer))
		{
			destroy();
			init();
		}

		var postProcess:Array<Shader> = scene.shaders;
		if (postProcess != null && postProcess.length > 0)
		{
			fb.bindFrameBuffer();
		}
		else
		{
			GL.bindFramebuffer(GL.FRAMEBUFFER, null);
		}
	}

	public function flushScene(scene:Scene)
	{
		var postProcess:Array<Shader> = scene.shaders;
		if (postProcess != null)
		{
			for (i in 0 ... postProcess.length)
			{
				var last = i == postProcess.length - 1;
				var shader = postProcess[i];
				var renderTexture = fb.texture;

				if (last)
				{
					// render to screen
					GL.bindFramebuffer(GL.FRAMEBUFFER, null);
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

				GL.enableVertexAttribArray(shader.attributeIndex("aPosition"));
				GL.enableVertexAttribArray(shader.attributeIndex("aTexCoord"));

				GL.activeTexture(GL.TEXTURE0);
				GL.bindTexture(GL.TEXTURE_2D, renderTexture);
				GL.enable(GL.TEXTURE_2D);

				GL.bindBuffer(GL.ARRAY_BUFFER, postProcessBuffer);
				GL.vertexAttribPointer(shader.attributeIndex("aPosition"), 2, GL.FLOAT, false, 16, 0);
				GL.vertexAttribPointer(shader.attributeIndex("aTexCoord"), 2, GL.FLOAT, false, 16, 8);
				GL.uniform1i(shader.uniformIndex("uImage0"), 0);
				GL.uniform2f(shader.uniformIndex("uResolution"), HXP.screen.width, HXP.screen.height);

				GL.blendEquation(GL.FUNC_ADD);
				GL.blendFunc(GL.ONE, GL.ONE_MINUS_SRC_ALPHA);
				GL.drawArrays(GL.TRIANGLES, 0, 6);

				GL.bindBuffer(GL.ARRAY_BUFFER, null);
				GL.disable(GL.TEXTURE_2D);
				GL.bindTexture(GL.TEXTURE_2D, null);

				GL.disableVertexAttribArray(shader.attributeIndex("aPosition"));
				GL.disableVertexAttribArray(shader.attributeIndex("aTexCoord"));

				shader.unbind();

				GL.bindFramebuffer(GL.FRAMEBUFFER, null);
			}
		}
	}

	public function startFrame(scene:Scene) {}
	public function endFrame(scene:Scene) {}

	inline function init()
	{
		if (fb == null)
		{
			fb = new FrameBuffer();
			backFb = new FrameBuffer();
			colorShader = new ColorShader();
			textureShader = new TextureShader();
		}

		glBuffer = GL.createBuffer();
		postProcessBuffer = GL.createBuffer();
		GL.bindBuffer(GL.ARRAY_BUFFER, postProcessBuffer);
		GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(_vertices), GL.STATIC_DRAW);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
	}

	inline function destroy() {}
}
#end
