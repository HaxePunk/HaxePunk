package haxepunk.graphics;

import haxepunk.math.Matrix4;
import haxepunk.renderers.Renderer;
import lime.Assets;

class Material
{

	public var shader(default, null):Shader;

	public function new(?shader:Shader)
	{
		_textures = new Array<Texture>();

		// set a default shader if none is given
		this.shader = (shader == null ? _defaultShader : shader);

		_modelViewMatrixUniform = this.shader.uniform("uMatrix");
	}

	public function addTexture(texture:Texture, uniformName:String="uImage0")
	{
		// keep uniform to allow removal of textures?
		// var uniform = shader.uniform(uniformName);
		// shader.use();
		_textures.push(texture);
	}

	public function use()
	{
		shader.use();

		// assign any textures
		for (i in 0..._textures.length)
		{
			_textures[i].bind(i);
		}
	}

	public inline function disable()
	{
	}

	private static var _defaultVertexShader:String =
		#if flash
			"m44 op, va0, vc0 // position * matrix
			mov v0, va1       // tex coord"
		#else
			"#ifdef GL_ES
				precision mediump float;
			#endif

			attribute vec3 aVertexPosition;
			attribute vec2 aTexCoord;

			varying vec2 vTexCoord;
			varying vec4 vPosition;

			uniform mat4 uMatrix;

			void main(void)
			{
				vTexCoord = aTexCoord;
				gl_Position = uMatrix * vec4(aVertexPosition, 1.0);
			}"
		#end;
	private static var _defaultFragmentShader:String =
		#if flash
			"tex oc, v0, fs0 <linear nomip 2d wrap>"
		#else
			"#ifdef GL_ES
				precision mediump float;
			#endif

			varying vec2 vTexCoord;
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

	private var _textures:Array<Texture>;

}
