package com.haxepunk.graphics.atlas.renderer;

#if ((openfl > "4.0.0") && (!flash))
import lime.graphics.GLRenderContext;
import lime.utils.Float32Array;
import lime.utils.UInt32Array;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.Graphics;
import openfl.display.Shader;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.display.Shader;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
#if !display
import openfl._internal.renderer.RenderSession;
import openfl._internal.renderer.opengl.GLRenderer;
#end
import com.haxepunk.HXP;


@:dox(hide)
private class TileShader extends Shader
{
	public function new()
	{
		glVertexSource =
			"attribute vec4 aPosition;
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

		glFragmentSource =
			"varying vec2 vTexCoord;
			varying vec4 vColor;
			uniform sampler2D uImage0;
			uniform float uAlpha;

			void main(void) {
				vec4 color = texture2D (uImage0, vTexCoord);

				if (color.a == 0.0) {

					gl_FragColor = vec4 (0.0, 0.0, 0.0, 0.0);

				} else {

					gl_FragColor = vec4 (color.rgb / color.a, color.a * uAlpha)*vColor;

				}
			}";

		super();
	}
}


/**
 * Rendering backend used for compatibility with OpenFL 4.0, which removed
 * support for drawTiles. Based on work by @Yanrishatum.
 */
@:access(openfl.display.Stage)
@:access(openfl.display.DisplayObject)
@:access(openfl.display.Graphics)
@:access(openfl._internal.renderer.RenderSession)
@:access(openfl._internal.renderer.opengl.GLRenderer)
class TileShaderRenderer
{
	static inline var BUFFER_CHUNK:Int = 32;
	static inline var INDEX_CHUNK:Int = 6;

	static var shader:TileShader;

	var data:AtlasData;

	var buffer:Float32Array = new Float32Array(BUFFER_CHUNK);
	var indexes:UInt32Array = new UInt32Array(INDEX_CHUNK);
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
			if (buffer.length < items * BUFFER_CHUNK)
			{
				var newBuffer = new Float32Array(Std.int(Math.max(buffer.length * 2, items * BUFFER_CHUNK)));
				for (i in 0 ... buffer.length) newBuffer[i] = buffer[i];
				buffer = newBuffer;
			}
			if (indexes.length < items * INDEX_CHUNK)
			{
				var newIndexes = new UInt32Array(Std.int(Math.max(indexes.length * 2, items * INDEX_CHUNK)));
				for (i in 0 ... indexes.length) newIndexes[i] = indexes[i];
				indexes = newIndexes;
			}

			var n:Int = 0, bufferPos:Int = 0, i:Int = 0, v:Int = 0, matrix:Matrix = HXP.matrix;

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

				inline function transformX(x, y) return matrix.__transformX(x, y);
				inline function transformY(x, y) return matrix.__transformY(x, y);

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
				indexes[i++] = v;
				indexes[i++] = v+1;
				indexes[i++] = v+2;
				indexes[i++] = v+2;
				indexes[i++] = v+1;
				indexes[i++] = v+3;
				v += 4;
			}

			renderSession.shaderManager.setShader(shader);
			gl.uniform1f(shader.data.uAlpha.index, displayObject.__worldAlpha);
			gl.uniformMatrix4fv(shader.data.uMatrix.index, false, renderer.getMatrix(displayObject.__worldTransform));

			renderSession.blendModeManager.setBlendMode(cast blend);

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

			gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, glIndexes);
			gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indexes, gl.DYNAMIC_DRAW);

			gl.bindBuffer(gl.ARRAY_BUFFER, glBuffer);
			gl.bufferData(gl.ARRAY_BUFFER, buffer, gl.DYNAMIC_DRAW);

			gl.vertexAttribPointer(shader.data.aPosition.index, 2, gl.FLOAT, false, 8 * Float32Array.BYTES_PER_ELEMENT, 0);
			gl.vertexAttribPointer(shader.data.aTexCoord.index, 2, gl.FLOAT, false, 8 * Float32Array.BYTES_PER_ELEMENT, 2 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer(shader.data.aColor.index, 4, gl.FLOAT, false, 8 * Float32Array.BYTES_PER_ELEMENT, 4 * Float32Array.BYTES_PER_ELEMENT);

			gl.drawElements(gl.TRIANGLES, items*6, gl.UNSIGNED_INT, 0);
		}
	}
}
#end
