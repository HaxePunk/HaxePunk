package haxepunk.graphics;

import lime.graphics.Image;

class Font {

	#if js
	private static var __canvas:js.html.CanvasElement;
	private static var __context:js.html.CanvasRenderingContext2D;
	#end

	public function new() {

	}

	public function toImage(glyphs:String):Image {

		var width = 512, height = 512;

		#if js

		if (__canvas == null)
		{
			__canvas = cast js.Browser.document.createElement ("canvas");
			__context = cast __canvas.getContext ("2d");
		}

		__context.fillStyle = '#FFF';
		__context.font = "12px monospace";

		__context.fillText(glyphs, 0, 0);

		var pixels = __context.getImageData (0, 0, width, height);
		__data = new ImageData (pixels.data);

		#elseif flash

		var bitmapData = new BitmapData (textureWidth, textureHeight, true, 0x000000);
		bitmapData.draw (src, null, null, null, true);

		var pixels = bitmapData.getPixels (bitmapData.rect);
		__data = new ImageData (pixels);

		#end

		return new Image();
	}

}
