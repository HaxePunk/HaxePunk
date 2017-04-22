package haxepunk.graphics.shaders;

#if hardware_render

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

	public function new(?fragment:String)
	{
		super(VERTEX_SHADER, fragment == null ? FRAGMENT_SHADER : fragment);
		position.name = "aPosition";
		color.name = "aColor";
	}

	public static var defaultShader(get, null):ColorShader;
	static inline function get_defaultShader():ColorShader
	{
		if (defaultShader == null) defaultShader = new ColorShader();
		return defaultShader;
	}
}
#end
