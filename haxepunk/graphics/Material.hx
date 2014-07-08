package haxepunk.graphics;

import haxepunk.math.Matrix3D;
import haxepunk.renderers.Renderer;
import lime.Assets;

class Material
{

	public function new(?shader:Shader)
	{
		_textures = new Array<Texture>();

		// set a default shader if none is given
		_shader = (shader == null ? _defaultShader : shader);

		_vertexAttribute = _shader.attribute("aVertexPosition");
		_texCoordAttribute = _shader.attribute("aTexCoord");
		_normalAttribute = _shader.attribute("aNormal");

		_projectionMatrixUniform = _shader.uniform("uProjectionMatrix");
		_modelViewMatrixUniform = _shader.uniform("uModelViewMatrix");
	}

	public function addTexture(texture:Texture, uniformName:String="uImage0")
	{
		switch (HXP.context)
		{
			case OPENGL(gl):
				// keep uniform to allow removal of textures?
				var uniform = _shader.uniform(uniformName);
				_shader.use();
				gl.uniform1i(uniform, _textures.length);
			default:
		}
		_textures.push(texture);
	}

	public function use(projectionMatrix:Matrix3D, modelViewMatrix:Matrix3D)
	{
		_shader.use();
		// assign the projection and modelview matrices
		_shader.setMatrix(_projectionMatrixUniform, projectionMatrix);
		_shader.setMatrix(_modelViewMatrixUniform, modelViewMatrix);

		// assign any textures
		for (i in 0..._textures.length)
		{
			_textures[i].bind(i);
		}

		switch (HXP.context)
		{
			case OPENGL(gl):
				// set the vertices as the first 3 floats in a buffer
				gl.vertexAttribPointer(_vertexAttribute, 3, gl.FLOAT, false, 8*4, 0);
				gl.enableVertexAttribArray(_vertexAttribute);

				// set the tex coords as the next 2 floats in a buffer
				gl.vertexAttribPointer(_texCoordAttribute, 2, gl.FLOAT, false, 8*4, 3*4);
				gl.enableVertexAttribArray(_texCoordAttribute);

				// set the normals as the last 3 floats in a buffer
				gl.vertexAttribPointer(_normalAttribute, 3, gl.FLOAT, false, 8*4, 5*4);
				gl.enableVertexAttribArray(_normalAttribute);
			default:
		}
	}

	public inline function disable()
	{
		switch (HXP.context)
		{
			case OPENGL(gl):
				gl.disableVertexAttribArray(_vertexAttribute);
				gl.disableVertexAttribArray(_texCoordAttribute);
				gl.disableVertexAttribArray(_normalAttribute);
			default:
		}
	}

	public static inline function clear()
	{
		Texture.clear();
		Shader.clear();
	}

	private var _textures:Array<Texture>;
	private var _shader:Shader;

	private static var _defaultVertexShader:String =
		#if flash
			"m44 vt0, va0, vc0 // position * projection matrix
			m44 op, vt0, vc1   // position * modelView matrix
			// dp3 vt0, va2, vc2
			mov vt1.w, va2.w
			nrm vt1.xyz, va2   // normalize normal
			mov v0, va1        // tex coord
			mov v1, vt1"
		#else
			"#ifdef GL_ES
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
			}"
		#end;
	private static var _defaultFragmentShader:String =
		#if flash
			// "tex oc, v0.xyxx, fs0 <linear mipdisable repeat 2d>"
			"tex oc, v0.xyxx, fs0 <linear nomip 2d clamp>"
		#else
			"#ifdef GL_ES
				precision mediump float;
			#endif

			varying vec2 vTexCoord;
			varying vec3 vNormal;
			varying vec4 vPosition;

			uniform sampler2D uImage0;

			void main(void)
			{
				gl_FragColor = texture2D(uImage0, vTexCoord);
			}"
		#end;
	private static var _defaultShader(get, null):Shader;
	private static inline function get__defaultShader():Shader {
		if (_defaultShader == null)
		{
			_defaultShader = new Shader(_defaultVertexShader, _defaultFragmentShader);
		}
		return _defaultShader;
	}

	private var _modelViewMatrixUniform:Location;
	private var _projectionMatrixUniform:Location;

	private var _texCoordAttribute:Int;
	private var _vertexAttribute:Int;
	private var _normalAttribute:Int;

}
