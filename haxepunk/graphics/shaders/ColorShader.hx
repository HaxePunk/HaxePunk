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

	override public function unbind()
	{
		super.unbind();
		GL.disableVertexAttribArray(position);
		GL.disableVertexAttribArray(color);
	}

	static var instance:ColorShader;
}
#end
