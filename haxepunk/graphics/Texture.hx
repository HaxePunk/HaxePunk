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
		_loaded ? value() : _onload.push(value);
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

	private function createTexture(dataArray:UInt8Array)
	{
		GL.bindTexture(GL.TEXTURE_2D, _texture);
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, height, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, dataArray);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		GL.bindTexture(GL.TEXTURE_2D, null);

		for (onload in _onload) onload();
		_loaded = true;
	}

	private inline function loadImage(path:String)
	{
#if lime_html5
		var image: js.html.ImageElement = js.Browser.document.createImageElement();
		image.onload = function(a) {
			var tmpCanvas = js.Browser.document.createCanvasElement();
				tmpCanvas.width = image.width;
				tmpCanvas.height = image.height;

			var tmpContext = tmpCanvas.getContext2d();
				tmpContext.clearRect(0,0, tmpCanvas.width, tmpCanvas.height);
				tmpContext.drawImage(image, 0, 0, image.width, image.height);

			var imageBytes = tmpContext.getImageData(0, 0, tmpCanvas.width, tmpCanvas.height);

			width = image.width;
			height = image.height;

			createTexture(new UInt8Array(imageBytes.data));

			tmpCanvas = null;
			tmpContext = null;
			imageBytes = null;
		};
		image.src = path;
#else
		var bytes = Assets.getBytes(path);
		if (bytes == null) return;
		var byteInput = new BytesInput(bytes, 0, bytes.length);
		var png = new format.png.Reader(byteInput).read();
		var data = format.png.Tools.extract32(png);
		var header = format.png.Tools.getHeader(png);

		width = header.width;
		height = header.height;

		var byteData = #if neko ByteArray.fromBytes(data) #else data.getData() #end;
		var dataArray = new UInt8Array(byteData);
		// bgra to rgba (flip blue and red channels)
		for (i in 0...(width * height))
		{
            var b = dataArray[i*4];
            dataArray[i*4] = dataArray[i*4+2]; // r
            dataArray[i*4+2] = b; // b
        }
		createTexture(dataArray);
#end
	}

	private var _texture:GLTexture;
	private var _onload:Array<OnloadCallback>;
	private var _loaded:Bool = false;

}
