package haxepunk.utils;

/**
 * Static helper class used for saving and loading data from stored cookies.
 */
class Data
{
	public static var PREFIX:String = "HaxePunk";

	/**
	 * If you want to share data between different SWFs on the same host, use this id.
	 */
	public static var id:String = "";

	/**
	 * Overwrites the current data with the file.
	 * @param	file		The filename to load.
	 */
	public static function load(file:String = ""):Void {}

	/**
	 * Overwrites the file with the current data. The current data will not be saved until this function is called.
	 * @param	file		The filename to save.
	 * @param	overwrite	Clear the file before saving.
	 */
	public static function save(file:String = "", overwrite:Bool = true):Void {}

	/**
	 * Reads an int from the current data.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public static function readInt(name:String, defaultValue:Int = 0):Int return defaultValue;

	/**
	 * Reads a Boolean from the current data.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public static function readBool(name:String, defaultValue:Bool = true):Bool return defaultValue;

	/**
	 * Reads a String from the current data.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public static function readString(name:String, defaultValue:String = ""):String return defaultValue;

	/**
	 * Reads a property from the data object.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public static function read(name:String, ?defaultValue:Dynamic):Dynamic return null;

	/**
	 * Writes a Dynamic object to the current data.
	 * @param	name		Property to write.
	 * @param	value		Value to write.
	 */
	public static function write(name:String, value:Dynamic):Void {}

	/** @private Loads the data file, or return it if you're loading the same one. */
	static function loadData(file:String):Dynamic return null;
}
