package com.haxepunk.utils;

import nme.net.SharedObject;

/**
 * Static helper class used for saving and loading data from stored cookies.
 */
class Data 
{
	/**
	 * If you want to share data between different SWFs on the same host, use this id.
	 */
	public static var id:String = "";
	
	/**
	 * Overwrites the current data with the file.
	 * @param	file		The filename to load.
	 */
	public static function load(file:String = "")
	{
		var data:Dynamic = loadData(file);
		_data = new Hash<Dynamic>();
		var str:String;
		for (str in Reflect.fields(data)) _data.set(str, Reflect.field(data, str));
	}
	
	/**
	 * Overwrites the file with the current data. The current data will not be saved until this function is called.
	 * @param	file		The filename to save.
	 */
	public static function save(file:String = "", overwrite:Bool = true)
	{
		if (_shared != null) _shared.clear();
		var data:Dynamic = loadData(file);
		var str:String;
		if (overwrite)
			for (str in Reflect.fields(data)) Reflect.deleteField(data, str);
		for (str in _data.keys()) Reflect.setField(data, str, _data.get(str));
		_shared.flush(SIZE);
	}
	
	/**
	 * Reads an int from the current data.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public static function readInt(name:String, defaultValue:Int = 0):Int
	{
		return Std.int(read(name, defaultValue));
	}
	
	/**
	 * Reads a Boolean from the current data.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public static function readBool(name:String, defaultValue:Bool = true):Bool
	{
		return read(name, defaultValue);
	}
	
	/**
	 * Reads a String from the current data.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public static function readString(name:String, defaultValue:String = ""):String
	{
		return Std.string(read(name, defaultValue));
	}
	
	/**
	 * Reads a property from the data object.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public static function read(name:String, defaultValue:Dynamic = null):Dynamic
	{
		if (_data.get(name) != null) return _data.get(name);
		return defaultValue;
	}
	
	/**
	 * Writes a Dynamic object to the current data.
	 * @param	name		Property to write.
	 * @param	value		Value to write.
	 */
	public static function write(name:String, value:Dynamic)
	{
		_data.set(name, value);
	}
	
	/** @private Loads the data file, or return it if you're loading the same one. */
	private static function loadData(file:String):Dynamic
	{
		if (file == null) file = DEFAULT_FILE;
		if (id != "") _shared = SharedObject.getLocal(PREFIX + "/" + id + "/" + file, "/");
		else _shared = SharedObject.getLocal(PREFIX + "/" + file);
		return _shared.data;
	}
	
	// Data information.
	private static var _shared:SharedObject;
	private static var _dir:String;
	private static var _data:Hash<Dynamic> = new Hash<Dynamic>();
	private static inline var PREFIX:String = "HaxePunk";
	private static inline var DEFAULT_FILE:String = "_file";
	private static inline var SIZE:Int = 10000;
}