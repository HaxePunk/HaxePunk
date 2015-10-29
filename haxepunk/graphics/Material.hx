package haxepunk.graphics;

import haxepunk.math.Matrix4;
import haxepunk.renderers.Renderer;

using StringTools;

class Pass
{
	public var shader(default, set):Shader;
	public var ambient:Color;
	public var diffuse:Color;
	public var specular:Color;
	public var emissive:Color;
	public var shininess:Float = 0;
	public var depthCheck:Bool = false;

	public function new()
	{
		ambient = new Color(0, 0, 0, 1);
		diffuse = new Color(1, 1, 1, 1);
		specular = new Color(0, 0, 0, 0);
		emissive = new Color(0, 0, 0, 0);

#if !unit_test
		shader = _defaultShader;
#end

		_textures = new Array<Texture>();
	}

	private function set_shader(value:Shader):Shader
	{
		// must grab the matrix uniform first to set it as 0
		value.uniform("uMatrix");

		_ambientLocation = value.uniform("uAmbientColor");
		_diffuseLocation = value.uniform("uDiffuseColor");
		_specularLocation = value.uniform("uSpecularColor");
		_emissiveLocation = value.uniform("uEmissiveColor");
		_shininessLocation = value.uniform("uShininess");
		return shader = value;
	}

	public function removeTexture(texture:Texture)
	{
		_textures.remove(texture);
	}

	public function addTexture(texture:Texture, uniformName:String="uImage0")
	{
		// keep uniform to allow removal of textures?
		// var uniform = shader.uniform(uniformName);
		// shader.use();
		_textures.push(texture);
	}

	public function getTexture(index:Int):Texture
	{
		if (index < 0 || index >= _textures.length) return null;
		return _textures[index];
	}

	public function use()
	{
		shader.use();
		Renderer.setColor(_ambientLocation, ambient);
		Renderer.setColor(_diffuseLocation, diffuse);
		Renderer.setColor(_specularLocation, specular);
		Renderer.setColor(_emissiveLocation, emissive);
		Renderer.setFloat(_shininessLocation, shininess);

		Renderer.setDepthTest(depthCheck, LESS_EQUAL);
		Renderer.setBlendMode(SOURCE_ALPHA, ONE_MINUS_SOURCE_ALPHA);

		// assign any textures
		for (i in 0..._textures.length)
		{
			_textures[i].bind(i);
		}
	}

	private static var _defaultShader(get, null):Shader;
	private static inline function get__defaultShader():Shader {
		if (_defaultShader == null)
		{
			#if flash
			var vert = "m44 op, va0, vc0\nmov v0, va1";
			var frag = "tex oc, v0, fs0 <linear nomip 2d wrap>";
			#else
			var vert = Assets.getText("hxp/shaders/default.vert");
			var frag = Assets.getText("hxp/shaders/default.frag");
			#end
			_defaultShader = new Shader(vert, frag);
		}
		return _defaultShader;
	}

	private var _textures:Array<Texture>;
	private var _ambientLocation:Location;
	private var _diffuseLocation:Location;
	private var _specularLocation:Location;
	private var _emissiveLocation:Location;
	private var _shininessLocation:Location;

}

/**
 * Contains passes for rendering graphics.
 */
class Material
{

	/**
	 * The material name.
	 */
	public var name:String;
	/**
	 * A list of the material's passes.
	 */
	public var passes:List<Pass>;

	public function new()
	{
		passes = new List<Pass>();
	}

	/**
	 * Generate a material from data
	 * @param text the material data to use
	 */
	public static function fromText(text:String):Material
	{
		var data = new MaterialData(text);
		return data.materials[0];
	}

	/**
	 * Generate a material from an asset string
	 * @id the asset id
	 */
	public static inline function fromAsset(id:String):Material
	{
		return fromText(Assets.getText(id));
	}

	/**
	 * Gets or creates the first pass object of the Material
	 */
	public var firstPass(get, never):Pass;
	private inline function get_firstPass():Pass
	{
		if (passes.length < 1) passes.add(new Pass());
		return passes.first();
	}

}

#if !unit_test private #end class MaterialData
{

	public var materials:Array<Material>;

	public function new(text:String)
	{
		_text = text;

		materials = new Array<Material>();
		materials.push(material());
	}

	private function scan():String
	{
		if (_next == null)
		{
			_next = next();
		}
		return _next;
	}

	private function next():String
	{
		var buffer:String;
		if (_next == null)
		{
			buffer = "";
			var inComment = false;
			while (_index++ < _text.length)
			{
				var c = _text.charAt(_index-1);
				if (c == '\n' || c == '\r')
				{
					if (buffer != "") return buffer;
					inComment = false;
					continue;
				}
				if (c == '/' && _text.charAt(_index) == '/')
				{
					inComment = true;
				}
				if (inComment) continue;

				if (c == ' ' || c == '\t')
				{
					if (buffer != "") return buffer;
					continue;
				}
				buffer += c;
			}
		}
		else
		{
			buffer = _next;
			_next = null;
		}
		return buffer;
	}

	private function material():Material
	{
		expected("material");
		var material = new Material();
		material.name = next();
		expected("{");
		while (scan() == "technique")
		{
			// TODO: check if technique fails and load fallback instead of loading all passes
			for (pass in technique(material))
			{
				material.passes.add(pass);
			}
		}
		expected("}");
		return material;
	}

	private function float():Float
	{
		var next = next();
		var value = Std.parseFloat(next);
		if (Math.isNaN(value)) throw 'Expected numeric value got "$next"';
		return value;
	}

	private function bool():Bool
	{
		var next = next();
		return next == "true" ? true : next == "false" ? false : throw 'Expected boolean value got "$next"';
	}

	private function color(color:Color):Void
	{
		next();
		color.r = float();
		color.g = float();
		color.b = float();
	}

	private function pass():Pass
	{
		expected("pass");
		expected("{");
		var pass = new Pass();
		while (true)
		{
			switch (scan())
			{
				case "ambient":
					color(pass.ambient);
				case "diffuse":
					color(pass.diffuse);
				case "specular":
					color(pass.specular);
				case "emissive":
					color(pass.emissive);
				case "program":
					expected("program");
					pass.shader = new Shader(Assets.getText(next()), Assets.getText(next()));
				case "depth_check":
					expected("depth_check");
					pass.depthCheck = bool();
				case "texture_unit":
					textureUnit();
				default:
					break;
			}
		}
		expected("}");
		return pass;
	}

	private function textureUnit()
	{
		expected("texture_unit");
		expected("{");
		texture();
		expected("}");
	}

	private function texture()
	{
		expected("texture");
		var texture = next();
		if (Assets.exists(texture))
		{
			// addTexture(Texture.fromAsset(texture));
		}
		else
		{
			throw 'Texture "$texture" does not exist';
		}
	}

	private function technique(material:Material):Array<Pass>
	{
		expected("technique");
		expected("{");
		var passes = [];
		while (scan() == "pass")
		{
			passes.push(pass());
		}
		expected("}");
		return passes;
	}

	private inline function expected(expected:String):String
	{
		var token = next();
		if (token != expected) throw 'Expected "$expected" but got "$token"';
		return token;
	}

	private var _text:String;
	private var _next:String;
	private var _index:Int = 0;

}
