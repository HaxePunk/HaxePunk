package haxepunk.renderers;

#if !flash

import haxepunk.graphics.Color;
import haxepunk.math.Matrix4;
import haxepunk.renderers.Renderer;
import lime.graphics.*;
import lime.utils.*;

class GLRenderer
{

	public static inline function init(gl:GLRenderContext)
	{
		GLRenderer.gl = gl;
	}

	public static inline function clear(color:Color):Void
	{
		gl.clearColor(color.r, color.g, color.b, color.a);
		gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
	}

	public static inline function setViewport(x:Int, y:Int, width:Int, height:Int):Void
	{
#if !neko
		gl.viewport(x, y, width, height);
#end
	}

	public static inline function present():Void
	{
		#if js
		gl.finish();
		#end
	}

	public static inline function setBlendMode(source:BlendFactor, destination:BlendFactor):Void
	{
		if (_activeState.blendSource == source && _activeState.blendDestination == destination) return;

		if (source == ONE && destination == ZERO)
		{
			gl.disable(gl.BLEND);
		}
		else
		{
			gl.blendFunc(BLEND[source], BLEND[destination]);
			gl.enable(gl.BLEND);
		}

		_activeState.blendSource = source;
		_activeState.blendDestination = destination;
	}

	public static inline function setCullMode(mode:CullMode):Void
	{
		if (mode == NONE)
		{
			gl.disable(gl.CULL_FACE);
		}
		else
		{
			gl.enable(gl.CULL_FACE);
			gl.cullFace(CULL[mode]);
		}
	}

	public static inline function createTexture(image:Image):NativeTexture
	{
		image.forcePowerOfTwo();

		var texture = gl.createTexture();
		gl.bindTexture(gl.TEXTURE_2D, texture);
		gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, image.width, image.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, image.data);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);

		return texture;
	}

	public static inline function deleteTexture(texture:NativeTexture):Void
	{
		gl.deleteTexture(texture);
	}

	public static inline function bindTexture(texture:NativeTexture, sampler:Int):Void
	{
		if (_activeState.texture == texture) return;

		gl.activeTexture(gl.TEXTURE0 + sampler);
		gl.bindTexture(gl.TEXTURE_2D, texture);
		_activeState.texture = texture;
	}

	public static inline function compileShaderProgram(vertex:String, fragment:String):ShaderProgram
	{
		var program:GLProgram = gl.createProgram();

		var shader = compileShader(vertex, gl.VERTEX_SHADER);
		if (shader == null) return null;
		gl.attachShader(program, shader);
		gl.deleteShader(shader);

		var shader = compileShader(fragment, gl.FRAGMENT_SHADER);
		if (shader == null) return null;
		gl.attachShader(program, shader);
		gl.deleteShader(shader);

		gl.linkProgram(program);

		if (gl.getProgramParameter(program, gl.LINK_STATUS) == 0)
		{
			trace(gl.getProgramInfoLog(program));
			trace("VALIDATE_STATUS: " + gl.getProgramParameter(program, gl.VALIDATE_STATUS));
			trace("ERROR: " + gl.getError());
			return null;
		}

		return program;
	}

	public static inline function bindProgram(program:ShaderProgram):Void
	{
		if (_activeState.program != program)
		{
			gl.useProgram(program);
			_activeState.program = program;
		}
	}

	public static inline function setMatrix(loc:Location, matrix:Matrix4):Void
	{
		gl.uniformMatrix4fv(loc, false, matrix.native);
	}

	public static inline function setAttribute(a:Int, offset:Int, num:Int, stride:Int):Void
	{
		if (_activeState.attributes.exists(a)) return;

		_activeState.attributes.set(a, true);
		gl.vertexAttribPointer(a, num, gl.FLOAT, false, stride*4, offset*4);
		gl.enableVertexAttribArray(a);
	}

	public static inline function bindBuffer(v:VertexBuffer):Void
	{
		if (_activeState.buffer == v) return;

		gl.bindBuffer(GL.ARRAY_BUFFER, v);
		_activeState.buffer = v;

		// clear active attributes
		for (key in _activeState.attributes.keys())
			_activeState.attributes.remove(key);
	}

	public static inline function createBuffer(data:Float32Array, ?usage:BufferUsage):VertexBuffer
	{
		var buffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
		gl.bufferData(gl.ARRAY_BUFFER, data, usage == DYNAMIC_DRAW ? gl.DYNAMIC_DRAW : gl.STATIC_DRAW);
		return buffer;
	}

	public static inline function createIndexBuffer(data:Int16Array, ?usage:BufferUsage):IndexBuffer
	{
		var buffer = gl.createBuffer();
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, buffer);
		gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, data, usage == DYNAMIC_DRAW ? gl.DYNAMIC_DRAW : gl.STATIC_DRAW);
		return buffer;
	}

	public static inline function draw(i:IndexBuffer, numTriangles:Int, offset:Int=0):Void
	{
		gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, i);
		gl.drawElements(GL.TRIANGLES, numTriangles * 3, GL.UNSIGNED_SHORT, offset << 2);
	}

	/**
	 * Compiles the shader source into a GlShader object and prints any errors
	 * @param source  The shader source code
	 * @param type    The type of shader to compile (fragment, vertex)
	 */
	private static inline function compileShader(source:String, type:Int):GLShader
	{
		var shader = gl.createShader(type);
		gl.shaderSource(shader, source);
		gl.compileShader(shader);

		if (gl.getShaderParameter(shader, gl.COMPILE_STATUS) == 0)
		{
			trace(gl.getShaderInfoLog(shader));
			shader = null;
		}

		return shader;
	}

	public static inline function setDepthTest(depthMask:Bool, ?test:DepthTestCompare):Void
	{
		if (_activeState.depthTest == test) return;

		if (depthMask)
		{
			gl.enable(gl.DEPTH_TEST);
			switch (test)
			{
				case NEVER: gl.depthFunc(gl.NEVER);
				case ALWAYS: gl.depthFunc(gl.ALWAYS);
				case GREATER: gl.depthFunc(gl.GREATER);
				case GREATER_EQUAL: gl.depthFunc(gl.GEQUAL);
				case LESS: gl.depthFunc(gl.LESS);
				case LESS_EQUAL: gl.depthFunc(gl.LEQUAL);
				case EQUAL: gl.depthFunc(gl.EQUAL);
				case NOT_EQUAL: gl.depthFunc(gl.NOTEQUAL);
			}
		}
		else
		{
			gl.disable(gl.DEPTH_TEST);
		}
		_activeState.depthTest = test;
	}


	private static var gl:GLRenderContext;
	private static var _activeState:ActiveState = new ActiveState();

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
