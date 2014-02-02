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
	public var wrap:Bool=false;

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
		wrap = options.wordWrap;

		if (options.font == null)  options.font = HXP.defaultFont;
		if (options.size == 0)     options.size = 16;

		// load the font as a TextureAtlas
		var font = BitmapFontAtlas.getFont(options.font);

		blit = HXP.renderMode != RenderMode.HARDWARE;
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

		if (blit) {
			_set = HXP.getBitmap(StringTools.replace(options.font, ".fnt", ".png"));
			_matrix = HXP.matrix;
			_colorTransform = new ColorTransform();
		}

		this.color = options.color;
		updateColor();
		this.text = text;
	}

	private var _red:Float;
	private var _green:Float;
	private var _blue:Float;
	public var color(default, set):Int;
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

		if (blit) {
			_colorTransform.color = color;
			_colorTransform.alphaMultiplier = alpha;
		}
	}

	public function set_text(text:String) {
		this.text = text;
		var _oldLines:Array<String> = null;
		if (_lines != null)
			_oldLines = _lines;
		_lines = text.split("\n");

		if (wrap) {
			wordWrap();
		}

		if (blit) updateBuffer(_oldLines);
		else computeTextSize();

		return text;
	}

	public function wordWrap() {
		// subdivide lines
		var newLines:Array<String> = [];
		var spaceWidth = _font.glyphData.get(' ').xAdvance;
		for (line in _lines) {
			var subLines:Array<String> = [];
			var words:Array<String> = [];
			// split this line into words
			var thisWord = "";
			for (n in 0 ... line.length) {
				var char:String = line.charAt(n);
				switch(char) {
					case ' ', '-': {
						words.push(thisWord + char);
						thisWord = "";
					}
					default: {
						thisWord += char;
					}
				}
			}
			if (thisWord != "") words.push(thisWord);
			if (words.length > 1) {
				var w = 0;
				var lineWidth = 0;
				var lastBreak = 0;
				while (w < words.length) {
					var wordWidth= 0;
					var word = words[w];
					for (letter in word.split('')) {
						var letterWidth = _font.glyphData.exists(letter) ?
						                  _font.glyphData.get(letter).xAdvance : 0;
						wordWidth += letterWidth + charSpacing;
					}
					lineWidth += wordWidth;
					// if the word ends in a space, don't count that last space
					// toward the line length for determining overflow
					var endsInSpace = word.charAt(word.length-1) == ' ';
					if (lineWidth - (endsInSpace ? spaceWidth : 0) > width) {
						// line is too long; split it before this word
						subLines.push(words.slice(lastBreak, w).join(''));
						lineWidth = wordWidth;
						lastBreak = w;
					}
					w += 1;
				}
				subLines.push(words.slice(lastBreak).join(''));
			} else {
				subLines.push(line);
			}

			for (subline in subLines) {
				newLines.push(subline);
			}
		}

		_lines = newLines;
	}

	public function computeTextSize() {
		// make a pass through the text without actually rendering to compute
		// textWidth/textHeight
		renderFont();
	}

	public function updateBuffer(oldLines:Array<String>=null) {
		// render the string of text to _buffer

		if (text == null) return;

		var fontScale = size/_font.fontSize;

		var fsx = HXP.screen.fullScaleX,
			fsy = HXP.screen.fullScaleY;

		var sx = scale * scaleX * fontScale,
			sy = scale * scaleY * fontScale;

		var w:Int;
		var h:Int;
		if (autoWidth || autoHeight) {
			computeTextSize();
			w = Std.int(autoWidth ? (textWidth) : width);
			h = Std.int(autoHeight ? (textHeight) : height);
		} else {
			w = Std.int(width);
			h = Std.int(height);
		}
		w = Std.int(w);
		h = Std.int(h+_font.lineHeight+lineSpacing);

		// if any of the previous lines of text are the same as the new lines,
		// don't re-render those lines
		var startLine = 0;
		if (oldLines != null) {
			for (n in 0 ... Std.int(Math.min(oldLines.length, _lines.length))) {
				if (_lines[n] == oldLines[n]) {
					startLine += 1;
				} else {
					break;
				}
			}
		}

		// create or clear the buffer if necessary
		if (_buffer == null || _buffer.width != w || _buffer.height != h) {
			if (_buffer != null) _buffer.dispose();
			_buffer = HXP.createBitmap(w, h, true, 0);
			startLine = 0;
		} else {
			var r = _buffer.rect;
			r.top = startLine * (_font.lineHeight + lineSpacing);
			_buffer.fillRect(r, 0);
			if (startLine > 0) startLine -= 1;
		}

		// make a pass through each character, copying it onto the buffer
		renderFont(function(region:AtlasRegion,gd:GlyphData,x:Float,y:Float) {
			_point.x = x;
			_point.y = y;

			_buffer.copyPixels(_set, gd.rect, _point, null, null, true);
		}, startLine);
	}

	private inline function renderFont(renderFunction:RenderFunction=null, startLine=0) {
		// loop through the text one character at a time, calling the supplied
		// rendering function for each character
		var fontScale = size/_font.fontSize;

		var lineHeight:Int = Std.int(_font.lineHeight + lineSpacing);

		var rx:Int = 0;
		var ry:Int = 0;
		for (y in 0 ... _lines.length) {
			var line = _lines[y];

			for (x in 0 ... line.length) {
				var letter = line.charAt(x);
				var region = _font.getChar(letter);
				var gd = _font.glyphData.get(letter);
				// if a character isn't in this font, display a space
				if (gd == null) letter = ' ';

				if (letter==' ') {
					// it's a space, just move the cursor
					rx += Std.int(gd.xAdvance);
				} else {
					// draw the character
					if (renderFunction != null &&
					    y >= startLine) {
						renderFunction(region, gd,
						               (rx+gd.xOffset),
						               (ry+gd.yOffset));
					}
					// advance cursor position
					rx += Std.int((gd.xAdvance + charSpacing));
					if (width != 0 && rx > width) {
						textWidth = Std.int(width);
						rx = 0;
						ry += lineHeight;
					}
				}

				// longest line so far
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

		var sx = scale * scaleX * fontScale,
			sy = scale * scaleY * fontScale;

		_point.x = Math.floor(point.x + x - camera.x * scrollX);
		_point.y = Math.floor(point.y + y - camera.y * scrollY);

		// blit the buffer to the screen
		_matrix.b = _matrix.c = 0;
		_matrix.a = sx;
		_matrix.d = sy;
		_matrix.tx = _point.x;
		_matrix.ty = _point.y;
		target.draw(_buffer, _matrix, _colorTransform);
		//target.copyPixels(_buffer, _buffer.rect, _point, null, null, true);
	}

	public override function renderAtlas(layer:Int, point:Point, camera:Point)
	{
		// determine drawing location
		var fontScale = size/_font.fontSize;

		var fsx = HXP.screen.fullScaleX,
			fsy = HXP.screen.fullScaleY;

		var sx = scale * scaleX * fontScale * fsx,
			sy = scale * scaleY * fontScale * fsy;

		_point.x = Math.floor(point.x + x - camera.x * scrollX);
		_point.y = Math.floor(point.y + y - camera.y * scrollY);

		// use hardware accelerated rendering
		renderFont(function(region:AtlasRegion,gd:GlyphData, x:Float,y:Float) {
			region.draw(_point.x * fsx + x * sx, _point.y * fsy + y * sy, layer, sx, sy, 0, _red, _green, _blue, alpha);
		});
	}
}
