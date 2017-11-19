package haxepunk.graphics.hardware;

import haxepunk.utils.Color;

#if (lime || nme)

typedef ImageData = flash.display.BitmapData;

#else

class ImageData
{
    public var width(default, null):Int;
    public var height(default, null):Int;

    public function new(width:Int, height:Int, transparent:Bool = false, color:Color = Color.Black)
    {
        this.width = width;
        this.height = height;
    }

    public function getPixel32(x:Int, y:Int):Int
    {
        throw "Unimplemented";
        return 0;
    }

    public function dispose()
    {

    }
}

#end