package haxepunk.graphics;

import lime.gl.GL;
import lime.gl.GLUniformLocation;
import lime.utils.Assets;
import lime.utils.Matrix3D;

class Material
{

	public function new(?shader:Shader)
	{
		_textures = new Array<Texture>();

		// set a default shader if none is given
		if (shader == null)
		{
			_shader = new Shader([
				{src: Assets.getText("shaders/default.vert"), fragment:false},
				{src: Assets.getText("shaders/default.frag"), fragment:true}
			]);
		}
		else
		{
			_shader = shader;
			trace("custom shader");
		}

		_vertexAttribute = _shader.attribute("aVertexPosition");
		_texCoordAttribute = _shader.attribute("aTexCoord");
		_normalAttribute = _shader.attribute("aNormal");

		_projectionMatrixUniform = _shader.uniform("uProjectionMatrix");
		_modelViewMatrixUniform = _shader.uniform("uModelViewMatrix");
		_normalMatrixUniform = _shader.uniform("uNormalMatrix");

		_normalMatrix = new Matrix3D();
		_modelViewMatrix = new Matrix3D();
	}

	public function addTexture(texture:Texture, uniformName:String="uImage0")
	{
		// keep uniform to allow removal of textures?
		var uniform = _shader.uniform(uniformName);
		_shader.use();
		GL.uniform1i(uniform, _textures.length);
		_textures.push(texture);
	}

	public function use(projectionMatrix:Matrix3D, modelViewMatrix:Matrix3D)
	{
		_shader.use();

		// assign any textures
		for (i in 0..._textures.length)
		{
			GL.activeTexture(GL.TEXTURE0 + i);
			_textures[i].bind();
		}

		// calculate the normal matrix, if the model changed since last calculation
		if (_normalMatrixUniform != -1)
		{
			if (modelViewMatrix.rawData != _modelViewMatrix.rawData)
			{
				_normalMatrix.rawData = modelViewMatrix.rawData.copy();
				_normalMatrix.invert();
				_normalMatrix.transpose();

				_modelViewMatrix.rawData = modelViewMatrix.rawData.copy();
			}
			
			GL.uniformMatrix3D(_normalMatrixUniform, false, _normalMatrix);
		}

		// assign the projection and modelview matrices
		GL.uniformMatrix3D(_projectionMatrixUniform, false, projectionMatrix);
		GL.uniformMatrix3D(_modelViewMatrixUniform, false, modelViewMatrix);

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

	public function disable()
	{
		GL.disableVertexAttribArray(_vertexAttribute);
		GL.disableVertexAttribArray(_texCoordAttribute);
		GL.disableVertexAttribArray(_normalAttribute);

		GL.bindTexture(GL.TEXTURE_2D, null);

		GL.useProgram(null);
	}

	private var _textures:Array<Texture>;
	private var _shader:Shader;

	private var _modelViewMatrixUniform:GLUniformLocation;
	private var _projectionMatrixUniform:GLUniformLocation;
	private var _normalMatrixUniform:GLUniformLocation;

	private var _texCoordAttribute:Int;
	private var _vertexAttribute:Int;
	private var _normalAttribute:Int;

	private var _normalMatrix:Matrix3D;
	private var _modelViewMatrix:Matrix3D;
}
