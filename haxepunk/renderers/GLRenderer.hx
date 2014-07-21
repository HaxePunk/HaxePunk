package haxepunk.renderers;

#if !flash

import haxepunk.graphics.Color;
import haxepunk.math.Matrix4;
import haxepunk.renderers.Renderer;
import lime.graphics.*;
import lime.utils.*;

class GLRenderer
{

	public static inline var MAX_BUFFER_SIZE:Int = 65535;

	public static inline function clear(color:Color):Void
	{
		GL.clearColor(color.r, color.g, color.b, color.a);
		GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
	}

	public static inline function setViewport(x:Int, y:Int, width:Int, height:Int):Void
	{
		GL.viewport(x, y, width, height);
	}

	public static inline function present():Void
	{
		#if js
		GL.finish();
		#end
	}

	public static inline function setBlendMode(source:BlendFactor, destination:BlendFactor):Void
	{
		if (_activeState.blendSource == source && _activeState.blendDestination == destination) return;

		if (source == ONE && destination == ZERO)
		{
			GL.disable(GL.BLEND);
		}
		else
		{
			GL.blendFunc(BLEND[source], BLEND[destination]);
			GL.enable(GL.BLEND);
		}

		_activeState.blendSource = source;
		_activeState.blendDestination = destination;
	}

	public static inline function setCullMode(mode:CullMode):Void
	{
		if (mode == NONE)
		{
			GL.disable(GL.CULL_FACE);
		}
		else
		{
			GL.enable(GL.CULL_FACE);
			GL.cullFace(CULL[mode]);
		}
	}

	public static inline function createTexture(image:Image):NativeTexture
	{
		image.forcePowerOfTwo();

		var format = image.bpp == 1 ? GL.ALPHA : GL.RGBA;
		var texture = GL.createTexture();
		GL.bindTexture(GL.TEXTURE_2D, texture);
		GL.texImage2D(GL.TEXTURE_2D, 0, format, image.width, image.height, 0, format, GL.UNSIGNED_BYTE, image.data);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);

		return texture;
	}

	public static inline function createTextureFromBytes(bytes:UInt8Array, width:Int, height:Int):NativeTexture
	{
		var texture = GL.createTexture();
		GL.bindTexture(GL.TEXTURE_2D, texture);
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, bytes);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		return texture;
	}

	public static inline function deleteTexture(texture:NativeTexture):Void
	{
		GL.deleteTexture(texture);
	}

	public static inline function bindTexture(texture:NativeTexture, sampler:Int):Void
	{
		if (_activeState.texture == texture) return;

		GL.activeTexture(GL.TEXTURE0 + sampler);
		GL.bindTexture(GL.TEXTURE_2D, texture);
		_activeState.texture = texture;
	}

	public static inline function compileShaderProgram(vertex:String, fragment:String):ShaderProgram
	{
		var program:GLProgram = GL.createProgram();

		var shader = compileShader(vertex, GL.VERTEX_SHADER);
		if (shader == null) return null;
		GL.attachShader(program, shader);
		GL.deleteShader(shader);

		var shader = compileShader(fragment, GL.FRAGMENT_SHADER);
		if (shader == null) return null;
		GL.attachShader(program, shader);
		GL.deleteShader(shader);

		GL.linkProgram(program);

		if (GL.getProgramParameter(program, GL.LINK_STATUS) == 0)
		{
			trace(GL.getProgramInfoLog(program));
			trace("VALIDATE_STATUS: " + GL.getProgramParameter(program, GL.VALIDATE_STATUS));
			trace("ERROR: " + GL.getError());
			return null;
		}

		return program;
	}

	public static inline function bindProgram(program:ShaderProgram):Void
	{
		if (_activeState.program != program)
		{
			GL.useProgram(program);
			_activeState.program = program;
		}
	}

	public static inline function setMatrix(loc:Location, matrix:Matrix4):Void
	{
		GL.uniformMatrix4fv(loc, false, matrix.native);
	}

	public static inline function setColor(loc:Location, color:Color):Void
	{
		GL.uniform4f(loc, color.r, color.g, color.b, color.a);
	}

	public static inline function setFloat(loc:Location, value:Float):Void
	{
		GL.uniform1f(loc, value);
	}

	public static inline function setAttribute(a:Int, offset:Int, num:Int):Void
	{
		GL.vertexAttribPointer(a, num, GL.FLOAT, false, _activeState.buffer.stride, offset << 2);
		GL.enableVertexAttribArray(a);
	}

	public static inline function bindBuffer(v:VertexBuffer):Void
	{
		if (_activeState.buffer == v) return;

		GL.bindBuffer(GL.ARRAY_BUFFER, v.buffer);
		_activeState.buffer = v;
	}

	public static inline function createBuffer(stride:Int):VertexBuffer
	{
		return new VertexBuffer(GL.createBuffer(), stride << 2);
	}

	public static inline function updateBuffer(data:Float32Array, ?usage:BufferUsage):Void
	{
		GL.bufferData(GL.ARRAY_BUFFER, data, usage == DYNAMIC_DRAW ? GL.DYNAMIC_DRAW : GL.STATIC_DRAW);
	}

	public static inline function updateIndexBuffer(data:Int16Array, ?usage:BufferUsage, ?buffer:IndexBuffer):IndexBuffer
	{
		if (buffer == null) buffer = GL.createBuffer();
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, buffer);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, data, usage == DYNAMIC_DRAW ? GL.DYNAMIC_DRAW : GL.STATIC_DRAW);
		_activeState.indexBuffer = buffer;
		return buffer;
	}

	public static inline function draw(buffer:IndexBuffer, numTriangles:Int, offset:Int=0):Void
	{
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, buffer);
		GL.drawElements(GL.TRIANGLES, numTriangles * 3, GL.UNSIGNED_SHORT, offset << 2);
	}

	/**
	 * Compiles the shader source into a GlShader object and prints any errors
	 * @param source  The shader source code
	 * @param type    The type of shader to compile (fragment, vertex)
	 */
	private static inline function compileShader(source:String, type:Int):GLShader
	{
		var shader = GL.createShader(type);
		GL.shaderSource(shader, source);
		GL.compileShader(shader);

		if (GL.getShaderParameter(shader, GL.COMPILE_STATUS) == 0)
		{
			trace(GL.getShaderInfoLog(shader));
			shader = null;
		}

		return shader;
	}

	public static inline function setDepthTest(depthMask:Bool, ?test:DepthTestCompare):Void
	{
		if (_activeState.depthTest == test) return;

		if (depthMask)
		{
			GL.enable(GL.DEPTH_TEST);
			switch (test)
			{
				case NEVER: GL.depthFunc(GL.NEVER);
				case ALWAYS: GL.depthFunc(GL.ALWAYS);
				case GREATER: GL.depthFunc(GL.GREATER);
				case GREATER_EQUAL: GL.depthFunc(GL.GEQUAL);
				case LESS: GL.depthFunc(GL.LESS);
				case LESS_EQUAL: GL.depthFunc(GL.LEQUAL);
				case EQUAL: GL.depthFunc(GL.EQUAL);
				case NOT_EQUAL: GL.depthFunc(GL.NOTEQUAL);
			}
		}
		else
		{
			GL.disable(GL.DEPTH_TEST);
		}
		_activeState.depthTest = test;
	}


	private static var _activeState:ActiveState = new ActiveState();

	private static var FORMAT = [
		GL.ALPHA,
		GL.LUMINANCE,
		GL.RGB,
		GL.RGBA
	];

	private static var BLEND = [
		GL.ZERO,
		GL.ONE,
		GL.SRC_ALPHA,
		GL.SRC_COLOR,
		GL.DST_ALPHA,
		GL.DST_COLOR,
		GL.ONE_MINUS_SRC_ALPHA,
		GL.ONE_MINUS_SRC_COLOR,
		GL.ONE_MINUS_DST_ALPHA,
		GL.ONE_MINUS_DST_COLOR
	];

	static var COMPARE = [
		GL.ALWAYS,
		GL.NEVER,
		GL.EQUAL,
		GL.NOTEQUAL,
		GL.GREATER,
		GL.GEQUAL,
		GL.LESS,
		GL.LEQUAL
	];

	static var CULL = [
		GL.NONE,
		GL.BACK,
		GL.FRONT,
		GL.FRONT_AND_BACK
	];

}

#end
