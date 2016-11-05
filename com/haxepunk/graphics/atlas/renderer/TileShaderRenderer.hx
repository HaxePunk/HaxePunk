package com.haxepunk.graphics.atlas.renderer;

#if tile_shader
import lime.graphics.GLRenderContext;
import lime.utils.Float32Array;
import lime.utils.UInt32Array;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.Graphics;
import openfl.display.Shader;
import openfl.geom.Matrix;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.gl.GLProgram;
import openfl._internal.renderer.opengl.GLRenderer;
import com.haxepunk.HXP;

@:dox(hide)
private class TileShader
{
	public var glProgram:GLProgram;

	public static inline var VERTEX_SHADER = "
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

	public static inline var FRAGMENT_SHADER = "
#version 120

#ifdef GL_ES
    precision mediump float;
#endif

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
		var vertexShader = GL.createShader(GL.VERTEX_SHADER);
		GL.shaderSource(vertexShader, VERTEX_SHADER);
		GL.compileShader(vertexShader);
		if (GL.getShaderParameter(vertexShader, GL.COMPILE_STATUS) == 0)
			throw "Error compiling vertex shader";

		var fragmentShader = GL.createShader(GL.FRAGMENT_SHADER);
		GL.shaderSource(fragmentShader, FRAGMENT_SHADER);
		GL.compileShader(fragmentShader);
		if (GL.getShaderParameter(fragmentShader, GL.COMPILE_STATUS) == 0)
			throw "Error compiling fragment shader";

		glProgram = GL.createProgram();
		GL.attachShader(glProgram, vertexShader);
		GL.attachShader(glProgram, fragmentShader);
		GL.linkProgram(glProgram);
		if (GL.getProgramParameter(glProgram, GL.LINK_STATUS) == 0)
			throw "Unable to initialize the shader program.";
	}

	public function bind()
	{
		GL.useProgram(glProgram);
		GL.enableVertexAttribArray(GL.getAttribLocation(glProgram, "aPosition"));
		GL.enableVertexAttribArray(GL.getAttribLocation(glProgram, "aTexCoord"));
		GL.enableVertexAttribArray(GL.getAttribLocation(glProgram, "aColor"));
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
 * support for drawTiles. Based on work by @Yanrishatum.
 * @since	2.6.0
 */
@:access(openfl.display.Stage)
@:access(openfl.display.DisplayObject)
@:access(openfl.display.Graphics)
@:access(openfl._internal.renderer.RenderSession)
@:access(openfl._internal.renderer.opengl.GLRenderer)
@:dox(hide)
class TileShaderRenderer
{
	static inline var BUFFER_CHUNK:Int = 32;
	static inline var INDEX_CHUNK:Int = 6;

	static var shader:TileShader;

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

	var data:AtlasData;

	var buffer:Float32Array;
	var indexes:UInt32Array;
	var glBuffer:GLBuffer;
	var glIndexes:GLBuffer;

	public function new(data:AtlasData)
	{
		this.data = data;
		if (shader == null) shader = new TileShader();
	}

	public inline function drawTiles(graphics:Graphics, tileData:Array<Float>, smooth:Bool = false, flags:Int = 0, count:Int = -1):Void
	{
		if (count == -1) count = tileData.length;

		if (count > 0)
		{
			var renderer:GLRenderer = cast HXP.stage.__renderer;
			var renderSession = renderer.renderSession;
			var gl:GLRenderContext = renderSession.gl;
			var displayObject:DisplayObject = graphics.__owner;

			var blend:Int = data.blend;
			var texture:BitmapData = data.bitmapData;

			var tx:Float, ty:Float, rx:Float, ry:Float, rw:Float, rh:Float, a:Float, b:Float, c:Float, d:Float,
				uvx:Float, uvy:Float, uvx2:Float, uvy2:Float,
				red:Float, green:Float, blue:Float, alpha:Float;

			// expand arrays if necessary
			var items = Std.int(count / 14);
			var bufferLength:Int = buffer == null ? 0 : buffer.length;
			if (bufferLength < items * BUFFER_CHUNK)
			{
				buffer = new Float32Array(resize(bufferLength, items, BUFFER_CHUNK));
			}
			var indexLength:Int = indexes == null ? 0 : indexes.length;
			if (indexLength < items * INDEX_CHUNK)
			{
				var newIndexes = new UInt32Array(resize(indexLength, items, INDEX_CHUNK));
				var i:Int = 0, vi:Int = 0;
				for (v in 0 ... Std.int(newIndexes.length / INDEX_CHUNK))
				{
					var vi = v * 4;
					newIndexes[i++] = vi;
					newIndexes[i++] = vi + 1;
					newIndexes[i++] = vi + 2;
					newIndexes[i++] = vi + 2;
					newIndexes[i++] = vi + 1;
					newIndexes[i++] = vi + 3;
				}
				indexes = newIndexes;
			}

			var n:Int = 0, bufferPos:Int = 0, matrix:Matrix = HXP.matrix;

			while (n < count)
			{
				tx = tileData[n++];
				ty = tileData[n++];
				rx = tileData[n++];
				ry = tileData[n++];
				rw = tileData[n++];
				rh = tileData[n++];
				a = tileData[n++];
				b = tileData[n++];
				c = tileData[n++];
				d = tileData[n++];
				red = tileData[n++];
				green = tileData[n++];
				blue = tileData[n++];
				alpha = tileData[n++];

				uvx = (rx / texture.width);
				uvy = (ry / texture.height);
				uvx2 = ((rx + rw) / texture.width);
				uvy2 = ((ry + rh) / texture.height);

				matrix.setTo(a, b, c, d, tx, ty);

				inline function transformX(x, y) return matrixTransformX(matrix, x, y);
				inline function transformY(x, y) return matrixTransformY(matrix, x, y);

				var start = bufferPos;
				buffer[bufferPos++] = transformX(0, 0);
				buffer[bufferPos++] = transformY(0, 0);
				buffer[bufferPos++] = uvx;
				buffer[bufferPos++] = uvy;
				buffer[bufferPos++] = red;
				buffer[bufferPos++] = green;
				buffer[bufferPos++] = blue;
				buffer[bufferPos++] = alpha;
				buffer[bufferPos++] = transformX(rw, 0);
				buffer[bufferPos++] = transformY(rw, 0);
				buffer[bufferPos++] = uvx2;
				buffer[bufferPos++] = uvy;
				buffer[bufferPos++] = red;
				buffer[bufferPos++] = green;
				buffer[bufferPos++] = blue;
				buffer[bufferPos++] = alpha;
				buffer[bufferPos++] = transformX(0, rh);
				buffer[bufferPos++] = transformY(0, rh);
				buffer[bufferPos++] = uvx;
				buffer[bufferPos++] = uvy2;
				buffer[bufferPos++] = red;
				buffer[bufferPos++] = green;
				buffer[bufferPos++] = blue;
				buffer[bufferPos++] = alpha;
				buffer[bufferPos++] = transformX(rw, rh);
				buffer[bufferPos++] = transformY(rw, rh);
				buffer[bufferPos++] = uvx2;
				buffer[bufferPos++] = uvy2;
				buffer[bufferPos++] = red;
				buffer[bufferPos++] = green;
				buffer[bufferPos++] = blue;
				buffer[bufferPos++] = alpha;
			}

			shader.bind();
			gl.uniform1f(shader.uniformIndex("uAlpha"), displayObject.__worldAlpha);
			gl.uniformMatrix4fv(shader.uniformIndex("uMatrix"), false, new lime.utils.Float32Array(renderer.getMatrix(displayObject.__renderTransform)));

			switch (blend)
			{
				case BlendMode.ADD:
					gl.blendEquation(gl.FUNC_ADD);
					gl.blendFunc(gl.ONE, gl.ONE);
				case BlendMode.MULTIPLY:
					gl.blendEquation(gl.FUNC_ADD);
					gl.blendFunc(gl.DST_COLOR, gl.ONE_MINUS_SRC_ALPHA);
				case BlendMode.SCREEN:
					gl.blendEquation(gl.FUNC_ADD);
					gl.blendFunc(gl.ONE, gl.ONE_MINUS_SRC_COLOR);
				case BlendMode.SUBTRACT:
					gl.blendEquation(gl.FUNC_REVERSE_SUBTRACT);
					gl.blendFunc(gl.ONE, gl.ONE);
				default:
					gl.blendEquation(gl.FUNC_ADD);
					gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
			}

			gl.bindTexture(gl.TEXTURE_2D, texture.getTexture(gl));
			if (smooth)
			{
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
			}
			else
			{
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
			}

			if (glBuffer == null)
			{
				glBuffer = gl.createBuffer();
				glIndexes = gl.createBuffer();
			}

			gl.bindBuffer(gl.ARRAY_BUFFER, glBuffer);
			gl.bufferData(gl.ARRAY_BUFFER, buffer, gl.DYNAMIC_DRAW);

			gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, glIndexes);
			gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indexes, gl.DYNAMIC_DRAW);

			gl.vertexAttribPointer(shader.attributeIndex("aPosition"), 2, gl.FLOAT, false, 8 * Float32Array.BYTES_PER_ELEMENT, 0);
			gl.vertexAttribPointer(shader.attributeIndex("aTexCoord"), 2, gl.FLOAT, false, 8 * Float32Array.BYTES_PER_ELEMENT, 2 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer(shader.attributeIndex("aColor"), 4, gl.FLOAT, false, 8 * Float32Array.BYTES_PER_ELEMENT, 4 * Float32Array.BYTES_PER_ELEMENT);

			gl.scissor(HXP.screen.x, HXP.screen.y, HXP.screen.width, HXP.screen.height);
			gl.enable(gl.SCISSOR_TEST);
			gl.drawElements(gl.TRIANGLES, items * INDEX_CHUNK, gl.UNSIGNED_INT, 0);
			gl.disable(gl.SCISSOR_TEST);

			renderSession.shaderManager.setShader(null);
		}
	}
}
#end
