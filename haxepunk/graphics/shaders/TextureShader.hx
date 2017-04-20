package haxepunk.graphics.shaders;

#if hardware_render
import flash.gl.GL;
import flash.utils.ArrayBufferView;
import flash.utils.Int32Array;
import haxepunk.graphics.atlas.Float32Array;
import haxepunk.graphics.atlas.DrawCommand;

@:dox(hide)
class TextureShader extends Shader
{
	static var VERTEX_SHADER =
"// HaxePunk texture vertex shader
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

	static var FRAGMENT_SHADER =
"// HaxePunk texture fragment shader
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

	function new()
	{
		super(VERTEX_SHADER, FRAGMENT_SHADER);
		bytesPerVertex = 8;
	}

	public static function get():TextureShader
	{
		if (instance == null) instance = new TextureShader();
		return instance;
	}

	override public function build()
	{
		super.build();
		position = attributeIndex("aPosition");
		texCoord = attributeIndex("aTexCoord");
		color = attributeIndex("aColor");
	}

	override public function bind()
	{
		super.bind();

		GL.enableVertexAttribArray(position);
		GL.enableVertexAttribArray(texCoord);
		GL.enableVertexAttribArray(color);
	}

	override public function prepare(drawCommand:DrawCommand, buffer:Float32Array)
	{
		var bufferPos:Int = -1;
		drawCommand.loopRenderData(function(data) {
			buffer[++bufferPos] = data.tx1;
			buffer[++bufferPos] = data.ty1;
			buffer[++bufferPos] = data.uvx1;
			buffer[++bufferPos] = data.uvy1;
			buffer[++bufferPos] = data.red;
			buffer[++bufferPos] = data.green;
			buffer[++bufferPos] = data.blue;
			buffer[++bufferPos] = data.alpha;

			buffer[++bufferPos] = data.tx2;
			buffer[++bufferPos] = data.ty2;
			buffer[++bufferPos] = data.uvx2;
			buffer[++bufferPos] = data.uvy2;
			buffer[++bufferPos] = data.red;
			buffer[++bufferPos] = data.green;
			buffer[++bufferPos] = data.blue;
			buffer[++bufferPos] = data.alpha;

			buffer[++bufferPos] = data.tx3;
			buffer[++bufferPos] = data.ty3;
			buffer[++bufferPos] = data.uvx3;
			buffer[++bufferPos] = data.uvy3;
			buffer[++bufferPos] = data.red;
			buffer[++bufferPos] = data.green;
			buffer[++bufferPos] = data.blue;
			buffer[++bufferPos] = data.alpha;
		});

		#if (lime >= "4.0.0")
		GL.bufferSubData(GL.ARRAY_BUFFER, 0, buffer.length * Float32Array.BYTES_PER_ELEMENT, buffer);
		#else
		GL.bufferSubData(GL.ARRAY_BUFFER, 0, buffer);
		#end

		var stride = bytesPerVertex * Float32Array.BYTES_PER_ELEMENT;
		GL.vertexAttribPointer(position, 2, GL.FLOAT, false, stride, 0);
		GL.vertexAttribPointer(texCoord, 2, GL.FLOAT, false, stride, 2 * Float32Array.BYTES_PER_ELEMENT);
		GL.vertexAttribPointer(color, 4, GL.FLOAT, false, stride, 4 * Float32Array.BYTES_PER_ELEMENT);
	}

	override public function unbind()
	{
		super.unbind();
		GL.disableVertexAttribArray(position);
		GL.disableVertexAttribArray(texCoord);
		GL.disableVertexAttribArray(color);
	}

	var position:Int;
	var texCoord:Int;
	var color:Int;

	static var instance:TextureShader;
}
#end
