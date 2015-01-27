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
	public var lineHeight:Float;
	public var tabWidth:Int = 4;

	public function new(text:String, size:Int=16)
	{
		super();
		_vertices = new FloatArray();
		_indices = new IntArray();
		color = new Color();

		this.size = size;
		this.lineHeight = size;

		#if flash
		var vert = "m44 op, va0, vc0\nmov v0, va1";
		var frag = "tex ft0, v0, fs0 <linear nomip 2d wrap>\nmov ft0.xyz, fc1.xyz\nmov oc, ft0";
		#else
		_font = Font.fromFile("font/SourceCodePro-Regular.otf");
		_font.loadGlyphs(size);
		var image = _font.createImage();
		_textFormat = new TextFormat(LeftToRight, ScriptLatin, "en");

		_texture = new Texture();
		_texture.loadFromImage(new lime.graphics.Image(image));
		var vert = Assets.getText("shaders/default.vert");
		var frag = Assets.getText("shaders/text.frag");

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
		#end

		this.text = text;
	}

	public var text(default, set):String;
	private function set_text(value:String):String {
		#if !flash
		if (text != value && value.trim() != "")
		{
			var glyphs = _font.glyphs.get(size);

			var x:Float, y:Float;
			var lines = value.split("\n");
			var numTiles = 0;
			for (i in 0...lines.length)
			{
				var line = lines[i];
				// TODO: remove magic number (lineHeight * 0.8)
				y = lineHeight * i + lineHeight * 0.8;
				var points = _textFormat.fromString(_font, size, line);
				x = 0.0;
				for (p in points)
				{
					if (!glyphs.exists(p.codepoint)) continue;
					var glyph = glyphs.get(p.codepoint);

					var left   = glyph.x / _texture.width;
					var top    = glyph.y / _texture.height;
					var right  = left + glyph.width / _texture.width;
					var bottom = top + glyph.height / _texture.height;

					var pointLeft = x + p.offset.x + glyph.xOffset;
					var pointTop = y + p.offset.y - glyph.yOffset;
					var pointRight = pointLeft + glyph.width;
					var pointBottom = pointTop + glyph.height;

					var index = numTiles * 16;
					_vertices[index++] = pointRight;
					_vertices[index++] = pointBottom;
					_vertices[index++] = right;
					_vertices[index++] = bottom;

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
					_vertices[index++] = left;
					_vertices[index++] = top;

					index = numTiles * 6;
					var j = Std.int(index / 6) * 4;
					_indices[index++] = j;
					_indices[index++] = j+1;
					_indices[index++] = j+2;

					_indices[index++] = j+1;
					_indices[index++] = j+2;
					_indices[index++] = j+3;

					x += p.advance.x;
					y -= p.advance.y;
					numTiles += 1;
				}
				if (x > width) width = x;
			}
			height = lineHeight * lines.length;
			Renderer.bindBuffer(_vertexBuffer);
			Renderer.updateBuffer(_vertices, STATIC_DRAW);
			_indexBuffer = Renderer.updateIndexBuffer(_indices, STATIC_DRAW, _indexBuffer);
		}
		#end
		return text = value;
	}

	override public function draw(camera:Camera, offset:Vector3):Void
	{
		#if !flash
		if (_indexBuffer == null || _vertexBuffer == null) return;

		// finish drawing whatever came before the text area
		HXP.spriteBatch.flush(camera);

		// TODO: batch this process
		material.use();

		origin *= scale;
		origin += offset;

		_matrix.identity();
		_matrix.translateVector3(origin);
		if (angle != 0) _matrix.rotateZ(angle);
		_matrix.multiply(camera.transform);

		origin -= offset;
		origin /= scale;

		Renderer.setMatrix(_modelViewMatrixUniform, _matrix);
		Renderer.setColor(_colorUniform, color);

		Renderer.bindBuffer(_vertexBuffer);
		Renderer.setAttribute(_vertexAttribute, 0, 2);
		Renderer.setAttribute(_texCoordAttribute, 2, 2);

		Renderer.draw(_indexBuffer, text.length * 2, 0);
		#end
	}

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
