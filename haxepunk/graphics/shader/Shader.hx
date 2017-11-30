package haxepunk.graphics.shader;

import haxepunk.graphics.hardware.opengl.GL;
import haxepunk.graphics.hardware.opengl.GLProgram;
import haxepunk.graphics.hardware.opengl.GLShader;
import haxepunk.graphics.hardware.opengl.GLUniformLocation;
import haxepunk.graphics.hardware.opengl.GLUtils;
import haxepunk.graphics.hardware.DrawCommand;
import haxepunk.graphics.hardware.Float32Array;
import haxepunk.graphics.hardware.RenderBuffer;

class Attribute
{
	public var index(default, null):Int = -1;
	public var data(default, set):Array<Float>;
	private function set_data(v:Array<Float>) : Array<Float>
	{
		dataPos = -1;
		return data = v;
	}
	public var valuesPerElement:Int;

	@:allow(haxepunk.graphics.hardware.RenderBuffer)
	private var dataPos(default, set):Int = -1; // for use by RenderBuffer to push data in VBOs
	private function set_dataPos(v:Int) : Int
	{
		return dataPos = v > -1 && data != null ? v % data.length : v;
	}

	public var name(default, set):String;
	public inline function set_name(value:String):String
	{
		name = value;
		rebind(); // requires name to be set
		if (index == -1)
			trace("Warning : attribute '" + name + "' is not declared or not used in shader source.");
		return name;
	}

	public var isEnabled(get, null):Bool;
	private function get_isEnabled() : Bool return name != null && index != -1;

	var parent:Shader;

	public function new(parent:Shader)
	{
		this.parent = parent;
	}

	public function rebind()
	{
		if (name != null) index = parent.attributeIndex(name);
		dataPos = -1;
	}
}

class Shader
{
	public var glProgram:GLProgram;
	public var floatsPerVertex(get, never):Int;
	function get_floatsPerVertex():Int
	{
		var a = 2 + (texCoord.isEnabled ? 2 : 0) + (color.isEnabled ? 1 : 0);
		for (v in attributes.iterator())
			if (v.isEnabled)
				a += v.valuesPerElement;
		return a;
	}

	public var vertexSource:String;
	var fragmentSource:String;

	public var id(default, null):Int;
	static var idSeq:Int = 0;

	public var position:Attribute;
	public var texCoord:Attribute;
	public var color:Attribute;

	var attributeNames:Array<String> = new Array();
	var attributes:Map<String, Attribute> = new Map();
	var uniformIndices:Map<String, GLUniformLocation> = new Map();
	var uniformNames:Array<String> = new Array();
	var uniformValues:Map<String, Float> = new Map();

	public function new(vertexSource:String, fragmentSource:String)
	{
		position = new Attribute(this);
		texCoord = new Attribute(this);
		color = new Attribute(this);
		this.vertexSource = vertexSource;
		this.fragmentSource = fragmentSource;
#if !unit_test
		build();
#end

		id = idSeq++;
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
		for (v in attributes.iterator())
			v.rebind();
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
		for (key in attributes.keys()) attributes.remove(key);
	}

	public function prepare(drawCommand:DrawCommand, buffer:RenderBuffer)
	{
		if (!position.isEnabled) return;
		var attribs = attributeNames.map(function(n) return attributes[n]).filter(function (a) return a.isEnabled);

		buffer.use();
		if (texCoord.isEnabled)
		{
			if (color.isEnabled)
			{
				buffer.prepareVertexUVandColor(drawCommand);
			}
			else
			{
				buffer.prepareVertexAndUV(drawCommand);
			}
		}
		else if (color.isEnabled)
		{
			buffer.prepareVertexAndColor(drawCommand);
		}
		else
		{
			buffer.prepareVertexOnly(drawCommand);
		}

		buffer.addVertexAttribData(attribs, drawCommand.triangleCount * 3);

		buffer.updateGraphicsCard();

		setAttributePointers(drawCommand.triangleCount);
	}

	function setAttributePointers(nbTriangles:Int)
	{
		var offset:Int = 0;
		// var stride:Int = floatsPerVertex * Float32Array.BYTES_PER_ELEMENT;
		var stride:Int = (2 + (texCoord.isEnabled ? 2 : 0) + (color.isEnabled ? 1 : 0)) * Float32Array.BYTES_PER_ELEMENT;
		GL.vertexAttribPointer(position.index, 2, GL.FLOAT, false, stride, offset);
		offset += 2 * Float32Array.BYTES_PER_ELEMENT;

		if (texCoord.isEnabled)
		{
			GL.vertexAttribPointer(texCoord.index, 2, GL.FLOAT, false, stride, offset);
			offset += 2 * Float32Array.BYTES_PER_ELEMENT;
		}

		if (color.isEnabled)
		{
			GL.vertexAttribPointer(color.index, 4, GL.UNSIGNED_BYTE, true, stride, offset);
			offset += 1 * Float32Array.BYTES_PER_ELEMENT;
		}

		// Custom vertex attrib data is at the end of the buffer to speed up construction.

		offset *= nbTriangles * 3;

		// Use an array of names to preserve order, since the order of keys in a Map is undefined
		for (n in attributeNames)
		{
			var attrib = attributes[n];
			if (attrib.isEnabled)
			{
				GL.vertexAttribPointer(attrib.index, attrib.valuesPerElement, GL.FLOAT, false, 0, offset);
				offset += nbTriangles * 3 * attrib.valuesPerElement * Float32Array.BYTES_PER_ELEMENT;
			}
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
		for (n in attributeNames)
			if (attributes[n].isEnabled)
				GL.enableVertexAttribArray(attributes[n].index);

		GLUtils.checkForErrors();
	}

	public function unbind()
	{
		GL.useProgram(null);
		GL.disableVertexAttribArray(position.index);
		if (texCoord.isEnabled) GL.disableVertexAttribArray(texCoord.index);
		if (color.isEnabled) GL.disableVertexAttribArray(color.index);
		for (n in attributeNames)
			if (attributes[n].isEnabled)
				GL.disableVertexAttribArray(attributes[n].index);
	}

	/**
	 * Returns the index of a named shader attribute.
	 */
	public inline function attributeIndex(name:String):Int
	{
#if unit_test
		return 0;
#else
		return GL.getAttribLocation(glProgram, name);
#end
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

	/**
	 * Set or change the values of a named vertex attribute.
	 */
	public function setVertexAttribData(name:String, values:Array<Float>, valuesPerElement:Int)
	{
		var attrib:Attribute;
		if (!attributes.exists(name))
		{
			attrib = new Attribute(this);
			attrib.name = name;
			attributes[name] = attrib;
			attributeNames.push(name);
		}
		else
			attrib = attributes[name];
		attrib.data = values;
		attrib.valuesPerElement = valuesPerElement;
	}

	/**
	 * Add extra values to a named vertex attribute.
	 */
	public function appendVertexAttribData(name:String, values:Array<Float>)
	{
		var attrib:Attribute;
		if (!attributes.exists(name))
			throw "appendVertexAttribData : attribute '" + name + "' was not declared";
		else
			attrib = attributes[name];
		if (values.length % attrib.valuesPerElement != 0)
			throw "appendVertexAttribData : values per element do not match";
		attrib.data = attrib.data.concat(values);
	}
}
