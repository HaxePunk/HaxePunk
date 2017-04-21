package haxepunk.graphics.shaders;

#if hardware_render
import flash.gl.GL;
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

	override public function unbind()
	{
		super.unbind();
		GL.disableVertexAttribArray(position);
		GL.disableVertexAttribArray(texCoord);
		GL.disableVertexAttribArray(color);
	}

	static var instance:TextureShader;
}
#end
