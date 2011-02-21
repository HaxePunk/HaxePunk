package com.haxepunk.utils;

import flash.net.SharedObject;

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
		for (str in data) _data[i] = data[i];
	}
	
	/**
	 * Overwrites the file with the current data. The current data will not be saved until this function is called.
	 * @param	file		The filename to save.
	 */
	public static function save(file:String = "")
	{
		if (_shared) _shared.clear();
		var data:Object = loadData(file);
		var str:String;
		for (str in _data) data[i] = _data[i];
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
		return int(read(name, defaultValue));
	}
	
	/**
	 * Reads a uint from the current data.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public static function readUint(name:String, defaultValue:Int = 0):Int
	{
		return uint(read(name, defaultValue));
	}
	
	/**
	 * Reads a Boolean from the current data.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public static function readBool(name:String, defaultValue:Bool = true):Bool
	{
		return Boolean(read(name, defaultValue));
	}
	
	/**
	 * Reads a String from the current data.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public static function readString(name:String, defaultValue:String = ""):String
	{
		return String(read(name, defaultValue));
	}
	
	/**
	 * Writes an int to the current data.
	 * @param	name		Property to write.
	 * @param	value		Value to write.
	 */
	public static function writeInt(name:String, value:Int = 0)
	{
		_data[name] = value;
	}
	
	/**
	 * Writes a uint to the current data.
	 * @param	name		Property to write.
	 * @param	value		Value to write.
	 */
	public static function writeUint(name:String, value:Int = 0)
	{
		_data[name] = value;
	}
	
	/**
	 * Writes a Boolean to the current data.
	 * @param	name		Property to write.
	 * @param	value		Value to write.
	 */
	public static function writeBool(name:String, value:Bool = true)
	{
		_data[name] = value;
	}
	
	/**
	 * Writes a String to the current data.
	 * @param	name		Property to write.
	 * @param	value		Value to write.
	 */
	public static function writeString(name:String, value:String = "")
	{
		_data[name] = value;
	}
	
	/** @private Reads a property from the data object. */
	private static function read(name:String, defaultValue:Dynamic):Dynamic
	{
		if (_data.hasOwnProperty(name)) return _data[name];
		return defaultValue;
	}
	
	/** @private Loads the data file, or return it if you're loading the same one. */
	private static function loadData(file:String):Dynamic
	{
		if (file == null) file = DEFAULT_FILE;
		if (id != null) _shared = SharedObject.getLocal(PREFIX + "/" + id + "/" + file, "/");
		else _shared = SharedObject.getLocal(PREFIX + "/" + file);
		return _shared.data;
	}
	
	// Data information.
	private static var _shared:SharedObject;
	private static var _dir:String;
	private static var _data:Hash<Dynamic>;
	private static inline var PREFIX:String = "FlashPunk";
	private static inline var DEFAULT_FILE:String = "_file";
	private static inline var SIZE:Int = 10000;
}