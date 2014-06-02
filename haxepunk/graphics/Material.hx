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
		if (_shader == null)
		{
			_shader = new Shader([
				{src: Assets.getText("shaders/default.vert"), fragment:false},
				{src: Assets.getText("shaders/default.frag"), fragment:true}
			]);
		}
		else
		{
			_shader = shader;
		}

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

	public function use(projectionMatrix:Matrix3D, modelViewMatrix:Matrix3D)
	{
		_shader.use();

		// assign any textures
		for (i in 0..._textures.length)
		{
			GL.activeTexture(GL.TEXTURE0 + i);
			_textures[i].bind();
		}

		// assign the projection and modelview matrices
		GL.uniformMatrix3D(_projectionMatrixUniform, false, projectionMatrix);
		GL.uniformMatrix3D(_modelViewMatrixUniform, false, modelViewMatrix);

		// set the vertices as the first 3 floats in a buffer
		GL.vertexAttribPointer(_vertexAttribute, 3, GL.FLOAT, false, 32, 0);
		GL.enableVertexAttribArray(_vertexAttribute);

		// set the tex coords as the next 2 floats in a buffer
		GL.vertexAttribPointer(_texCoordAttribute, 2, GL.FLOAT, false, 32, 12);
		GL.enableVertexAttribArray(_texCoordAttribute);

		// set the normals as the last 3 floats in a buffer
		GL.vertexAttribPointer(_normalAttribute, 3, GL.FLOAT, true, 32, 20);
		GL.enableVertexAttribArray(_normalAttribute);
	}

	public function disable()
	{
		GL.disableVertexAttribArray(_vertexAttribute);
		GL.disableVertexAttribArray(_texCoordAttribute);

		GL.disable(GL.TEXTURE_2D);
		GL.bindTexture(GL.TEXTURE_2D, null);

		GL.useProgram(null);
	}

	private var _textures:Array<Texture>;
	private var _shader:Shader;

	private var _modelViewMatrixUniform:GLUniformLocation;
	private var _projectionMatrixUniform:GLUniformLocation;

	private var _texCoordAttribute:Int;
	private var _vertexAttribute:Int;
	private var _normalAttribute:Int;

}
