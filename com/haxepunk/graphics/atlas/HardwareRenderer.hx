package com.haxepunk.graphics.atlas;

#if tile_shader
import flash.geom.Rectangle;
import openfl.display.BlendMode;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.gl.GLProgram;
#if lime
import lime.utils.Float32Array;
import lime.utils.UInt32Array;
#if !flash
import openfl._internal.renderer.opengl.GLRenderer;
#end
#elseif nme
import nme.utils.Float32Array;
import nme.utils.Int32Array as UInt32Array;
#end
import com.haxepunk.HXP;

@:dox(hide)
private class TextureShader
{
	public var glProgram:GLProgram;

	public static inline var VERTEX_SHADER =
"
#version 120

attribute vec4 aPosition;
attribute vec2 aTexCoord;
attribute vec4 aColor;
varying vec2 vTexCoord;
varying vec4 vColor;
uniform mat4 uMatrix;

void main(void) {
	vTexCoord = aTexCoord;
	vColor = aColor;
	gl_Position = uMatrix * aPosition;
}";

	public static inline var FRAGMENT_SHADER =
"#version 120
" +
#if !desktop "precision mediump float;
" + #end
"
varying vec2 vTexCoord;
varying vec4 vColor;
uniform sampler2D uImage0;

void main(void) {
	vec4 color = texture2D (uImage0, vTexCoord);
	if (color.a == 0.0) {
		gl_FragColor = vec4 (0.0, 0.0, 0.0, 0.0);
	} else {
		gl_FragColor = vec4 (color.rgb / color.a, color.a)*vColor;
	}
}";

	public function new()
	{
		glProgram = GL.createProgram();

		var vertexShader = GL.createShader(GL.VERTEX_SHADER);
		GL.shaderSource(vertexShader, VERTEX_SHADER);
		GL.compileShader(vertexShader);
		if (GL.getShaderParameter(vertexShader, GL.COMPILE_STATUS) == 0)
			throw "Error compiling vertex shader";
		GL.attachShader(glProgram, vertexShader);

		var fragmentShader = GL.createShader(GL.FRAGMENT_SHADER);
		GL.shaderSource(fragmentShader, FRAGMENT_SHADER);
		GL.compileShader(fragmentShader);
		if (GL.getShaderParameter(fragmentShader, GL.COMPILE_STATUS) == 0)
			throw "Error compiling fragment shader";
		GL.attachShader(glProgram, fragmentShader);

		GL.linkProgram(glProgram);
		if (GL.getProgramParameter(glProgram, GL.LINK_STATUS) == 0)
			throw "Unable to initialize the shader program.";
	}

	public inline function bind()
	{
		GL.useProgram(glProgram);
		GL.enableVertexAttribArray(attributeIndex("aPosition"));
		GL.enableVertexAttribArray(attributeIndex("aTexCoord"));
		GL.enableVertexAttribArray(attributeIndex("aColor"));
	}

	public inline function unbind()
	{
		GL.useProgram(null);
		GL.disableVertexAttribArray(attributeIndex("aPosition"));
		GL.disableVertexAttribArray(attributeIndex("aTexCoord"));
		GL.disableVertexAttribArray(attributeIndex("aColor"));
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
	static inline var BUFFER_CHUNK:Int = 32;
	static inline var INDEX_CHUNK:Int = 6;
	static inline var FLOAT32_BYTES:Int = #if lime Float32Array.BYTES_PER_ELEMENT #else Float32Array.SBYTES_PER_ELEMENT #end;

	static var textureShader:TextureShader;

	static inline function resize(length:Int, minChunks:Int, chunkSize:Int)
	{
		return Std.int(Math.max(
			Std.int(length * 2 / chunkSize),
			minChunks
		) * chunkSize);
	}

	static inline function matrixTransformX(m:Matrix, px:Float, py:Float):Float
	{
		return px * m.a + py * m.c + m.tx;
	}

	static inline function matrixTransformY(m:Matrix, px:Float, py:Float):Float
	{
		return px * m.b + py * m.d + m.ty;
	}

	static var buffer:Float32Array;
	static var indexes:UInt32Array;
	static var glBuffer:GLBuffer;
	static var glIndexes:GLBuffer;

	@:access(com.haxepunk.graphics.atlas.DrawCommand)
	@:access(com.haxepunk.graphics.atlas.QuadData)
	public static function render(drawCommand:DrawCommand, scene:Scene, rect:Rectangle):Void
	{
		if (drawCommand != null && drawCommand.quads > 0)
		{
			if (textureShader == null) textureShader = new TextureShader();

			var shader = textureShader;
			shader.bind();

			var blend:Int = drawCommand.blend;
			var smooth:Bool = drawCommand.smooth;

			var tx:Float, ty:Float, rx:Float, ry:Float, rw:Float, rh:Float, a:Float, b:Float, c:Float, d:Float,
				uvx:Float = 0, uvy:Float = 0, uvx2:Float = 0, uvy2:Float = 0,
				red:Float, green:Float, blue:Float, alpha:Float;

			if (glBuffer == null)
			{
				glBuffer = GL.createBuffer();
				glIndexes = GL.createBuffer();
			}

			// expand arrays if necessary
			var bufferLength:Int = buffer == null ? 0 : buffer.length;
			var items = drawCommand.quads;
			if (bufferLength < items * BUFFER_CHUNK)
			{
				buffer = new Float32Array(resize(bufferLength, items, BUFFER_CHUNK));

				GL.bindBuffer(GL.ARRAY_BUFFER, glBuffer);
				GL.bufferData(GL.ARRAY_BUFFER, buffer, GL.DYNAMIC_DRAW);
			}
			var indexLength:Int = indexes == null ? 0 : indexes.length;
			if (indexLength < items * INDEX_CHUNK)
			{
				var newIndexes = new UInt32Array(resize(indexLength, items, INDEX_CHUNK));
				var i:Int = 0, vi:Int = 0;
				for (v in 0 ... Std.int(newIndexes.length / INDEX_CHUNK))
				{
					vi = v * 4;
					newIndexes[i++] = vi;
					newIndexes[i++] = vi + 1;
					newIndexes[i++] = vi + 2;
					newIndexes[i++] = vi + 2;
					newIndexes[i++] = vi + 1;
					newIndexes[i++] = vi + 3;
				}
				indexes = newIndexes;

				GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, glIndexes);
				GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indexes, GL.DYNAMIC_DRAW);
			}

			var bufferPos:Int = 0, matrix:Matrix = HXP.matrix;
			var texture = drawCommand.texture;
			var quad = drawCommand.quad;
			var x0:Float, y0:Float;

			var quads:Int = 0;
			while (quad != null)
			{
				rx = quad.rx;
				ry = quad.ry;
				rw = quad.rw;
				rh = quad.rh;
				a = quad.a;
				b = quad.b;
				c = quad.c;
				d = quad.d;
				tx = quad.tx;
				ty = quad.ty;
				red = quad.red;
				green = quad.green;
				blue = quad.blue;
				alpha = quad.alpha;

				if (texture != null)
				{
					uvx = (rx / texture.width);
					uvy = (ry / texture.height);
					uvx2 = ((rx + rw) / texture.width);
					uvy2 = ((ry + rh) / texture.height);
				}

				matrix.setTo(a, b, c, d, tx, ty);

				inline function transformX(x, y) return matrixTransformX(matrix, x, y);
				inline function transformY(x, y) return matrixTransformY(matrix, x, y);

				buffer[bufferPos++] = transformX(0, 0);
				buffer[bufferPos++] = transformY(0, 0);
				if (texture != null)
				{
					buffer[bufferPos++] = uvx;
					buffer[bufferPos++] = uvy;
				}
				buffer[bufferPos++] = red;
				buffer[bufferPos++] = green;
				buffer[bufferPos++] = blue;
				buffer[bufferPos++] = alpha;
				buffer[bufferPos++] = transformX(rw, 0);
				buffer[bufferPos++] = transformY(rw, 0);
				if (texture != null)
				{
					buffer[bufferPos++] = uvx2;
					buffer[bufferPos++] = uvy;
				}
				buffer[bufferPos++] = red;
				buffer[bufferPos++] = green;
				buffer[bufferPos++] = blue;
				buffer[bufferPos++] = alpha;
				buffer[bufferPos++] = transformX(0, rh);
				buffer[bufferPos++] = transformY(0, rh);
				if (texture != null)
				{
					buffer[bufferPos++] = uvx;
					buffer[bufferPos++] = uvy2;
				}
				buffer[bufferPos++] = red;
				buffer[bufferPos++] = green;
				buffer[bufferPos++] = blue;
				buffer[bufferPos++] = alpha;
				buffer[bufferPos++] = transformX(rw, rh);
				buffer[bufferPos++] = transformY(rw, rh);
				if (texture != null)
				{
					buffer[bufferPos++] = uvx2;
					buffer[bufferPos++] = uvy2;
				}
				buffer[bufferPos++] = red;
				buffer[bufferPos++] = green;
				buffer[bufferPos++] = blue;
				buffer[bufferPos++] = alpha;

				quad = quad._next;
				quads++;
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

			GL.vertexAttribPointer(shader.attributeIndex("aPosition"), 2, GL.FLOAT, false, 8 * FLOAT32_BYTES, 0);
			if (texture != null)
			{
				GL.vertexAttribPointer(shader.attributeIndex("aTexCoord"), 2, GL.FLOAT, false, 8 * FLOAT32_BYTES, 2 * FLOAT32_BYTES);
			}
			GL.vertexAttribPointer(shader.attributeIndex("aColor"), 4, GL.FLOAT, false, 8 * FLOAT32_BYTES, 4 * FLOAT32_BYTES);

			GL.scissor(Std.int(x0), Std.int(HXP.stage.stageHeight - y0 - rect.height), Std.int(rect.width), Std.int(rect.height));
			GL.enable(GL.SCISSOR_TEST);
			GL.drawElements(GL.TRIANGLES, items * INDEX_CHUNK, GL.UNSIGNED_INT, 0);
			GL.disable(GL.SCISSOR_TEST);

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
