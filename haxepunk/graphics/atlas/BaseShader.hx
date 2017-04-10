package haxepunk.graphics.atlas;

#if hardware_render
import openfl.gl.GL;
import openfl.gl.GLProgram;

#if js
typedef GLUniformLocation = js.html.webgl.UniformLocation;
#else
typedef GLUniformLocation = Int;
#end

class BaseShader
{
	public var glProgram:GLProgram;
	public var bufferChunkSize:Int = 0;

	var vertexSource:String;
	var fragmentSource:String;

	var uniformIndices:Map<String, GLUniformLocation> = new Map();
	var attributeIndices:Map<String, Int> = new Map();
	var uniformNames:Array<String> = new Array();
	var uniformValues:Map<String, Float> = new Map();

	function new(vertexSource:String, fragmentSource:String)
	{
		this.vertexSource = vertexSource;
		this.fragmentSource = fragmentSource;
		build();
	}

	public function build()
	{
		var vertexShader = GL.createShader(GL.VERTEX_SHADER);
		GL.shaderSource(vertexShader, vertexSource);
		GL.compileShader(vertexShader);
		#if gl_debug
		if (GL.getShaderParameter(vertexShader, GL.COMPILE_STATUS) == 0)
			throw "Error compiling vertex shader: " +
			GL.getShaderInfoLog(vertexShader);
		#end

		var fragmentShader = GL.createShader(GL.FRAGMENT_SHADER);
		GL.shaderSource(fragmentShader, fragmentSource);
		GL.compileShader(fragmentShader);
		#if gl_debug
		if (GL.getShaderParameter(fragmentShader, GL.COMPILE_STATUS) == 0)
			throw "Error compiling fragment shader: " +
			GL.getShaderInfoLog(fragmentShader);
		#end

		glProgram = GL.createProgram();
		GL.attachShader(glProgram, fragmentShader);
		GL.attachShader(glProgram, vertexShader);
		GL.linkProgram(glProgram);
		#if gl_debug
		if (GL.getProgramParameter(glProgram, GL.LINK_STATUS) == 0)
			throw "Unable to initialize the shader program.";
		#end
	}

	public function destroy()
	{
		for (key in uniformIndices.keys()) uniformIndices.remove(key);
		for (key in attributeIndices.keys()) attributeIndices.remove(key);
	}

	public function bind()
	{
		if (GLUtils.invalid(glProgram))
		{
			destroy();
			build();
		}

		GL.useProgram(glProgram);

		for (name in uniformNames)
		{
			GL.uniform1f(uniformIndex(name), uniformValues[name]);
		}
	}

	public function unbind()
	{
		GL.useProgram(null);
	}

	/**
	 * Returns the index of a named shader attribute.
	 */
	public inline function attributeIndex(name:String):Int
	{
		if (!attributeIndices.exists(name))
		{
			attributeIndices[name] = GL.getAttribLocation(glProgram, name);
		}
		return attributeIndices[name];
	}

	/**
	 * Returns the index of a named shader uniform.
	 */
	public inline function uniformIndex(name:String):GLUniformLocation
	{
		if (!uniformIndices.exists(name))
		{
			uniformIndices[name] = GL.getUniformLocation(glProgram, name);
		}
		return uniformIndices[name];
	}

	/**
	 * Set or change the value of a named shader uniform.
	 */
	public inline function setUniform(name:String, value:Float)
	{
		if (!uniformValues.exists(name))
		{
			uniformNames.push(name);
		}
		uniformValues[name] = value;
	}
}
#end
