package haxepunk.graphics;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import lime.gl.GL;
import lime.gl.GLTexture;
import lime.utils.Assets;
import lime.utils.UInt8Array;
import lime.utils.ByteArray;

typedef OnloadCallback = Void->Void;

class Texture
{

	/**
	 * The width of the texture
	 */
	public var width(default, null):Int = 0;

	/**
	 * The height of the texture
	 */
	public var height(default, null):Int = 0;

	public var onload(never, set):OnloadCallback;
	private function set_onload(value:OnloadCallback):OnloadCallback
	{
		_onload.push(value);
		return value;
	}

	/**
	 * Creates a new Texture
	 * @param path The path to the texture asset
	 */
	public function new(path:String)
	{
		_texture = GL.createTexture();
		_onload = new Array<OnloadCallback>();
		loadImage(path);
	}

	/**
	 * Binds the texture for drawing
	 */
	public inline function bind():Void
	{
		GL.bindTexture(GL.TEXTURE_2D, _texture);
	}

	private function createTexture(bytes:Bytes)
	{
		if (bytes == null) return;
		var byteInput = new BytesInput(bytes, 0, bytes.length);
		var png = new format.png.Reader(byteInput).read();
		var data = format.png.Tools.extract32(png);
		var header = format.png.Tools.getHeader(png);

		width = header.width;
		height = header.height;

		var byteData = #if neko ByteArray.fromBytes(data) #else data.getData() #end;
		var dataArray = new UInt8Array(byteData);

		GL.bindTexture(GL.TEXTURE_2D, _texture);
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, height, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, dataArray);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		GL.bindTexture(GL.TEXTURE_2D, null);

		for (onload in _onload) onload();
	}

	private inline function loadImage(path:String)
	{
#if lime_html5
		var request = new js.html.XMLHttpRequest();
		request.open("GET", path);
		request.responseType = "arraybuffer";
		request.onload = function(v:Dynamic):Void {
			var buffer:js.html.ArrayBuffer = request.response;
			var byteArray = new UInt8Array(buffer);
			var array:Array<Int> = new Array<Int>();
			for (i in 0...byteArray.length) {
				array.push(byteArray[i]);
			}
			var bytes = Bytes.ofData(array);
			createTexture(bytes);
		};
		request.send(null);
#else
		var bytes = Assets.getBytes(path);
		createTexture(bytes);
#end
	}

	private var _texture:GLTexture;
	private var _onload:Array<OnloadCallback>;

}
