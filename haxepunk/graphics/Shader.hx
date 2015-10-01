package haxepunk.graphics;

import haxe.ds.StringMap;
import haxepunk.renderers.Renderer;
import haxepunk.math.Matrix4;

/**
 * Shader object for GLSL and AGAL
 */
class Shader
{

	/**
	 * Creates a new Shader
	 * @param sources  A list of glsl shader sources to compile and link into a program
	 */
	public function new(vertex:String, fragment:String)
	{
		_program = Renderer.compileShaderProgram(vertex, fragment);
		_uniforms = new StringMap<Location>();
		_attributes = new StringMap<Int>();
	}

	/**
	 * Return the attribute location in this shader
	 * @param a  The attribute name to find
	 * @return the attribute location for binding
	 */
	public function attribute(a:String):Int
	{
		if (!_attributes.exists(a))
		{
			_attributes.set(a, Renderer.attribute(_program, a));
		}
		return _attributes.get(a);
	}

	/**
	 * Return the uniform location in this shader
	 * @param u  The uniform name to find
	 * @return the uniform location for binding
	 */
	public function uniform(u:String):Location
	{
		if (!_uniforms.exists(u))
		{
			_uniforms.set(u, Renderer.uniform(_program, u));
		}
		return _uniforms.get(u);
	}

	/**
	 * Bind the program for rendering
	 */
	public inline function use():Void
	{
		Renderer.bindProgram(_program);
	}

	private var _attributes:StringMap<Int>;
	private var _uniforms:StringMap<Location>;
	private var _program:ShaderProgram;

}
