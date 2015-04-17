package haxepunk.graphics;

import haxe.ds.IntMap;
import haxepunk.scene.Camera;
import haxepunk.math.Vector3;
import haxepunk.math.Matrix4;
import haxepunk.renderers.Renderer;
import lime.text.Font;
import lime.text.TextLayout;
import lime.Assets;

using StringTools;

class Text extends Graphic
{

	/**
	 * The font color of the Text
	 */
	public var color:Color;

	/**
	 * The font size of the Text
	 */
	public var size(default, null):Int;

	/**
	 * The pixel height of each line of text
	 */
	public var lineHeight:Float;

	/**
	 * The number of spaces for tab characters
	 */
	public var tabWidth:Int = 4;

	/**
	 * Create a new Text graphic
	 * @param text the default text to render
	 * @param size the font size of the text
	 */
	public function new(text:String, size:Int=14)
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
		_textLayout = new TextLayout("", _font, size, LEFT_TO_RIGHT, LATIN, "en");
		var image = _font.renderGlyphs(_font.getGlyphs(), size);

		_texture = new Texture();
		_texture.loadFromImage(image);
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

	/**
	 * The text value to render. Regenerates a list of glyphs to draw.
	 */
	public var text(default, set):String;
	private function set_text(value:String):String {
		#if !flash
		if (text != value)
		{
			if (value.trim() == "")
			{
				_numTriangles = 0;
			}
			else if (text != null && text.startsWith(value))
			{
				// don't recreate the buffer if it's the same
				_numTriangles = value.replace("\n", "").length * 2;
			}
			else
			{
				_textLayout.text = value;
				var x:Float, y:Float;
				var lines = value.split("\n");
				var vertIndex = 0, indIndex = 0;
				for (i in 0...lines.length)
				{
					var line = lines[i];
					// TODO: remove magic number (lineHeight * 0.8)
					y = lineHeight * i + lineHeight * 0.8;
					x = 0.0;
					for (p in _textLayout.positions)
					{
						var metrics = _font.getGlyphMetrics(p.glyph);
						trace(metrics);

						var left   = metrics.advance.x / _texture.width;
						var top    = metrics.advance.y / _texture.height;
						var right  = left + metrics.width / _texture.width;
						var bottom = top + metrics.height / _texture.height;

						var pointLeft = x + p.offset.x + metrics.xOffset;
						var pointTop = y + p.offset.y - metrics.yOffset;
						var pointRight = pointLeft + metrics.width;
						var pointBottom = pointTop + metrics.height;

						_vertices[vertIndex++] = pointRight;
						_vertices[vertIndex++] = pointBottom;
						_vertices[vertIndex++] = right;
						_vertices[vertIndex++] = bottom;

						_vertices[vertIndex++] = pointLeft;
						_vertices[vertIndex++] = pointBottom;
						_vertices[vertIndex++] = left;
						_vertices[vertIndex++] = bottom;

						_vertices[vertIndex++] = pointRight;
						_vertices[vertIndex++] = pointTop;
						_vertices[vertIndex++] = right;
						_vertices[vertIndex++] = top;

						_vertices[vertIndex++] = pointLeft;
						_vertices[vertIndex++] = pointTop;
						_vertices[vertIndex++] = left;
						_vertices[vertIndex++] = top;

						var j = Std.int(indIndex / 6) * 4;
						_indices[indIndex++] = j;
						_indices[indIndex++] = j+1;
						_indices[indIndex++] = j+2;

						_indices[indIndex++] = j+1;
						_indices[indIndex++] = j+2;
						_indices[indIndex++] = j+3;

						x += p.advance.x;
						y -= p.advance.y;
					}
					if (x > width) width = x;
				}
				_numTriangles = Math.floor(indIndex / 3);
				height = lineHeight * lines.length;
				Renderer.bindBuffer(_vertexBuffer);
				Renderer.updateBuffer(_vertices, STATIC_DRAW);
				_indexBuffer = Renderer.updateIndexBuffer(_indices, STATIC_DRAW, _indexBuffer);
			}
		}
		#end
		return text = value;
	}

	/**
	 * Draw the Text object to the screen
	 * @param offset the offset of the Text object usually set from and Entity
	 */
	override public function draw(offset:Vector3):Void
	{
		#if !flash
		if (_numTriangles <= 0 || _indexBuffer == null || _vertexBuffer == null) return;

		// TODO: batch this process

		// finish drawing whatever came before the text area
		SpriteBatch.flush();

		material.use();

		origin *= scale;
		origin += offset;

		_matrix.identity();
		_matrix.translateVector3(origin);
		if (angle != 0) _matrix.rotateZ(angle);
		_matrix.multiply(HXP.scene.camera.transform);

		origin -= offset;
		origin /= scale;

		Renderer.setMatrix(_modelViewMatrixUniform, _matrix);
		Renderer.setColor(_colorUniform, color);

		Renderer.bindBuffer(_vertexBuffer);
		Renderer.setAttribute(_vertexAttribute, 0, 2);
		Renderer.setAttribute(_texCoordAttribute, 2, 2);

		Renderer.draw(_indexBuffer, _numTriangles, 0);
		#end
	}

	private var _textLayout:TextLayout;
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
	private var _numTriangles:Int = 0;

}
