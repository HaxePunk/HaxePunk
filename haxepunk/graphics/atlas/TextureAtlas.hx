package haxepunk.graphics.atlas;

import haxe.io.Eof;
import haxe.io.Input;
import haxe.io.Path;
import haxe.io.StringInput;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Assets;
import haxepunk.HXP;
import haxepunk.graphics.atlas.AtlasData;
using StringTools;

class TextureAtlas extends Atlas
{
	/**
	 * Loads a TexturePacker xml file and generates all tile regions.
	 * Uses the Generic XML exporter format from Texture Packer.
	 * @param	file	The TexturePacker file to load
	 * @return	A TextureAtlas with all packed images defined as regions
	 */
	public static function loadTexturePacker(file:String):TextureAtlas
	{
		var xml = Xml.parse(Assets.getText(file));
		var root = xml.firstElement();
		var atlas = new TextureAtlas(root.get("imagePath"));
		for (sprite in root.elements())
		{
			HXP.rect.x = Std.parseInt(sprite.get("x"));
			HXP.rect.y = Std.parseInt(sprite.get("y"));
			if (sprite.exists("w")) HXP.rect.width = Std.parseInt(sprite.get("w"));
			else if (sprite.exists("width")) HXP.rect.width = Std.parseInt(sprite.get("width"));
			if (sprite.exists("h")) HXP.rect.height = Std.parseInt(sprite.get("h"));
			else if (sprite.exists("height")) HXP.rect.height = Std.parseInt(sprite.get("height"));

			// set the defined region
			var name = if (sprite.exists("n")) sprite.get("n")
						else if (sprite.exists("name")) sprite.get("name")
						else throw("Unable to find the region's name.");

			var region = atlas.defineRegion(name, HXP.rect);

			if (sprite.exists("r") && sprite.get("r") == "y") region.rotated = true;
		}
		return atlas;
	}

	/**
	 * Loads a libgdx TexturePacker file and generates all tile regions.
	 * @param	file	The TexturePacker file to load
	 * @return	A TextureAtlas with all packed images defined as regions
	 */
	public static inline function loadGdxTexturePacker(file:String):TextureAtlas
	{
		return GdxTexturePacker.load(file);
	}

	function new(?source:AtlasDataType)
	{
		_regions = new Map<String, AtlasRegion>();

		super(source);

		if (source == null)
		{
			_pages = new Map();
		}
	}

	/**
	 * Gets an atlas region based on an identifier
	 * @param	name	The name identifier of the region to retrieve.
	 *
	 * @return	The retrieved region.
	 */
	public inline function getRegion(name:String):AtlasRegion
	{
		if (_regions.exists(name))
			return _regions.get(name);

		throw 'Region has not been defined yet "$name".';
	}

	/**
	 * Creates a new AtlasRegion and assigns it to a name
	 * @param	name	The region name to create
	 * @param	rect	Defines the rectangle of the tile on the tilesheet
	 * @param	center	Positions the local center point to pivot on
	 * @param	page	(optional) Page name, if this atlas supports multiple pages
	 *
	 * @return	The new AtlasRegion object.
	 */
	public function defineRegion(name:String, rect:Rectangle, ?center:Point, ?page:String):AtlasRegion
	{
		var data = _pages == null ? this._data : _pages.get(page);
		var region = data.createRegion(rect, center);
		_regions.set(name, region);
		return region;
	}

	var _regions:Map<String, AtlasRegion>;
	var _pages:Map<String, AtlasData>;
}

@:generic private typedef NamedValue<T> =
{
	name:String,
	value:T
};

@:access(haxepunk.graphics.atlas.TextureAtlas)
private class GdxTexturePacker
{
	public static function load(file:String):TextureAtlas
	{
		var data:String = Assets.getText(file);
		var inputDir:String = Path.directory(file);
		var atlas:TextureAtlas = new TextureAtlas();
		var reader:StringInput = new StringInput(data);
		var page:AtlasData;
		var pageName:String;
		var extension:String;

		while (true)
		{
			var line:String = null;
			try
			{
				line = reader.readLine();
			}
			catch (e:Eof)
			{
				break;
			}
			if (line == null) break;

			line = line.trim();
			if (line.length == 0) continue;

			// new page
			pageName = line;
			extension = Path.extension(pageName);
			page = AtlasData.getAtlasDataByName(Path.join([inputDir, pageName]), true);
			atlas._pages.set(pageName, page);

			var line:String = "";
			while (true)
			{
				try
				{
					line = reader.readLine();
				}
				catch (e:Eof)
				{
					break;
				}
				if (line.indexOf(":") == -1) break;

				var value = getValue(line);
				switch (value.name)
				{
					case "size": {}
					case "format": {}
					case "filter": {}
					case "repeat": {}
				}
			}

			while (line != "")
			{
				var regionName:String = line;
				try
				{
					line = reader.readLine();
				}
				catch (e:Eof)
				{
					break;
				}
				var values:Map<String, String> = new Map();
				while (line.indexOf(":") > -1)
				{
					var value = getValue(line);
					values[value.name] = value.value;
					try
					{
						line = reader.readLine();
					}
					catch (e:Eof)
					{
						break;
					}
				}
				var xy:Array<Int> = [for (x in getTuple(values["xy"])) Std.parseInt(x)];
				var size:Array<Int> = [for (x in getTuple(values["size"])) Std.parseInt(x)];
				var rotate:Float = values["rotate"] == "true" ? -90 : 0;
				var r:Rectangle = (rotate != 0) ? new Rectangle(xy[0], xy[1], size[1], size[0]) : new Rectangle(xy[0], xy[1], size[0], size[1]);
				var path:String = Path.join([inputDir, regionName + "." + extension]);
				// TODO: rotation currently ignored; rotation is in the opposite
				// direction of TexturePacker XML
				atlas.defineRegion(path, r, null, pageName);
			}
		}

		return atlas;
	}

	static inline function getValue(line:String):NamedValue<String>
	{
		var parts:Array<String> = line.split(":");
		return {name: parts[0].trim(), value: parts[1].trim()};
	}

	static inline function getTuple(value:String):Array<String>
	{
		var values:Array<String> = [for (v in value.split(",")) v.trim()];
		return values;
	}
}
