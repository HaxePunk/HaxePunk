package com.haxepunk.graphics;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.geom.ColorTransform;
import com.haxepunk.HXP;
import com.haxepunk.RenderMode;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.Canvas;
import com.haxepunk.graphics.Text;
import com.haxepunk.graphics.atlas.BitmapFontAtlas;
import com.haxepunk.graphics.atlas.AtlasRegion;


typedef RenderFunction = AtlasRegion -> GlyphData -> Float -> Float -> Void;

class BitmapText extends Graphic {
	private var _buffer:BitmapData;
	private var _set:BitmapData;
	private var _font:BitmapFontAtlas;
	private var _matrix:Matrix;
	private var _colorTransform:ColorTransform;
	
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
		
		// load the font as a TextureAtlas
		var font = BitmapFontAtlas.getFont(options.font);
		
		_blit = HXP.renderMode != RenderMode.HARDWARE;
		_font = cast(font, BitmapFontAtlas);
		
		// failure to load
		if (_font == null)
			throw "Invalid font glyphs provided.";
		
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.size = options.size;
		
		autoWidth = width==0;
		autoHeight = height==0;
		
		if (_blit) {
			_set = HXP.getBitmap(StringTools.replace(options.font, ".fnt", ".png"));
			_matrix = HXP.matrix;
			_colorTransform = new ColorTransform();
		}
		
		this.color = options.color;
		this.text = text;
	}
	
	private var _red:Float;
	private var _green:Float;
	private var _blue:Float;
	public var color(default, set_color):Int=0xffffff;
	private function set_color(value:Int):Int {
		value &= 0xFFFFFF;
		if (color == value) return value;
		
		color = value;
		updateColor();
		
		return value;
	}
	
	public var alpha(default,set):Float=1;
	function set_alpha(value:Float) {
		alpha = value;
		updateColor();
		
		return value;
	}
	
	function updateColor() {
		// update _colorTransform if blitting
		_red = HXP.getRed(color) / 255;
		_green = HXP.getGreen(color) / 255;
		_blue = HXP.getBlue(color) / 255;
		
		if (_blit) {
			_colorTransform.redMultiplier = _red;
			_colorTransform.greenMultiplier = _green;
			_colorTransform.blueMultiplier = _blue;
			_colorTransform.alphaMultiplier = alpha;
			updateBuffer();
		}
	}
	
	public function set_text(text:String) {
		this.text = text;
		_lines = text.split("\n");
		
		if (_blit) updateBuffer();
		
		return text;
	}
	
	public function computeTextSize() {
		// make a pass through the text without actually rendering to compute
		// textWidth/textHeight
		renderFont(function(region:AtlasRegion,gd:GlyphData,x:Float,y:Float) {
		});
	}
	
	public function updateBuffer() {
		// render the string of text to _buffer
		
		if (text == null) return;
		
		var fontScale = size/_font.fontSize;
		
		var fsx = HXP.screen.fullScaleX,
			fsy = HXP.screen.fullScaleY;
		
		var sx = scale * scaleX * fontScale * fsx,
			sy = scale * scaleY * fontScale * fsy;
			
		computeTextSize();
		
		var w = Std.int(textWidth*sx);
		var h = Std.int(textHeight*sy);
		
		if (_buffer == null || _buffer.width != w || _buffer.height != h) {
			_buffer = new BitmapData(w*2, h*2, true, 0);
		}
		
		renderFont(function(region:AtlasRegion,gd:GlyphData,x:Float,y:Float) {
			_matrix.b = _matrix.c = 0;
			_matrix.a = sx;
			_matrix.d = sy;
			_matrix.tx = x;
			_matrix.ty = y;
			_point.x = x;
			_point.y = y;
			
			var thisGlyph = new BitmapData(cast gd.rect.width, cast gd.rect.height);
			thisGlyph.copyPixels(_set, gd.rect, new Point());
			_buffer.draw(thisGlyph, _matrix, null, null, null, false);
			_buffer.colorTransform(_buffer.rect, _colorTransform);
		});
	}
	
	public function renderFont(renderFunction:RenderFunction) {
		// loop through the text one character at a time, calling the supplied
		// rendering function for each character
		var fontScale = size/_font.fontSize;
		
		var fsx = HXP.screen.fullScaleX,
			fsy = HXP.screen.fullScaleY;
		
		var sx = scale * scaleX * fontScale * fsx,
			sy = scale * scaleY * fontScale * fsy;
		
		var lineHeight:Int = Std.int(_font.lineHeight + lineSpacing);
		
		var rx:Int = 0;
		var ry:Int = 0;
		for (y in 0 ... _lines.length) {
			var line = _lines[y];
			
			for (x in 0 ... line.length) {
				var letter = line.charAt(x);
				var region = _font.getChar(letter);
				var gd = _font.glyphData[letter];
				
				if (letter==' ') {
					// it's a space, just move the cursor
					rx += Std.int(gd.xAdvance);
				} else {
					// draw the character
					renderFunction(region, gd,
					               (rx+gd.xOffset)*sx, 
					               (ry+gd.yOffset)*sy);
					
					// advance cursor position
					rx += Std.int((gd.xAdvance + charSpacing));
					if (width != 0 && rx > width) {
						textWidth = Std.int(width);
						rx = 0;
						ry += lineHeight;
					}
				}
				
				if (rx > textWidth) textWidth = rx;
			}
			
			// next line
			rx = 0;
			ry += lineHeight;
			if (ry > textHeight) textHeight = ry;
		}
	}
	
	override public function render(target:BitmapData, point:Point, camera:Point) {
		// determine drawing location
		var fontScale = size/_font.fontSize;
		
		var fsx = HXP.screen.fullScaleX,
			fsy = HXP.screen.fullScaleY;
		
		var sx = scale * scaleX * fontScale * fsx,
			sy = scale * scaleY * fontScale * fsy;
		
		_point.x = Math.floor((point.x + x - camera.x * scrollX) * fsx);
		_point.y = Math.floor((point.y + y - camera.y * scrollY) * fsy);
		
		if (_blit) {
			// blit the buffer to the screen
			target.copyPixels(_buffer, _buffer.rect, _point, null, null, true);
			
		} else {
			// use hardware accelerated rendering
			renderFont(function(region:AtlasRegion,gd:GlyphData, x:Float,y:Float) {
				region.draw(_point.x+x,_point.y+y,layer,sx,sy,0,_red,_green,_blue,alpha);
			});
		}
	}
}
