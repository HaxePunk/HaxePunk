package haxepunk.graphics.shaders;

import flash.Assets;
import flash.gl.GL;
import flash.gl.GLBuffer;
import flash.gl.GLUniformLocation;
import haxepunk.graphics.atlas.Float32Array;
import haxepunk.graphics.atlas.GLUtils;

/**
 * Used to create a custom shader.
 */
class SceneShader extends Shader
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
	public static inline function fromAsset(name:String):SceneShader
	{
		return new SceneShader(Assets.getText(name));
	}

	/**
	 * Create a custom shader from a string.
	 */
	public function new(fragmentSource:String)
	{
		super(DEFAULT_VERTEX_SHADER, fragmentSource);
	}

	function createBuffer()
	{
		buffer = GL.createBuffer();
		GL.bindBuffer(GL.ARRAY_BUFFER, buffer);
		var v = new Float32Array(_vertices);
		#if (lime >= "4.0.0")
		GL.bufferData(GL.ARRAY_BUFFER, v.length * Float32Array.BYTES_PER_ELEMENT, v, GL.STATIC_DRAW);
		#else
		GL.bufferData(GL.ARRAY_BUFFER, v, GL.STATIC_DRAW);
		#end
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
	}

	override public function build()
	{
		super.build();
		position = attributeIndex("aPosition");
		texCoord = attributeIndex("aTexCoord");
		image = uniformIndex("uImage0");
		resolution = uniformIndex("uResolution");
	}

	override public function bind()
	{
		super.bind();
		if (GLUtils.invalid(buffer))
		{
			createBuffer();
		}
		GL.enableVertexAttribArray(position);
		GL.enableVertexAttribArray(texCoord);

		GL.bindBuffer(GL.ARRAY_BUFFER, buffer);
		GL.vertexAttribPointer(position, 2, GL.FLOAT, false, 4 * Float32Array.BYTES_PER_ELEMENT, 0);
		GL.vertexAttribPointer(texCoord, 2, GL.FLOAT, false, 4 * Float32Array.BYTES_PER_ELEMENT, 2 * Float32Array.BYTES_PER_ELEMENT);

		GL.uniform1i(image, 0);
		GL.uniform2f(resolution, HXP.screen.width, HXP.screen.height);
	}

	override public function unbind()
	{
		GL.disableVertexAttribArray(position);
		GL.disableVertexAttribArray(texCoord);
		super.unbind();
	}

	static var _vertices:Array<Float> = [
		-1.0, -1.0, 0, 0,
		1.0, -1.0, 1, 0,
		-1.0,  1.0, 0, 1,
		1.0, -1.0, 1, 0,
		1.0,  1.0, 1, 1,
		-1.0,  1.0, 0, 1
	];

	var image:GLUniformLocation;
	var resolution:GLUniformLocation;
	static var buffer:GLBuffer;
}
