package haxepunk.graphics.shaders;

#if hardware_render
import flash.gl.GL;
import flash.gl.GLProgram;
import flash.gl.GLShader;
import haxepunk.graphics.atlas.GLUtils;
import haxepunk.graphics.atlas.DrawCommand;
import haxepunk.graphics.atlas.Float32Array;

#if js
typedef GLUniformLocation = js.html.webgl.UniformLocation;
#else
typedef GLUniformLocation = Int;
#end

class Attribute
{
	public var index(default, null):Int;

	public var name(default, set):String;
	public inline function set_name(value:String):String
	{
		name = value;
		rebind(); // requires name to be set
		return name;
	}

	public var isEnabled(get, never):Bool;
	inline function get_isEnabled():Bool return name != null;

	var parent:Shader;

	public function new(parent:Shader)
	{
		this.parent = parent;
	}

	public function rebind()
	{
		if (isEnabled) index = parent.attributeIndex(name);
	}
}

class Shader
{

	public var glProgram:GLProgram;
	public var floatsPerVertex(get, never):Int;
	inline function get_floatsPerVertex():Int return 2 + (texCoord.isEnabled ? 2 : 0) + (color.isEnabled ? 4 : 0);

	var vertexSource:String;
	var fragmentSource:String;

	var position:Attribute;
	var texCoord:Attribute;
	var color:Attribute;

	var uniformIndices:Map<String, GLUniformLocation> = new Map();
	var attributeIndices:Map<String, Int> = new Map();
	var uniformNames:Array<String> = new Array();
	var uniformValues:Map<String, Float> = new Map();

	function new(vertexSource:String, fragmentSource:String)
	{
		position = new Attribute(this);
		texCoord = new Attribute(this);
		color = new Attribute(this);
		this.vertexSource = vertexSource;
		this.fragmentSource = fragmentSource;
		build();
	}

	public function build()
	{
		var vertexShader = compile(GL.VERTEX_SHADER, vertexSource);
		var fragmentShader = compile(GL.FRAGMENT_SHADER, fragmentSource);

		glProgram = GL.createProgram();
		GL.attachShader(glProgram, fragmentShader);
		GL.attachShader(glProgram, vertexShader);
		GL.linkProgram(glProgram);
		#if gl_debug
		if (GL.getProgramParameter(glProgram, GL.LINK_STATUS) == 0)
			throw "Unable to initialize the shader program.";
		#end

		position.rebind();
		texCoord.rebind();
		color.rebind();
	}

	function compile(type:Int, source:String):GLShader
	{
		var shader = GL.createShader(type);
		GL.shaderSource(shader, source);
		GL.compileShader(shader);
		#if gl_debug
		if (GL.getShaderParameter(shader, GL.COMPILE_STATUS) == 0)
			throw "Error compiling vertex shader: " + GL.getShaderInfoLog(shader);
		#end
		return shader;
	}

	public function destroy()
	{
		for (key in uniformIndices.keys()) uniformIndices.remove(key);
		for (key in attributeIndices.keys()) attributeIndices.remove(key);
	}

	public function prepare(drawCommand:DrawCommand, buffer:Float32Array)
	{
		if (!position.isEnabled) return;

		var bufferPos:Int = -1;

		var hasTexCoord = texCoord.isEnabled;
		var textureOffset = drawCommand.triangleCount * 6;
		var texturePos = textureOffset - 1;

		var hasColor = color.isEnabled;
		var colorOffset = drawCommand.triangleCount * (hasTexCoord ? 12 : 6);
		var colorPos = colorOffset - 1;

		drawCommand.loopRenderData(function(data) {
			buffer[++bufferPos] = data.tx1;
			buffer[++bufferPos] = data.ty1;
			buffer[++bufferPos] = data.tx2;
			buffer[++bufferPos] = data.ty2;
			buffer[++bufferPos] = data.tx3;
			buffer[++bufferPos] = data.ty3;

			if (hasTexCoord)
			{
				buffer[++texturePos] = data.uvx1;
				buffer[++texturePos] = data.uvy1;
				buffer[++texturePos] = data.uvx2;
				buffer[++texturePos] = data.uvy2;
				buffer[++texturePos] = data.uvx3;
				buffer[++texturePos] = data.uvy3;
			}

			if (hasColor)
			{
				buffer[++colorPos] = data.red;
				buffer[++colorPos] = data.green;
				buffer[++colorPos] = data.blue;
				buffer[++colorPos] = data.alpha;
				buffer[++colorPos] = data.red;
				buffer[++colorPos] = data.green;
				buffer[++colorPos] = data.blue;
				buffer[++colorPos] = data.alpha;
				buffer[++colorPos] = data.red;
				buffer[++colorPos] = data.green;
				buffer[++colorPos] = data.blue;
				buffer[++colorPos] = data.alpha;
			}
		});

		#if (lime >= "4.0.0")
		GL.bufferSubData(GL.ARRAY_BUFFER, 0, buffer.length * Float32Array.BYTES_PER_ELEMENT, buffer);
		#else
		GL.bufferSubData(GL.ARRAY_BUFFER, 0, buffer);
		#end

		GL.vertexAttribPointer(position.index, 2, GL.FLOAT, false, 0, 0);
		if (hasTexCoord)
		{
			GL.vertexAttribPointer(texCoord.index, 2, GL.FLOAT, false, 0, textureOffset * Float32Array.BYTES_PER_ELEMENT);
		}
		if (hasColor)
		{
			GL.vertexAttribPointer(color.index, 4, GL.FLOAT, false, 0, colorOffset * Float32Array.BYTES_PER_ELEMENT);
		}
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

		GL.enableVertexAttribArray(position.index);
		if (texCoord.isEnabled) GL.enableVertexAttribArray(texCoord.index);
		if (color.isEnabled) GL.enableVertexAttribArray(color.index);
	}

	public function unbind()
	{
		GL.useProgram(null);
		GL.disableVertexAttribArray(position.index);
		if (texCoord.isEnabled) GL.disableVertexAttribArray(texCoord.index);
		if (color.isEnabled) GL.disableVertexAttribArray(color.index);
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
