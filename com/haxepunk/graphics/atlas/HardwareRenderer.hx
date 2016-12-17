package com.haxepunk.graphics.atlas;

#if tile_shader
import flash.geom.Rectangle;
import openfl.display.BlendMode;
import openfl.geom.Point;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.gl.GLProgram;
#if lime
import lime.utils.Float32Array;
#if !flash
import openfl._internal.renderer.opengl.GLRenderer;
#end
#elseif nme
import nme.utils.Float32Array;
#end
import com.haxepunk.HXP;

@:dox(hide)
private class Shader
{
	public var glProgram:GLProgram;
	public var bufferChunkSize:Int = 0;

	public function new(vertexSource:String, fragmentSource:String)
	{
		var vertexShader = GL.createShader(GL.VERTEX_SHADER);
		GL.shaderSource(vertexShader, vertexSource);
		GL.compileShader(vertexShader);
		if (GL.getShaderParameter(vertexShader, GL.COMPILE_STATUS) == 0)
			throw "Error compiling vertex shader: " +
			GL.getShaderInfoLog(vertexShader);

		var fragmentShader = GL.createShader(GL.FRAGMENT_SHADER);
		GL.shaderSource(fragmentShader, fragmentSource);
		GL.compileShader(fragmentShader);
		if (GL.getShaderParameter(fragmentShader, GL.COMPILE_STATUS) == 0)
			throw "Error compiling fragment shader: " +
			GL.getShaderInfoLog(fragmentShader);

		glProgram = GL.createProgram();
		GL.attachShader(glProgram, fragmentShader);
		GL.attachShader(glProgram, vertexShader);
		GL.linkProgram(glProgram);
		if (GL.getProgramParameter(glProgram, GL.LINK_STATUS) == 0)
			throw "Unable to initialize the shader program.";
	}

	public function bind()
	{
		GL.useProgram(glProgram);
	}

	public function unbind()
	{
		GL.useProgram(null);
	}

	public inline function attributeIndex(name:String)
	{
		return GL.getAttribLocation(glProgram, name);
	}

	public inline function uniformIndex(name:String)
	{
		return GL.getUniformLocation(glProgram, name);
	}
}

@:dox(hide)
private class TextureShader extends Shader
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
		gl_FragColor = vec4(color.rgb / color.a, color.a) * vColor;
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
private class ColorShader extends Shader
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
	gl_FragColor = clamp(vColor, 0.0, 1.0);
	//gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
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
 * Rendering backend used for compatibility with OpenFL 4.0, which removed
 * support for drawTiles. Based on work by @Yanrishatum and @Beeblerox.
 * @since	2.6.0
 */
#if lime
@:access(openfl.display.Stage)
@:access(openfl._internal.renderer.opengl.GLRenderer)
#end
@:access(com.haxepunk.Scene)
@:dox(hide)
class HardwareRenderer
{
	static inline var FLOAT32_BYTES:Int = #if lime Float32Array.BYTES_PER_ELEMENT #else Float32Array.SBYTES_PER_ELEMENT #end;

	static var colorShader:ColorShader;
	static var textureShader:TextureShader;

	static inline function resize(length:Int, minChunks:Int, chunkSize:Int)
	{
		return Std.int(Math.max(
			Std.int(length * 2 / chunkSize),
			minChunks
		) * chunkSize);
	}

	static var buffer:Float32Array;
	static var glBuffer:GLBuffer;

	@:access(com.haxepunk.graphics.atlas.DrawCommand)
	@:access(com.haxepunk.graphics.atlas.RenderData)
	public static function render(drawCommand:DrawCommand, scene:Scene, rect:Rectangle):Void
	{
		if (colorShader == null) colorShader = new ColorShader();
		if (textureShader == null) textureShader = new TextureShader();

		if (drawCommand != null && drawCommand.dataCount > 0)
		{
			var shader:Shader;
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

			var blend:Int = drawCommand.blend;
			var smooth:Bool = drawCommand.smooth;

			var tx:Float, ty:Float, rx:Float, ry:Float, rw:Float, rh:Float, a:Float, b:Float, c:Float, d:Float,
				uvx:Float = 0, uvy:Float = 0, uvx2:Float = 0, uvy2:Float = 0,
				red:Float, green:Float, blue:Float, alpha:Float;

			if (glBuffer == null)
			{
				glBuffer = GL.createBuffer();
			}

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
			var transformation = ortho(-x0, -x0 + HXP.stage.stageWidth, -y0 + HXP.stage.stageHeight, -y0, 1000, -1000);
			GL.uniformMatrix4fv(shader.uniformIndex("uMatrix"), false, transformation);

			if (texture != null)
			{
				#if (lime && !flash)
				var renderer:GLRenderer = cast HXP.stage.__renderer;
				var renderSession = renderer.renderSession;
				GL.bindTexture(GL.TEXTURE_2D, texture.getTexture(renderSession.gl));
				#elseif nme
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
			}

			GL.bindBuffer(GL.ARRAY_BUFFER, glBuffer);
			GL.bufferSubData(GL.ARRAY_BUFFER, 0, buffer);

			switch (drawCommand.blend)
			{
				case BlendMode.Add:
					GL.blendEquation(GL.FUNC_ADD);
					GL.blendFunc(GL.ONE, GL.ONE);
				case BlendMode.Multiply:
					GL.blendEquation(GL.FUNC_ADD);
					GL.blendFunc(GL.DST_COLOR, GL.ONE_MINUS_SRC_ALPHA);
				case BlendMode.Screen:
					GL.blendEquation(GL.FUNC_ADD);
					GL.blendFunc(GL.ONE, GL.ONE_MINUS_SRC_COLOR);
				case BlendMode.Subtract:
					GL.blendEquation(GL.FUNC_REVERSE_SUBTRACT);
					GL.blendFunc(GL.ONE, GL.ONE);
				default:
					GL.blendEquation(GL.FUNC_ADD);
					GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
			}

			var stride = bufferChunkSize * FLOAT32_BYTES;
			GL.vertexAttribPointer(shader.attributeIndex("aPosition"), 2, GL.FLOAT, false, stride, 0);
			GL.vertexAttribPointer(shader.attributeIndex("aColor"), 4, GL.FLOAT, false, stride, 2 * FLOAT32_BYTES);
			if (texture != null)
			{
				GL.vertexAttribPointer(shader.attributeIndex("aTexCoord"), 2, GL.FLOAT, false, stride, 6 * FLOAT32_BYTES);
			}

			GL.scissor(Std.int(x0), Std.int(HXP.stage.stageHeight - y0 - rect.height), Std.int(rect.width), Std.int(rect.height));
			GL.enable(GL.SCISSOR_TEST);
			GL.drawArrays(GL.TRIANGLES, 0, items * 3);
			GL.disable(GL.SCISSOR_TEST);

			GL.bindBuffer(GL.ARRAY_BUFFER, null);

			shader.unbind();
		}

		checkForGLErrors();
	}

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

	public static function startFrame(scene:Scene) {}
	public static function endFrame(scene:Scene) {}

	static var _point:Point = new Point();
	static var _f32:Float32Array = new Float32Array(16);
}
#end
