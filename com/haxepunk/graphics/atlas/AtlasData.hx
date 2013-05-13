package com.haxepunk.graphics.atlas;

import nme.display.BitmapData;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.display.Tilesheet;
import nme.geom.Rectangle;
import nme.geom.Point;

class Layer
{
	public var sprite:Sprite;
	public var data:Array<Float>;
	public var index:Int;
	public var dirty:Bool;

	public function new()
	{
		sprite = new Sprite();
		data = new Array<Float>();
		prepare();
	}

	public inline function prepare()
	{
		if (index < data.length)
		{
			data.splice(index, data.length - index);
		}
		index = 0; // reset index for next run
		dirty = false;
	}
}

class AtlasData
{

	public var width(default, null):Int;
	public var height(default, null):Int;

	public static inline function create(source:Dynamic)
	{
		var data:AtlasData;
		if (Std.is(source, BitmapData))
		{
#if debug
			HXP.log("Atlases using BitmapData will not be managed.");
#end
			data = new AtlasData(source);
		}
		else
		{
			if (_dataPool.exists(source))
			{
				data = _dataPool.get(source);
				data._refCount += 1;
			}
			else
			{
				data = new AtlasData(HXP.getBitmap(source));
				data._name = source;
				_dataPool.set(source, data);
			}
		}
		return data;
	}

	private function new(bd:BitmapData)
	{
//#if haxe3
		//_layers = new Map<Int,Layer>();
//#else
		//_layers = new IntHash<Layer>();
//#end

		_tilesheet = new Tilesheet(bd);
		_renderFlags = Tilesheet.TILE_TRANS_2x2 | Tilesheet.TILE_ALPHA | Tilesheet.TILE_BLEND_NORMAL | Tilesheet.TILE_RGB;

		width = bd.width;
		height = bd.height;

		_tileIndex = 0;
		_refCount = 1;
		_layerIndex = -1;
		_atlases.push(this);
	}

	public static inline function clear()
	{
		for (layer in _layers.keys()) 
		{
			_layers.get(layer).sprite.graphics.clear();
		}
	}

	/**
	 * Called by the current Scene to draw all TextureAtlas
	 */
	#if haxe3
	public static inline function render(layers:Map<Int,Layer>)
	#else
	public static inline function render(layers:IntHash<Layer>)
	#end
	{
		if (_atlases.length > 0)
		{
			for (atlas in _atlases)
			{
				atlas.renderData(layers);
			}
		}
	}

	/**
	 * Renders the current TextureAtlas
	 * @param g the graphics context to draw in
	 * @param smooth if rendering should use antialiasing
	 */
	#if haxe3
	private inline function renderData(layers:Map<Int,Layer>)
	#else
	private inline function renderData(layers:IntHash<Layer>)
	#end
	{
		var l:Layer;

		for (layer in layers.keys())
		{
			l = layers.get(layer);
			// check that we have something to draw
			if (l.dirty)
			{
				renderLayer(l);
			}
		}
	}

	public function destroy()
	{
		_refCount -= 1;
		if (_refCount < 0)
		{
			_atlases.remove(this);
		}
	}

	/**
	 * Removes all atlases from the display list
	 */
	public static function destroyAll()
	{
		for (atlas in _atlases)
		{
			atlas.destroy();
		}
	}

	/**
	 * Creates a new AtlasRegion and assigns it to a name
	 * @param name the region name to create
	 * @param rect defines the rectangle of the tile on the tilesheet
	 * @param center positions the local center point to pivot on
	 */
	public inline function createRegion(rect:Rectangle, ?center:Point):AtlasRegion
	{
		_tilesheet.addTileRect(rect, center);
		var region = new AtlasRegion(this, _tileIndex, rect);
		_tileIndex += 1;
		return region;
	}

	private inline function renderLayer(layer:Layer)
	{
		layer.prepare();
		layer.sprite.graphics.drawTiles(_tilesheet, layer.data, Atlas.smooth, _renderFlags);
	}

	private inline function setLayer(layer:Int)
	{
		if (_layers.exists(layer))
		{
			_layer = _layers.get(layer);
		}
		else
		{
			_layer = createLayer(layer);
		}
		_layerIndex = layer;
	}

	public inline function prepareTile(tile:Int, x:Float, y:Float, layer:Int,
		scaleX:Float, scaleY:Float, angle:Float,
		red:Float, green:Float, blue:Float, alpha:Float)
	{
		if (_layerIndex != layer) setLayer(layer);
		var d = _layer.data;
		_layer.dirty = true;

		d[_layer.index++] = x;
		d[_layer.index++] = y;
		d[_layer.index++] = tile;

		// matrix transformation
		if (angle == 0)
		{
			// fast defaults for non-rotated tiles (cos=1, sin=0)
			d[_layer.index++] = scaleX; // m00
			d[_layer.index++] = 0; // m01
			d[_layer.index++] = 0; // m10
			d[_layer.index++] = scaleY; // m11
		}
		else
		{
			var cos = Math.cos(-angle * HXP.RAD);
			var sin = Math.sin(-angle * HXP.RAD);
			d[_layer.index++] = cos * scaleX; // m00
			d[_layer.index++] = sin * scaleX; // m01
			d[_layer.index++] = -sin * scaleY; // m10
			d[_layer.index++] = cos * scaleY; // m11
		}

		d[_layer.index++] = red;
		d[_layer.index++] = green;
		d[_layer.index++] = blue;
		d[_layer.index++] = alpha;

		if (_layer.index > Atlas.drawCallThreshold)
		{
			renderLayer(_layer);
		}
	}

	public static function getSpriteByLayer(layer:Int):Sprite
	{
		if (_layers.exists(layer))
		{
			return _layers.get(layer).sprite;
		}
		else
		{
			return createLayer(layer).sprite;
		}
	}
	
	private static function createLayer(layer:Int):Layer
	{
		var nLayer:Layer = new Layer();
		var idx:Int = 0;
		// create a revers order of the layers
		var layers = new Array<Int>();
		for (l in _layers.keys()) layers.push(l);
		layers.sort(function(a:Int, b:Int):Int { return b - a; } );
		// find the index to insert the layer
		for (l in layers) 
		{
			if (layer > l) break;
			idx += 1;
		}
		_layers.set(layer, nLayer);
		HXP.engine.addChildAt(nLayer.sprite, idx);
		return nLayer;
	}
	
	#if haxe3
	public static function getLayers():Map<Int,Layer>
	#else
	public static function getLayers():IntHash<Layer>
	#end
	{
		return _layers;
	}

	// used for pooling
	private var _name:String;
	private var _refCount:Int; // memory management

	private var _layerIndex:Int;
	private var _layer:Layer; // current layer
	private var _renderFlags:Int;
	private var _tileIndex:Int;
	private var _tilesheet:Tilesheet;
#if haxe3
	private static var _layers:Map<Int,Layer> = new Map<Int,Layer>();
#else
	private static var _layers:IntHash<Layer> = new IntHash<Layer>();
#end

#if haxe3
	//private static var _sprites:Map<Int,Sprite> = new Map<Int,Sprite>();
	private static var _dataPool:Map<String,AtlasData> = new Map<String,AtlasData>();
#else
	//private static var _sprites:IntHash<Sprite> = new IntHash<Sprite>();
	private static var _dataPool:Hash<AtlasData> = new Hash<AtlasData>();
#end
	private static var _atlases:Array<AtlasData> = new Array<AtlasData>();
}
