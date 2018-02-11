package haxepunk.utils;

@:enum
abstract LogLevel(Int) from Int to Int
{
	var Debug = 10;
	var Info = 20;
	var Warning = 30;
	var Error = 40;
	var Critical = 50;

	static var longest:Int = 20;

	public inline function format(s:String, ?pos:haxe.PosInfos):String
	{
		var d = Date.now().toString();
		var p = StringTools.lpad(pos.fileName, " ", longest) + ":" + StringTools.lpad(Std.string(pos.lineNumber), " ", 4) + ":";
		#if desktop
		var colorize = Sys.systemName() != "Windows";
		if (pos.fileName.length > longest) longest = pos.fileName.length;
		if (!colorize) return '$d $p  $s';
		else return switch (this)
		{
			default: '\033[38;5;6m$d $p  $s\033[m';
			case Info: '\033[38;5;12m$d $p  $s\033[m';
			case Warning: '\033[38;5;3m$d $p  $s\033[m';
			case Error: '\033[38;5;1m$d $p  $s\033[m';
			case Critical: '\033[38;5;5m$d $p  $s\033[m';
		}
		#else
		return '$d $p  $s';
		#end
	}
}

class Log
{
	public static inline function write(s:Dynamic, level:LogLevel = LogLevel.Info, ?pos:haxe.PosInfos)
	{
		#if (hxp_debug && !(hxp_no_log))
		#if neko
		var p:haxe.PosInfos = {fileName: "", lineNumber: 0, customParams: null, methodName: "", className: ""};
		#else
		var p:haxe.PosInfos = null;
		#end
		haxe.Log.trace(level.format(Std.string(s), pos), p);
		#end
	}

	public static inline function debug(s:Dynamic, ?pos:haxe.PosInfos) write(s, LogLevel.Debug, pos);
	public static inline function info(s:Dynamic, ?pos:haxe.PosInfos) write(s, LogLevel.Info, pos);
	public static inline function warning(s:Dynamic, ?pos:haxe.PosInfos) write(s, LogLevel.Warning, pos);
	public static inline function error(s:Dynamic, ?pos:haxe.PosInfos) write(s, LogLevel.Error, pos);
	public static inline function critical(s:Dynamic, ?pos:haxe.PosInfos) write(s, LogLevel.Critical, pos);
}
