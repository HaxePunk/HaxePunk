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
	public static function load(file:String = ""):void
	{
		var data:Object = loadData(file);
		_data = { };
		for (var i:String in data) _data[i] = data[i];
	}
	
	/**
	 * Overwrites the file with the current data. The current data will not be saved until this function is called.
	 * @param	file		The filename to save.
	 */
	public static function save(file:String = ""):void
	{
		if (_shared) _shared.clear();
		var data:Object = loadData(file);
		for (var i:String in _data) data[i] = _data[i];
		_shared.flush(SIZE);
	}
	
	/**
	 * Reads an int from the current data.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public static function readInt(name:String, defaultValue:int = 0):int
	{
		return int(read(name, defaultValue));
	}
	
	/**
	 * Reads a uint from the current data.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public static function readUint(name:String, defaultValue:uint = 0):uint
	{
		return uint(read(name, defaultValue));
	}
	
	/**
	 * Reads a Boolean from the current data.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public static function readBool(name:String, defaultValue:Boolean = true):Boolean
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
	public static function writeInt(name:String, value:int = 0):void
	{
		_data[name] = value;
	}
	
	/**
	 * Writes a uint to the current data.
	 * @param	name		Property to write.
	 * @param	value		Value to write.
	 */
	public static function writeUint(name:String, value:uint = 0):void
	{
		_data[name] = value;
	}
	
	/**
	 * Writes a Boolean to the current data.
	 * @param	name		Property to write.
	 * @param	value		Value to write.
	 */
	public static function writeBool(name:String, value:Boolean = true):void
	{
		_data[name] = value;
	}
	
	/**
	 * Writes a String to the current data.
	 * @param	name		Property to write.
	 * @param	value		Value to write.
	 */
	public static function writeString(name:String, value:String = ""):void
	{
		_data[name] = value;
	}
	
	/** @private Reads a property from the data object. */
	private static function read(name:String, defaultValue:*):*
	{
		if (_data.hasOwnProperty(name)) return _data[name];
		return defaultValue;
	}
	
	/** @private Loads the data file, or return it if you're loading the same one. */
	private static function loadData(file:String):Object
	{
		if (!file) file = DEFAULT_FILE;
		if (id) _shared = SharedObject.getLocal(PREFIX + "/" + id + "/" + file, "/");
		else _shared = SharedObject.getLocal(PREFIX + "/" + file);
		return _shared.data;
	}
	
	// Data information.
	/** @private */ private static var _shared:SharedObject;
	/** @private */ private static var _dir:String;
	/** @private */ private static var _data:Object = { };
	/** @private */ private static const PREFIX:String = "FlashPunk";
	/** @private */ private static const DEFAULT_FILE:String = "_file";
	/** @private */ private static const SIZE:uint = 10000;
}