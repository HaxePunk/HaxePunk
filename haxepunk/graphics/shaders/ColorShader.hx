package haxepunk.graphics.shaders;

#if hardware_render
import flash.gl.GL;
import haxepunk.graphics.atlas.Float32Array;
import haxepunk.graphics.atlas.DrawCommand;

@:dox(hide)
class ColorShader extends Shader
{
	static var VERTEX_SHADER =
"// HaxePunk color vertex shader
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

	static var FRAGMENT_SHADER =
"// HaxePunk color fragment shader
#ifdef GL_ES
precision mediump float;
#endif

varying vec4 vColor;

void main(void) {
	gl_FragColor = vColor;
}";

	function new()
	{
		super(VERTEX_SHADER, FRAGMENT_SHADER);
		bytesPerVertex = 6;
	}

	public static function get():ColorShader
	{
		if (instance == null) instance = new ColorShader();
		return instance;
	}

	override public function build()
	{
		super.build();
		position = attributeIndex("aPosition");
		color = attributeIndex("aColor");
	}

	override public function bind()
	{
		super.bind();

		GL.enableVertexAttribArray(position);
		GL.enableVertexAttribArray(color);
	}

	override public function prepare(drawCommand:DrawCommand, buffer:Float32Array)
	{
		var bufferPos:Int = -1;
		drawCommand.loopRenderData(function(data) {
			buffer[++bufferPos] = data.tx1;
			buffer[++bufferPos] = data.ty1;
			buffer[++bufferPos] = data.red;
			buffer[++bufferPos] = data.green;
			buffer[++bufferPos] = data.blue;
			buffer[++bufferPos] = data.alpha;

			buffer[++bufferPos] = data.tx2;
			buffer[++bufferPos] = data.ty2;
			buffer[++bufferPos] = data.red;
			buffer[++bufferPos] = data.green;
			buffer[++bufferPos] = data.blue;
			buffer[++bufferPos] = data.alpha;

			buffer[++bufferPos] = data.tx3;
			buffer[++bufferPos] = data.ty3;
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
		GL.vertexAttribPointer(color, 4, GL.FLOAT, false, stride, 2 * Float32Array.BYTES_PER_ELEMENT);
	}

	override public function unbind()
	{
		super.unbind();
		GL.disableVertexAttribArray(position);
		GL.disableVertexAttribArray(color);
	}

	var position:Int;
	var color:Int;

	static var instance:ColorShader;
}
#end
