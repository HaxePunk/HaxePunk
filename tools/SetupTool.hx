import haxe.io.Bytes;
import neko.Sys;
import neko.Lib;
import neko.FileSystem;
import neko.io.File;
import neko.io.FileInput;
import neko.io.FileOutput;
import neko.io.Path;
import neko.zip.Reader;

class SetupTool
{

	public function new()
	{
		var args:Array<String> = Sys.args();
		if (args.length < 2)
		{
			Lib.println("USAGE: haxelib run HaxePunk new");
			return;
		}

//		var last:String = (new Path(args[args.length-1])).toString();
//		var slash = last.substr(-1);
//		if (slash=="/"|| slash=="\\") 
//			last = last.substr(0, last.length - 1);
//		if (FileSystem.exists(last) && FileSystem.isDirectory(last)) {
//			Sys.setCwd(last);
//		}

		var command:String = args.shift();

		switch (command)
		{
			case "new":
				newProject(args);
		}
	}

	public function newProject(args:Array<String>)
	{
		var destFolder:String = (new Path(args.shift())).toString();

		var slash:String = destFolder.substr(-1);
		var destCheck:String = destFolder;
		if (slash=="/"|| slash=="\\")
			destCheck = destFolder.substr(0, destFolder.length - 1);

		if (FileSystem.exists(destCheck) && FileSystem.isDirectory(destCheck))
		{
			// read the template zip file
			var fin:FileInput = File.read("template.zip", true);
			var entries:List<ZipEntry> = Reader.readZip(fin);
			fin.close();

			// unzip the file
			for (entry in entries)
			{
				var filename:String = entry.fileName;
				slash = filename.substr(-1);
				// check if it's a folder
				if (slash=="/"|| slash=="\\")
				{
					filename = filename.substr(0, filename.length - 1);
					var folder:String = destFolder + filename;
					if ( ! FileSystem.exists(folder) )
					{
						FileSystem.createDirectory(folder);
					}
				}
				else
				{
					// create the file
					var bytes:Bytes = Reader.unzip(entry);
					var fout:FileOutput = File.write(destFolder + filename, true);
					fout.writeBytes(bytes, 0, bytes.length);
					fout.close();
				}
			}
		}
	}

	public static function main()
	{
		new SetupTool();
	}

}