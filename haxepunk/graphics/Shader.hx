package haxepunk.graphics;

import haxe.ds.StringMap;
import haxepunk.renderers.Renderer;
import haxepunk.math.Matrix4;
import lime.graphics.GL;

/**
 * GLSL Shader object
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
	 */
	public inline function attribute(a:String):Int
	{
		var attribute:Int;
		if (_attributes.exists(a))
		{
			attribute = _attributes.get(a);
		}
		else
		{
			#if (flash || (js && canvas))
			attribute = _attributeId++;
			#else
			attribute = GL.getAttribLocation(_program, a);
			#end
			_attributes.set(a, attribute);
		}
		return attribute;
	}

	/**
	 * Return the uniform location in this shader
	 * @param a  The uniform name to find
	 */
	public inline function uniform(u:String):Location
	{
		var uniform:Location;
		if (_uniforms.exists(u))
		{
			uniform = _uniforms.get(u);
		}
		else
		{
			#if (flash || (js && canvas))
			uniform = _uniformId++;
			#else
			uniform = GL.getUniformLocation(_program, u);
			#end
			_uniforms.set(u, uniform);
		}
		return uniform;
	}

	/**
	 * Bind the program for rendering
	 */
	public inline function use()
	{
		Renderer.bindProgram(_program);
	}

	private var _attributes:StringMap<Int>;
	private var _attributeId:Int = 0;
	private var _uniforms:StringMap<Location>;
	private var _uniformId:Int = 0;
	private var _program:ShaderProgram;

}
