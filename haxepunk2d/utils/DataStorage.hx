package haxepunk2d.utils;

/**
 * Static helper class used for saving and loading data.
 */
class DataStorage
{
	/** If you want to share data between different games on the same host use this ID.*/
	static var ID:String;

	/**
	 * Overwrites the current data with the file.
	 */
	function load(filename:String="");

	/**
	 * Overwrites the file with the current data. The current data will not be saved until this function is called.
	 */
	function save(filename:String="");

	/**
	 * Reads a property from the data object.
	 */
	function read(name:String, ?defaultValue:Dynamic):Dynamic;

	/**
	 * Reads an Integer from the current data.
	 */
	function readInt(name:String, ?defaultValue:Int):Int;

	/**
	 * Reads a Float from the current data.
	 */
	function readFloat(name:String, ?defaultValue:Float):Float;

	/**
	 * Reads a Boolean from the current data.
	 */
	function readBool(name:String, ?defaultValue:Bool):Bool;

	/**
	 * Reads a String from the current data.
	 */
	function readString(name:String, ?defaultValue:String):String;

	/**
	 * Writes a Dynamic object to the current data.
	 */
	function write(name:String, value:Dynamic):Void;
}
