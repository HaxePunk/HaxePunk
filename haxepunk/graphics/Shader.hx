package haxepunk.graphics;

import haxepunk.renderers.Renderer;
import lime.graphics.GL;
import lime.graphics.GLUniformLocation;

typedef ShaderSource = {
	var src:String;
	var fragment:Bool;
}

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
		_program = HXP.renderer.compileShaderProgram(vertex, fragment);
	}

	/**
	 * Return the attribute location in this shader
	 * @param a  The attribute name to find
	 */
	public inline function attribute(a:String):Int
	{
		#if flash
		return switch (a)
		{
			default: -1;
		}
		#else
		return GL.getAttribLocation(_program, a);
		#end
	}

	/**
	 * Return the uniform location in this shader
	 * @param a  The uniform name to find
	 */
	public inline function uniform(u:String):GLUniformLocation
	{
		#if flash
		return switch (u)
		{
			case "uProjectionMatrix": 0;
			case "uModelViewMatrix": 1;
			default: -1;
		}
		#else
		return GL.getUniformLocation(_program, u);
		#end
	}

	/**
	 * Bind the program for rendering
	 */
	public inline function use()
	{
		if (_lastUsedProgram != _program)
		{
			HXP.renderer.bindProgram(_program);
			_lastUsedProgram = _program;
		}
	}

	public static function clear()
	{
		_lastUsedProgram = null;
		HXP.renderer.bindProgram(_lastUsedProgram);
	}

	private var _program:ShaderProgram;
	private static var _lastUsedProgram:ShaderProgram;

}
