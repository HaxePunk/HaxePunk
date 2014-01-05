package com.haxepunk.graphics;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.haxepunk.HXP;
import com.haxepunk.RenderMode;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.Canvas;
import com.haxepunk.graphics.Text;
import com.haxepunk.graphics.atlas.BitmapFontAtlas;


class BitmapText extends Graphic {
	private var _set:BitmapData;
	private var _font:BitmapFontAtlas;
	
	public var width:Float=0;
	public var height:Float=0;
	public var textWidth:Int=0;
	public var textHeight:Int=0;
	public var autoWidth:Bool = false;
	public var autoHeight:Bool = false;
	public var size:Int=0;
	
	public var scale:Float=1;
	public var scaleX:Float=1;
	public var scaleY:Float=1;
	
	public var lineSpacing:Int=0;
	public var charSpacing:Int=0;
	
	public var text(default, set):String;
	private var _lines:Array<String>;
	
	public function new(text:String, x:Float=0, y:Float=0, width:Float=0, height:Float=0, ?options:TextOptions) {
		super();
		
		if (options == null) {
			options = {};
			options.color = 0xFFFFFF;
		}

		if (options.font == null)  options.font = HXP.defaultFont;
		if (options.size == 0)     options.size = 16;
		
		var font = BitmapFontAtlas.getFont(options.font);
		
		// load the font
		_blit = !HXP.renderMode.has(RenderMode.HARDWARE);
		_font = cast(font, BitmapFontAtlas);
		
		// failure to load
		if (_set == null && _font == null)
			throw "Invalid font glyphs provided.";
		
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.size = options.size;
		
		autoWidth = width==0;
		autoHeight = height==0;
		
		this.color = options.color;
		
		this.text = text;
	}
	
	private var _red:Float;
	private var _green:Float;
	private var _blue:Float;
	public var color(default, set_color):Int;
	private function set_color(value:Int):Int {
		value &= 0xFFFFFF;
		if (color == value) return value;
		// save individual color channel values
		_red = HXP.getRed(value) / 255;
		_green = HXP.getGreen(value) / 255;
		_blue = HXP.getBlue(value) / 255;

		return color = value;
	}
	
	public var alpha:Float=1;
	
	public function set_text(text:String) {
		this.text = text;
		_lines = text.split("\n");
		return text;
	}
	
	override public function render(target:BitmapData, point:Point, camera:Point) {
		// determine drawing location
		_point.x = point.x + x - camera.x * scrollX;
		_point.y = point.y + y - camera.y * scrollY;
		
		var fontScale = size/_font.fontSize;
		
		var fsx = HXP.screen.fullScaleX,
		    fsy = HXP.screen.fullScaleY;
		
		var sx = scale * scaleX * fontScale * fsx,
		    sy = scale * scaleY * fontScale * fsy;
		
		_point.x = Math.floor(_point.x * fsx);
		_point.y = Math.floor(_point.y * fsy);
		
		var lineHeight:Int = Std.int((_font.lineHeight + lineSpacing) * sy);
		
		var rx:Int = 0;
		var ry:Int = 0;
		for (y in 0 ... _lines.length) {
			var line = _lines[y];
			
			for (x in 0 ... line.length) {
				var letter = line.charAt(x);
				var region = _font.getChar(letter);
				var md = _font.glyphMetadata[letter];
				
				if (letter==' ') {
					// it's a space, just move the cursor
					rx += Std.int(md.xAdvance * sx);
				} else {
					// draw the character
					region.draw(_point.x+rx+md.xOffset*sx, 
					            _point.y+ry+md.yOffset*sy, 
					            layer,
					            sx, sy, 0,
					            _red, _green, _blue, alpha);
					
					// advance cursor position
					rx += Std.int((md.xAdvance + charSpacing) * sx);
					if (width != 0 && rx > width*sx) {
						if (autoWidth) textWidth = Std.int(width);
						rx = 0;
						ry += lineHeight;
					}
				}
				
				if (autoWidth && rx > textWidth) textWidth = rx;
			}
			
			rx = 0;
			ry += lineHeight;
			if (autoHeight && ry > textHeight) textHeight = ry;
		}
	}
}
