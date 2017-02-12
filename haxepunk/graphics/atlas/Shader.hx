package haxepunk.graphics.atlas;

import openfl.Assets;

#if flash
class Shader
{
	public static function fromAsset(_:String) throw "shaders are not supported on Flash";
	public function new(_:String) throw "shaders are not supported on Flash";
}
#else
/**
 * Used to create a custom shader.
 */
class Shader extends BaseShader
{
	static inline var DEFAULT_VERTEX_SHADER:String = "
#ifdef GL_ES
precision mediump float;
#endif

attribute vec4 aPosition;
attribute vec2 aTexCoord;
varying vec2 vTexCoord;

void main() {
	vTexCoord = aTexCoord;
	gl_Position = aPosition;
}";

	/**
	 * Create a custom shader from a text asset.
	 */
	public static inline function fromAsset(name:String):Shader
	{
		return new Shader(Assets.getText(name));
	}

	/**
	 * Create a custom shader from a string.
	 */
	public function new(fragmentSource:String)
	{
		super(DEFAULT_VERTEX_SHADER, fragmentSource);
	}
}
#end
