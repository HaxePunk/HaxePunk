package haxepunk2d.utils;

/**
 * A version with semver values: "Major.Minor.Patch".
 */
class Version
{
	/** The version in the following format: "Major.Minor.Patch". */
	var version : String;

	/** The major value. */
	var majorVersion : Int;

	/** The minor value. */
	var minorVersion : Int;

	/** The patch version. */
	var patchVersion : Int;
}

/**
 * Infos from HaxePunk's haxelib.json.
 * Variables description taken from: http://haxe.org/manual/haxelib-json.html
 */
class LibInfo
{
	/** An array of user names which identify contributors to the library, ie. people who can push to haxelib. */
	static var contributors : Array<String>;

	/** An array of object composed of a library name and optional version. */
	static var dependencies : Array<{name:String, version:Version}>;

	/** The description of what the library is doing. */
	static var description : String;

	/** The license under which the library is released. Can be GPL, LGPL, BSD, Public (for Public Domain) or MIT. */
	static var license : String;

	/** The name of the library. */
	static var name : String;

	/** The release notes of the current version. */
	static var releaseNotes : String;

	/** An array of tag-strings which are used on the repository website to sort libraries. */
	static var tags : Array<String>;

	/** The URL of the library, i.e. where more information can be found. */
	static var url : String;

	/** The version of the library.*/
	static var version : Version;
}
