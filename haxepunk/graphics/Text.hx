package haxepunk.graphics;

import haxe.ds.IntMap;
import haxepunk.scene.Camera;
import haxepunk.math.Vector3;
import haxepunk.math.Matrix4;
import haxepunk.renderers.Renderer;
import lime.graphics.Font;
import lime.graphics.TextFormat;
import lime.Assets;

using StringTools;

class Text extends Graphic
{

	public var color:Color;
	public var size(default, null):Int;
	public var lineHeight:Int;
	public var tabWidth:Int = 4;

	public function new(text:String, size:Int=16)
	{
		super();
		_vertices = new FloatArray();
		_indices = new IntArray();
		color = new Color();

		#if (cpp || neko)
		_font = new Font(#if mac "../Resources/" + #end "font/SourceCodePro-Regular.otf");
		#else
		_font = new Font("Georgia");
		#end

		this.size = size;
		this.lineHeight = Std.int(size * 1.4);

		_font.loadGlyphs(size);
		var image = _font.createImage();
		_glyphs = _font.glyphs.get(size);
		_textFormat = new TextFormat(LeftToRight, ScriptLatin, "en");

		_texture = new Texture();
		_texture.loadFromImage(new lime.graphics.Image(image));
		#if flash
		var vert = "m44 op, va0, vc0\nmov v0, va1";
		var frag = "tex ft0, v0, fs0 <linear nomip 2d wrap>\nmov ft0.xyz, fc1.xyz\nmov oc, ft0";
		#else
		var vert = Assets.getText("shaders/default.vert");
		var frag = Assets.getText("shaders/text.frag");
		#end
		var shader = new Shader(vert, frag);
		material = Material.fromAsset("materials/text.material");
		var pass = material.firstPass;
		pass.shader = shader;
		pass.addTexture(_texture);

		_vertexAttribute = shader.attribute("aVertexPosition");
		_texCoordAttribute = shader.attribute("aTexCoord");

		_modelViewMatrixUniform = shader.uniform("uMatrix");
		_colorUniform = shader.uniform("uColor");
		_vertexBuffer = Renderer.createBuffer(4);

		this.text = text;
	}

	public var text(default, set):String;
	private function set_text(value:String):String {
		if (text != value && value.trim() != "")
		{
			var spaceAdvance = _glyphs.get(" ".code).xOffset;
			var x = 0.0, y = 30.0;
			var index = 0;
			var points = _textFormat.fromString(_font, size, value);
			for (p in points)
			{
				if (!_glyphs.exists(p.codepoint)) continue;
				writeChar(index++, p, x, y);
				x += p.advance.x;
				y -= p.advance.y;
			}
			width = x;
			height = y + lineHeight;
			Renderer.bindBuffer(_vertexBuffer);
			Renderer.updateBuffer(_vertices, STATIC_DRAW);
			_indexBuffer = Renderer.updateIndexBuffer(_indices, STATIC_DRAW, _indexBuffer);
		}
		return text = value;
	}

	private function writeChar(i:Int, p:PosInfo, x:Float = 0, y:Float = 0):Void
	{
		var rect = _glyphs.get(p.codepoint);

		var left   = rect.x / _texture.width;
		var top    = rect.y / _texture.height;
		var right  = left + rect.width / _texture.width;
		var bottom = top + rect.height / _texture.height;

		var pointLeft = x + p.offset.x + rect.xOffset;
		var pointTop = y + p.offset.y - rect.yOffset;
		var pointRight = pointLeft + rect.width;
		var pointBottom = pointTop + rect.height;

		var index = i * 20;
		_vertices[index++] = pointRight;
		_vertices[index++] = pointBottom;
		_vertices[index++] = left;
		_vertices[index++] = top;

		_vertices[index++] = pointLeft;
		_vertices[index++] = pointBottom;
		_vertices[index++] = left;
		_vertices[index++] = bottom;

		_vertices[index++] = pointRight;
		_vertices[index++] = pointTop;
		_vertices[index++] = right;
		_vertices[index++] = top;

		_vertices[index++] = pointLeft;
		_vertices[index++] = pointTop;
		_vertices[index++] = right;
		_vertices[index++] = bottom;

		index = i * 6;
		_indices[index++] = i*4;
		_indices[index++] = i*4+1;
		_indices[index++] = i*4+2;

		_indices[index++] = i*4+1;
		_indices[index++] = i*4+2;
		_indices[index++] = i*4+3;
	}

	override public function draw(camera:Camera, offset:Vector3):Void
	{
		if (_indexBuffer == null || _vertexBuffer == null) return;

		material.use();

		_matrix.identity();
		_matrix.translateVector3(offset);
		if (angle != 0) _matrix.rotateZ(angle);
		_matrix.multiply(camera.transform);

		Renderer.setMatrix(_modelViewMatrixUniform, _matrix);
		Renderer.setColor(_colorUniform, color);

		Renderer.bindBuffer(_vertexBuffer);
		Renderer.setAttribute(_vertexAttribute, 0, 2);
		Renderer.setAttribute(_texCoordAttribute, 2, 2);

		Renderer.draw(_indexBuffer, text.length * 2, 0);
	}

	private var _glyphs:IntMap<GlyphRect>;
	private var _textFormat:TextFormat;
	private var _font:Font;
	private var _texture:Texture;

	private var _texCoordAttribute:Int;
	private var _vertexAttribute:Int;
	private var _modelViewMatrixUniform:Location;
	private var _colorUniform:Location;
	private var _widthUniform:Location;
	private var _heightUniform:Location;

	private var _vertices:FloatArray;
	private var _indices:IntArray;
	private var _vertexBuffer:VertexBuffer;
	private var _indexBuffer:IndexBuffer;

}
