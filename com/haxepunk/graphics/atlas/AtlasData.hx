package com.haxepunk.graphics.atlas;

import nme.display.BitmapData;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.display.Tilesheet;
import nme.geom.Rectangle;
import nme.geom.Point;

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
		_tilesheet = new Tilesheet(bd);
		_renderFlags = Tilesheet.TILE_TRANS_2x2 | Tilesheet.TILE_ALPHA | Tilesheet.TILE_BLEND_NORMAL | Tilesheet.TILE_RGB;

		width = bd.width;
		height = bd.height;

		_tileIndex = 0;
		_refCount = 1;
		_layerIndex = -1;
		_atlases.push(this);
	}

	/**
	 * Called by the current Scene to draw all TextureAtlas
	 */
	public static inline function render()
	{
		if (_atlases.length > 0)
		{
			for (atlas in _atlases)
			{
				atlas.renderData();
			}
		}
	}

	/**
	 * Renders the current TextureAtlas
	 * @param g the graphics context to draw in
	 * @param smooth if rendering should use antialiasing
	 */
	private inline function renderData()
	{
		var l:AtlasLayer;

		for (layer in _layerList.layers.keys())
		{
			l = _layerList.layers.get(layer);
			// check that we have something to draw
			if (l.dirty)
			{
				renderLayer(l);
			}
		}
	}

	/**
	 * Removes all AtlasData's.
	 */
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
	 * Sets the current AtlasLayerList.
	 * @param	layerList  The AtlasLayerList to use.
	 */
	public static function setLayerList(layerList:AtlasLayerList)
	{
		_layerList = layerList;
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

	private inline function renderLayer(layer:AtlasLayer)
	{
		layer.prepare();
		layer.sprite.graphics.drawTiles(_tilesheet, layer.data, Atlas.smooth, _renderFlags);
	}

	private inline function setLayer(layer:Int)
	{
		_layer = _layerList.getLayer(layer);
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

	// used for pooling
	private var _name:String;
	private var _refCount:Int; // memory management

	private var _layerIndex:Int;
	private var _layer:AtlasLayer; // current layer
	private var _renderFlags:Int;
	private var _tileIndex:Int;
	private var _tilesheet:Tilesheet;
	

#if haxe3
	private static var _dataPool:Map<String,AtlasData> = new Map<String,AtlasData>();
#else
	private static var _dataPool:Hash<AtlasData> = new Hash<AtlasData>();
#end
	private static var _layerList:AtlasLayerList;
	private static var _atlases:Array<AtlasData> = new Array<AtlasData>();
}
