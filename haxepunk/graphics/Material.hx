package haxepunk.graphics;

import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLUniformLocation;
import lime.Assets;
import lime.utils.Float32Array;
import haxepunk.math.Matrix3D;

class Material
{

	public function new(?shader:Shader)
	{
		_textures = new Array<Texture>();

		// set a default shader if none is given
		_shader = (shader == null) ? _defaultShader : shader;

		_vertexAttribute = _shader.attribute("aVertexPosition");
		_texCoordAttribute = _shader.attribute("aTexCoord");
		_normalAttribute = _shader.attribute("aNormal");

		_projectionMatrixUniform = _shader.uniform("uProjectionMatrix");
		_modelViewMatrixUniform = _shader.uniform("uModelViewMatrix");
	}

	public function addTexture(texture:Texture, uniformName:String="uImage0")
	{
		// keep uniform to allow removal of textures?
		var uniform = _shader.uniform(uniformName);
		_shader.use();
		GL.uniform1i(uniform, _textures.length);
		_textures.push(texture);
	}

	public function use(projectionMatrix:Float32Array, modelViewMatrix:Matrix3D)
	{
		_shader.use();

		// assign any textures
		for (i in 0..._textures.length)
		{
			GL.activeTexture(GL.TEXTURE0 + i);
			_textures[i].bind();
		}

		// assign the projection and modelview matrices
		GL.uniformMatrix4fv(_projectionMatrixUniform, false, projectionMatrix);
		GL.uniformMatrix4fv(_modelViewMatrixUniform, false, modelViewMatrix.float32Array);

		// set the vertices as the first 3 floats in a buffer
		GL.vertexAttribPointer(_vertexAttribute, 3, GL.FLOAT, false, 8*4, 0);
		GL.enableVertexAttribArray(_vertexAttribute);

		// set the tex coords as the next 2 floats in a buffer
		GL.vertexAttribPointer(_texCoordAttribute, 2, GL.FLOAT, false, 8*4, 3*4);
		GL.enableVertexAttribArray(_texCoordAttribute);

		// set the normals as the last 3 floats in a buffer
		GL.vertexAttribPointer(_normalAttribute, 3, GL.FLOAT, false, 8*4, 5*4);
		GL.enableVertexAttribArray(_normalAttribute);
	}

	public inline function disable()
	{
		GL.disableVertexAttribArray(_vertexAttribute);
		GL.disableVertexAttribArray(_texCoordAttribute);
		GL.disableVertexAttribArray(_normalAttribute);
	}

	public static inline function clear()
	{
		Texture.clear();
		Shader.clear();
	}

	private var _textures:Array<Texture>;
	private var _shader:Shader;

	private static var _defaultVertexShader:String = "
#ifdef GL_ES
	precision mediump float;
#endif

attribute vec3 aVertexPosition;
attribute vec2 aTexCoord;
attribute vec3 aNormal;

varying vec2 vTexCoord;
varying vec3 vNormal;
varying vec4 vPosition;

uniform mat4 uModelViewMatrix;
uniform mat4 uProjectionMatrix;

void main(void)
{
	vPosition = uModelViewMatrix * vec4(aVertexPosition, 1.0);
	vNormal = normalize(aNormal);
	vTexCoord = aTexCoord;
	gl_Position = uProjectionMatrix * vPosition;
}";
	private static var _defaultFragmentShader:String = "
#ifdef GL_ES
	precision mediump float;
#endif

varying vec2 vTexCoord;
varying vec3 vNormal;
varying vec4 vPosition;

uniform sampler2D uImage0;

void main(void)
{
	gl_FragColor = texture2D(uImage0, vTexCoord);
}
";
	private static var _defaultShader(get, null):Shader;
	private static inline function get__defaultShader():Shader {
		if (_defaultShader == null)
		{
			_defaultShader = new Shader([
				{src: _defaultVertexShader, fragment:false},
				{src: _defaultFragmentShader, fragment:true}
			]);
		}
		return _defaultShader;
	}

	private var _modelViewMatrixUniform:GLUniformLocation;
	private var _projectionMatrixUniform:GLUniformLocation;

	private var _texCoordAttribute:Int;
	private var _vertexAttribute:Int;
	private var _normalAttribute:Int;

}
