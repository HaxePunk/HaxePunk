package haxepunk.graphics.shader;

import haxepunk.graphics.hardware.opengl.GL;
import haxepunk.graphics.hardware.opengl.GLBuffer;
import haxepunk.graphics.hardware.opengl.GLUniformLocation;
import haxepunk.graphics.hardware.opengl.GLUtils;
import haxepunk.graphics.hardware.Float32Array;

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

	#if (lime || nme)
	/**
	 * Create a custom shader from a text asset.
	 */
	public static inline function fromAsset(name:String):SceneShader
	{
		return new SceneShader(flash.Assets.getText(name));
	}
	#end

	/**
	 * Create a custom shader from a string.
	 */
	public function new(fragment:String)
	{
		super(DEFAULT_VERTEX_SHADER, fragment);
		position.name = "aPosition";
		texCoord.name = "aTexCoord";
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

		GL.bindBuffer(GL.ARRAY_BUFFER, buffer);
		GL.vertexAttribPointer(position.index, 2, GL.FLOAT, false, 4 * Float32Array.BYTES_PER_ELEMENT, 0);
		GL.vertexAttribPointer(texCoord.index, 2, GL.FLOAT, false, 4 * Float32Array.BYTES_PER_ELEMENT, 2 * Float32Array.BYTES_PER_ELEMENT);

		GL.uniform1i(image, 0);
		GL.uniform2f(resolution, HXP.screen.width, HXP.screen.height);
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
