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
	static var contributors(default, null) : Array<String>;

	/** An array of object composed of a library name and optional version. */
	static var dependencies(default, null) : Array<{name:String, version:Version}>;

	/** The description of what the library is doing. */
	static var description(default, null) : String;

	/** The license under which the library is released. Can be GPL, LGPL, BSD, Public (for Public Domain) or MIT. */
	static var license (default, null): String;

	/** The name of the library. */
	static var name(default, null) : String;

	/** The release notes of the current version. */
	static var releaseNotes(default, null) : String;

	/** An array of tag-strings which are used on the repository website to sort libraries. */
	static var tags(default, null) : Array<String>;

	/** The URL of the library, i.e. where more information can be found. */
	static var url(default, null) : String;

	/** The version of the library.*/
	static var version(default, null) : Version;
}
