package tools;

import lime.graphics.Font;
import sys.io.*;

class Asset
{
	public static function process(args:Array<String>)
	{
		var inFile = args.shift();
		var outFile = args.shift();

		switch (Path.extension(inFile))
		{
			case "ttf":
				processFont(inFile, outFile);
		}
	}

	private static function processFont(fontFile:String, imageFile:String)
	{
		// var font = new Font(fontFile);
		// var fontData = font.createImage(32);
		// var file = File.write(imageFile);

		// var image = fontData.image.src;
		// for (i in 0...image.length)
		// {
		// 	file.writeByte(image[i]);
		// }
		// file.close();
	}
}
