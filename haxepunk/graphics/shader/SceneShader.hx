package haxepunk.graphics.shader;

import haxepunk.assets.AssetLoader;
import haxepunk.graphics.hardware.opengl.GL;
import haxepunk.graphics.hardware.opengl.GLBuffer;
import haxepunk.graphics.hardware.opengl.GLUniformLocation;
import haxepunk.graphics.hardware.opengl.GLUtils;
import haxepunk.graphics.hardware.Float32Array;

/**
 * Used to create a custom shader.
 */
class SceneShader extends Shader
{
	static inline var DEFAULT_VERTEX_SHADER:String = "
#ifdef GL_ES
precision mediump float;
#endif

attribute vec4 aPosition;
attribute vec2 aTexCoord;
varying vec2 vTexCoord;

void main() {
	vTexCoord = aTexCoord;
	gl_Position = aPosition;
}";

	static inline var DEFAULT_FRAGMENT_SHADER:String = "
#ifdef GL_ES
precision mediump float;
#endif

varying vec2 vTexCoord;
uniform sampler2D uImage0;
uniform vec2 uResolution;

void main () {
	gl_FragColor = texture2D(uImage0, vTexCoord);
}";

	/**
	 * Create a custom shader from a text asset.
	 */
	public static inline function fromAsset(name:String):SceneShader
	{
		return new SceneShader(AssetLoader.getText(name));
	}

	public var width:Null<Int> = null;
	public var height:Null<Int> = null;
	public var smooth:Bool = false;

	public var textureWidth(get, never):Int;
	inline function get_textureWidth() return width == null ? HXP.screen.width : Std.int(Math.min(HXP.screen.width, width));

	public var textureHeight(get, never):Int;
	inline function get_textureHeight() return height == null ? HXP.screen.height : Std.int(Math.min(HXP.screen.height, height));

	var v:Float32Array;

	/**
	 * Create a custom shader from a string.
	 */
	public function new(?fragment:String)
	{
		if (fragment == null)
		{
			fragment = DEFAULT_FRAGMENT_SHADER;
		}
		super(DEFAULT_VERTEX_SHADER, fragment);
		position.name = "aPosition";
		texCoord.name = "aTexCoord";
	}

	function createBuffer()
	{
		buffer = GL.createBuffer();
		GL.bindBuffer(GL.ARRAY_BUFFER, buffer);
		v = new Float32Array(_vertices);
		#if (lime >= "4.0.0")
		GL.bufferData(GL.ARRAY_BUFFER, v.length * Float32Array.BYTES_PER_ELEMENT, v, GL.STATIC_DRAW);
		#else
		GL.bufferData(GL.ARRAY_BUFFER, v, GL.STATIC_DRAW);
		#end
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
	}

	override public function build()
	{
		super.build();
		image = uniformIndex("uImage0");
		resolution = uniformIndex("uResolution");
	}

	public function setScale(w:Int, h:Int, sx:Float, sy:Float)
	{
		if (GLUtils.invalid(buffer) || GLUtils.invalid(v))
		{
			createBuffer();
		}

		GL.bindBuffer(GL.ARRAY_BUFFER, buffer);
		var x:Float = w / HXP.screen.width,
			y:Float = h / HXP.screen.height;
		sx *= x;
		sy *= y;
		if (_lastX != x || _lastY != y || _lastSx != sx || _lastSy != sy)
		{
			v[4] = v[12] = v[16] = sx * 2 - 1;
			v[1] = v[5] = v[13] = -sy * 2 + 1;
			v[6] = v[14] = v[18] = x;
			v[3] = v[7] = v[15] = 1 - y;

			#if (lime >= "4.0.0")
			GL.bufferData(GL.ARRAY_BUFFER, v.length * Float32Array.BYTES_PER_ELEMENT, v, GL.STATIC_DRAW);
			#else
			GL.bufferData(GL.ARRAY_BUFFER, v, GL.STATIC_DRAW);
			#end

			_lastX = x;
			_lastY = y;
			_lastSx = sx;
			_lastSy = sy;
		}
		trace(_lastX, _lastY, _lastSx, _lastSy);
	}

	override public function bind()
	{
		super.bind();
		if (GLUtils.invalid(buffer))
		{
			createBuffer();
		}

		GL.vertexAttribPointer(position.index, 2, GL.FLOAT, false, 4 * Float32Array.BYTES_PER_ELEMENT, 0);
		GL.vertexAttribPointer(texCoord.index, 2, GL.FLOAT, false, 4 * Float32Array.BYTES_PER_ELEMENT, 2 * Float32Array.BYTES_PER_ELEMENT);

		GL.uniform1i(image, 0);
		GL.uniform2f(resolution, HXP.screen.width, HXP.screen.height);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
	}

	static var _vertices:Array<Float> = [
		-1.0, -1.0, 0, 0,
		1.0, -1.0, 1, 0,
		-1.0, 1.0, 0, 1,
		1.0, -1.0, 1, 0,
		1.0, 1.0, 1, 1,
		-1.0, 1.0, 0, 1
	];

	var image:GLUniformLocation;
	var resolution:GLUniformLocation;
	static var _lastX:Float = 0;
	static var _lastY:Float = 0;
	static var _lastSx:Float = 0;
	static var _lastSy:Float = 0;
	static var buffer:GLBuffer;
}
