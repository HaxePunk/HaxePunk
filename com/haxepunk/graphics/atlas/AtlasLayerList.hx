package com.haxepunk.graphics.atlas;

import nme.display.Sprite;

/**
 * ...
 * @author Erin M Gunn
 */
class AtlasLayerList
{
#if haxe3
	public var layers(get_layers, never):Map<Int, AtlasLayer>;
	private function get_layers():Map<Int, AtlasLayer> { return _layers;	}
#else
	public var layers(get_layers, never):IntHash<AtlasLayer>;
	private function get_layers():IntHash<AtlasLayer> { return _layers;	}
#end

	public function new(sprite:Sprite) 
	{
		_sprite = sprite;
		
#if haxe3
	_layers = new Map<Int, AtlasLayer>();
#else
	_layers = new IntHash<AtlasLayer>();
#end
	}
	
	/**
	 * Clears the graphics for each layer.
	 */
	public function clear()
	{
		for (layer in _layers.keys()) 
		{
			_layers.get(layer).sprite.graphics.clear();
		}
	}
	
	/**
	 * Gets the AtlasLayer for the specified layer.
	 * @param	layer	The layer to get the AtlasLayer for.
	 * @return	The AtlasLayer.
	 */
	public function getLayer(layer:Int):AtlasLayer
	{
		if (_layers.exists(layer))
		{
			return _layers.get(layer);
		}
		else
		{
			return createLayer(layer);
		}
	}
	
	/**
	 * Gets the Sprite for the specified layer.
	 * @param	layer	The layer to get the Sprite for.
	 * @return	The Sprite.
	 */
	public function getSpriteByLayer(layer:Int):Sprite
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
	
	private function createLayer(layer:Int):AtlasLayer
	{
		var nLayer:AtlasLayer = new AtlasLayer();
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
		_sprite.addChildAt(nLayer.sprite, idx);
		return nLayer;
	}
	
	private var _sprite:Sprite;
	
#if haxe3
	private var _layers:Map<Int, AtlasLayer>;
#else
	private var _layers:IntHash<AtlasLayer>;
#end
}