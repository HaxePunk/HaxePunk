package haxepunk.graphics;

import haxe.ds.StringMap;
import haxepunk.scene.Camera;
import haxepunk.math.Vector3;
import haxepunk.renderers.Renderer;
import lime.graphics.Font;
import lime.utils.Float32Array;
import lime.utils.Int16Array;
import lime.Assets;

class Text implements Graphic
{

	public var material:Material;
	public var color:Color;

	public function new(text:String, size:Int=16)
	{
		_vertices = new Array<Float>();
		_indices = new Array<Int>();
		color = new Color();

		#if (cpp || neko)
		var font = new Font("../Resources/assets/Watermelon.ttf");
		#else
		var font = new Font("Georgia");
		#end

		var data = font.createImage(size);
		_glyphs = data.glyphs;

		setTexture(data.image);
		var shader = new Shader(Assets.getText("shaders/default.vert"), Assets.getText("shaders/text.frag"));
		material = new Material(shader);
		material.addTexture(_texture);

		this.text = text;

		_vertexAttribute = material.shader.attribute("aVertexPosition");
		_texCoordAttribute = material.shader.attribute("aTexCoord");
		_modelViewMatrixUniform = material.shader.uniform("uMatrix");
		_colorUniform = material.shader.uniform("uColor");
	}

	public var text(default, set):String;
	private function set_text(value:String):String {
		if (text != value)
		{
			var x = 100.0, y = 150.0;
			for (i in 0...value.length)
			{
				x += writeChar(i, value.charAt(i), x, y);
			}
			_vertexBuffer = Renderer.updateBuffer(new Float32Array(_vertices), 5, STATIC_DRAW, _vertexBuffer);
			_indexBuffer = Renderer.updateIndexBuffer(new Int16Array(_indices), STATIC_DRAW, _indexBuffer);
			text = value;
		}
		return value;
	}

	@:access(haxepunk.graphics.Texture)
	private function setTexture(image:lime.graphics.Image)
	{
		_texture = new Texture();
		_texture._texture = Renderer.createTexture(image);
		_texture.width = _texture.originalWidth = image.width;
		_texture.height = _texture.originalHeight = image.height;
	}

	private inline function writeChar(i:Int, c:String, x:Float = 0, y:Float = 0):Int
	{
		var rect = _glyphs.get(c);

		x += rect.xOffset;
		y -= rect.yOffset;

		var left   = rect.x / _texture.width;
		var top    = rect.y / _texture.height;
		var right  = left + rect.width / _texture.width;
		var bottom = top + rect.height / _texture.height;
		var index = i * 20;

		_vertices[index++] = x;
		_vertices[index++] = y;
		_vertices[index++] = 0;
		_vertices[index++] = left;
		_vertices[index++] = top;

		_vertices[index++] = x;
		_vertices[index++] = y + rect.height;
		_vertices[index++] = 0;
		_vertices[index++] = left;
		_vertices[index++] = bottom;

		_vertices[index++] = x + rect.width;
		_vertices[index++] = y;
		_vertices[index++] = 0;
		_vertices[index++] = right;
		_vertices[index++] = top;

		_vertices[index++] = x + rect.width;
		_vertices[index++] = y + rect.height;
		_vertices[index++] = 0;
		_vertices[index++] = right;
		_vertices[index++] = bottom;

		index = i * 6;
		_indices[index++] = i*4;
		_indices[index++] = i*4+1;
		_indices[index++] = i*4+2;

		_indices[index++] = i*4+1;
		_indices[index++] = i*4+2;
		_indices[index++] = i*4+3;

		return rect.advance;
	}

	public function update(elapsed:Float) {}

	public function draw(camera:Camera, offset:Vector3):Void
	{
		if (_vertexBuffer == null || _indexBuffer == null) return;

		material.use();

		// _matrix.multiply(camera.transform);
		Renderer.setMatrix(_modelViewMatrixUniform, camera.transform);
		Renderer.setColor(_colorUniform, color);

		Renderer.bindBuffer(_vertexBuffer);
		Renderer.setAttribute(_vertexAttribute, 0, 3);
		Renderer.setAttribute(_texCoordAttribute, 3, 2);

		Renderer.draw(_indexBuffer, text.length * 2, 0);
	}

	private var _glyphs:StringMap<GlyphRect>;
	private var _texture:Texture;

	private var _texCoordAttribute:Int;
	private var _vertexAttribute:Int;
	private var _modelViewMatrixUniform:Location;
	private var _colorUniform:Location;

	private var _vertices:Array<Float>;
	private var _indices:Array<Int>;
	private var _vertexBuffer:VertexBuffer;
	private var _indexBuffer:IndexBuffer;

}
