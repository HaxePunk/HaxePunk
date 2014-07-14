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

	private static var _defaultShader(get, null):Shader;
	private static inline function get__defaultShader():Shader {
		if (_defaultShader == null)
		{
			#if flash
			var vert = "m44 op, va0, vc0\nmov v0, va1";
			var frag = "tex oc, v0, fs0 <linear nomip 2d wrap>";
			#else
			var vert = Assets.getText("shaders/default.vert");
			var frag = Assets.getText("shaders/default.frag");
			#end
			_defaultShader = new Shader(vert, frag);
		}
		return _defaultShader;
	}

	private var _modelViewMatrixUniform:Location;
	private var _projectionMatrixUniform:Location;

	private var _textures:Array<Texture>;

}
