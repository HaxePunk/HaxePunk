package haxepunk.graphics;

import haxe.ds.IntMap;
import haxepunk.scene.Camera;
import haxepunk.math.Vector3;
import haxepunk.math.Matrix4;
import haxepunk.renderers.Renderer;
import lime.text.Font;
import lime.text.TextLayout;

using StringTools;

class Text extends Graphic
{

	/**
	 * The font color of the Text
	 */
	public var color:Color;

	/**
	 * The pixel height of each line of text
	 */
	public var lineHeight:Float;

	/**
	 * The number of spaces for tab characters
	 */
	public var tabWidth:Int = 4;

	/**
	 * The font size of the Text
	 */
	public var size(default, set):Int;
	private function set_size(value:Int):Int {
		if (size != value)
		{
			_images = _font.renderGlyphs(_font.getGlyphs(), value);
			if (_images != null)
			{
				var it = _images.iterator();
				if (it.hasNext())
				{
					_texture.loadFromImage(it.next().buffer);
				}
			}
		}
		return size = value;
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
						var image = _images.get(p.glyph);
						if (image != null)
						{
							// uv
							var ratio  = 1 / _texture.width;
							var left   = image.offsetX * ratio;
							var right  = left + image.width * ratio;
							ratio      = 1 / _texture.height;
							var top    = image.offsetY * ratio;
							var bottom = top + image.height * ratio;

							var pointLeft = x + p.offset.x + image.x;
							var pointTop = y + p.offset.y - image.y;
							var pointRight = pointLeft + image.width;
							var pointBottom = pointTop + image.height;

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
						}

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
	 * Create a new Text graphic
	 * @param text the default text to render
	 * @param size the font size of the text
	 */
	public function new(text:String, size:Int=14)
	{
		super();
		_vertices = new FloatArray();
		_indices = new IntArray();
		_texture = new Texture();
		color = new Color();

		#if flash
		var vert = "m44 op, va0, vc0\nmov v0, va1";
		var frag = "tex ft0, v0, fs0 <linear nomip 2d wrap>\nmov ft0.xyz, fc1.xyz\nmov oc, ft0";
		#else
		_font = Font.fromFile("hxp/font/OpenSans-Regular.ttf");
		_textLayout = new TextLayout("", _font, size, LEFT_TO_RIGHT, LATIN, "en");

		// MUST be set after the texture is created
		this.lineHeight = this.size = size;

		var vert = Assets.getText("hxp/shaders/default.vert");
		var frag = Assets.getText("hxp/shaders/text.frag");
		#end

		var shader = new Shader(vert, frag);
		material = Material.fromAsset("hxp/materials/text.material");
		var pass = material.firstPass;
		pass.shader = shader;
		pass.addTexture(_texture);

		_vertexBuffer = Renderer.createBuffer(4);

		this.text = text;
	}

	/**
	 * Draw the Text object to the screen
	 * @param offset the offset of the Text object usually set from and Entity
	 */
	override public function draw(offset:Vector3):Void
	{
		#if !flash
		if (_numTriangles <= 0 || _indexBuffer == null || _vertexBuffer == null) return;

		// TODO: batch this process?
		// finish drawing whatever came before the text area
		SpriteBatch.flush();

		origin *= scale;
		origin += offset;

		_matrix.identity();
		_matrix.translateVector3(origin);
		if (angle != 0) _matrix.rotateZ(angle);
		_matrix.multiply(HXP.scene.camera.transform);

		origin -= offset;
		origin /= scale;

		Renderer.bindBuffer(_vertexBuffer);
		for (pass in material.passes)
		{
			pass.use();
			Renderer.setMatrix(pass.shader.uniform("uMatrix"), _matrix);
			Renderer.setColor(pass.shader.uniform("uColor"), color);
			Renderer.setAttribute(pass.shader.attribute("aVertexPosition"), 0, 2);
			Renderer.setAttribute(pass.shader.attribute("aTexCoord"), 2, 2);
			Renderer.draw(_indexBuffer, _numTriangles, 0);
		}

		#end
	}

	private var _textLayout:TextLayout;
	private var _font:Font;
	private var _texture:Texture;

	private var _images:Map<lime.text.Glyph, lime.graphics.Image>;
	private var _vertices:FloatArray;
	private var _indices:IntArray;
	private var _vertexBuffer:VertexBuffer;
	private var _indexBuffer:IndexBuffer;
	private var _numTriangles:Int = 0;

}
